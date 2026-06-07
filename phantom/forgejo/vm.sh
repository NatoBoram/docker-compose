#!/bin/sh

set -e

mkdir -p /vm/storage
DISK_IMG="/vm/storage/runner.qcow2"
SEED_ISO="/vm/storage/seed.iso"

# Download cloud image
mkdir -p /vm/images
if [ ! -f "/vm/images/$IMAGE_NAME" ]; then
  echo "Downloading $IMAGE_NAME..."
  curl --fail --location --output "/vm/images/$IMAGE_NAME" --silent "$IMAGE_URL"
fi

# Create disk for virtual machine
qemu-img create -f qcow2 -b "/vm/images/$IMAGE_NAME" -F qcow2 "$DISK_IMG" "$VM_STORAGE"

USER_DATA="$(mktemp)"
cat <<EOF >"$USER_DATA"
#cloud-config
users:
  - name: runner
    groups: sudo
    shell: /bin/bash
    sudo: ["ALL=(ALL) NOPASSWD:ALL"]

packages:
  - docker.io
  - curl
  - jq

write_files:
  - path: /vm/storage/config.yaml
    permissions: "0600"
    owner: root:root
    content: |
      runner:
        capacity: $VM_CPU
        labels:
          - docker:docker://node:lts
          - ubuntu-latest:docker://node:lts

      container:
        enable_ipv6: true
        privileged: true

      server:
        connections:
          homelab:
            url: "$FORGEJO_INSTANCE_URL"
            uuid: "$FORGEJO_RUNNER_UUID"
            token: "$FORGEJO_RUNNER_TOKEN"

runcmd:
  # Forgejo Runner: https://forgejo.org/docs/latest/admin/actions/installation/binary
  - export ARCH=\$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/')
  - export RUNNER_VERSION=\$(curl -X 'GET' https://data.forgejo.org/api/v1/repos/forgejo/runner/releases/latest | jq .name -r | cut -c 2-)
  - export FORGEJO_URL="https://code.forgejo.org/forgejo/runner/releases/download/v\${RUNNER_VERSION}/forgejo-runner-\${RUNNER_VERSION}-linux-\${ARCH}"

  - curl --fail --location --output /usr/local/bin/forgejo-runner --silent \${FORGEJO_URL}
  - chmod +x /usr/local/bin/forgejo-runner

  - forgejo-runner --config /vm/storage/config.yaml one-job --wait
  - systemctl poweroff
EOF

META_DATA="$(mktemp)"
echo "local-hostname: $VM_HOSTNAME" >"$META_DATA"

cloud-localds "$SEED_ISO" "$USER_DATA" "$META_DATA"
rm -f "$USER_DATA" "$META_DATA"

exec qemu-system-x86_64 \
  -enable-kvm \
  -cpu host \
  -smp "$VM_CPU" \
  -m "$VM_RAM" \
  -drive file="$DISK_IMG",if=virtio,format=qcow2 \
  -drive file="$SEED_ISO",format=raw,if=virtio,readonly=on \
  -device virtio-net-pci,netdev=vmnic \
  -netdev user,id=vmnic,hostfwd=tcp::22-:22 \
  -nographic \
  -snapshot
rm -f "$DISK_IMG" "$SEED_ISO"
