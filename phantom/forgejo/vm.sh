#!/bin/sh

set -e
umask 077

# Cleanup runs when the script exits.
cleanup() {
  EXIT_STATUS="$1"
  WORK_DIR="$2"
  RUNNERS_URL="$3"
  RUNNER_ID="$4"
  QEMU_PID="$5"
  trap - EXIT INT TERM

  if [ -n "$QEMU_PID" ]; then
    kill "$QEMU_PID" 2>/dev/null || true
    wait "$QEMU_PID" 2>/dev/null || true
  fi

  if [ -n "$RUNNER_ID" ]; then
    if HTTP_STATUS="$(curl --silent --show-error --connect-timeout 10 --max-time 30 --header "@$WORK_DIR/authorization" --request DELETE --output /dev/null --write-out '%{http_code}' "$RUNNERS_URL/$RUNNER_ID")"; then
      case "$HTTP_STATUS" in
      204 | 404) ;;
      *)
        printf 'Failed to revoke runner %s: HTTP %s\n' "$RUNNER_ID" "$HTTP_STATUS" >&2
        EXIT_STATUS=1
        ;;
      esac
    else
      printf 'Failed to revoke runner %s; remove it in Forgejo before restarting.\n' "$RUNNER_ID" >&2
      EXIT_STATUS=1
    fi
  fi

  rm --force "$WORK_DIR/authorization" "$WORK_DIR/registration.json" "$WORK_DIR/runners.json" "$WORK_DIR/stale-runners" "$WORK_DIR/user-data" "$WORK_DIR/meta-data" "$WORK_DIR/disk.qcow2" "$WORK_DIR/seed.img"
  rmdir "$WORK_DIR"
  exit "$EXIT_STATUS"
}

: "${FORGEJO_INSTANCE_URL:?Set FORGEJO_INSTANCE_URL}"
: "${VM_HOSTNAME:?Set VM_HOSTNAME}"

WORK_DIR="$(mktemp --directory)"
RUNNERS_URL="${FORGEJO_INSTANCE_URL%/}/api/v1/admin/actions/runners"
RUNNER_ID=''
QEMU_PID=''
trap 'cleanup "$?" "$WORK_DIR" "$RUNNERS_URL" "$RUNNER_ID" "$QEMU_PID"' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

# Download cloud image.
BASE_IMAGE="/vm/images/$IMAGE_NAME"
mkdir --parents /vm/images
if [ ! -f "$BASE_IMAGE" ]; then
  printf 'Downloading %s...\n' "$IMAGE_NAME"
  curl --fail --location --output "$BASE_IMAGE" --silent "$IMAGE_URL"
fi

# Resolve Docker's service name outside QEMU, which has its own DNS resolver.
REGISTRY_ADDRESS="$(getent ahostsv4 registry | awk 'NR == 1 {print $1}')"
: "${REGISTRY_ADDRESS:?Could not resolve the local registry}"
curl --fail --silent --show-error --connect-timeout 10 --max-time 30 --retry 5 --retry-connrefused \
  --output /dev/null "http://$REGISTRY_ADDRESS:5000/v2/"

# Keep the provisioning token out of process arguments and guest cloud-init.
API_TOKEN="$(cat /run/secrets/FORGEJO_RUNNER_API_TOKEN)"
case "$API_TOKEN" in
'' | *[!a-zA-Z0-9]*)
  printf 'Invalid Forgejo runner API token.\n' >&2
  exit 1
  ;;
esac
printf 'Authorization: token %s\n' "$API_TOKEN" >"$WORK_DIR/authorization"
unset API_TOKEN

# Collect before deleting: removing runners while paging could skip entries.
PAGE=1
: >"$WORK_DIR/stale-runners"
while :; do
  curl --fail --silent --show-error --connect-timeout 10 --max-time 30 \
    --header "@$WORK_DIR/authorization" --output "$WORK_DIR/runners.json" "$RUNNERS_URL?page=$PAGE&limit=50"
  PAGE_SIZE="$(jq --exit-status 'if type == "array" then length else error("Expected a runner list") end' "$WORK_DIR/runners.json")"
  [ "$PAGE_SIZE" -gt 0 ] || break

  jq --raw-output --arg name "$VM_HOSTNAME" '
    .[] | select(.name == $name and .owner_id == 0 and .repo_id == 0) |
    if .status != "offline" then error("A matching runner is still online; stop it before restarting")
    elif (.id | type == "number" and . > 0 and . == floor) then .id
    else error("Invalid stale runner ID")
    end
  ' "$WORK_DIR/runners.json" >>"$WORK_DIR/stale-runners"
  PAGE="$((PAGE + 1))"
done

while IFS= read -r STALE_RUNNER_ID; do
  printf 'Revoking stale runner %s for %s...\n' "$STALE_RUNNER_ID" "$VM_HOSTNAME"
  HTTP_STATUS="$(curl --silent --show-error --connect-timeout 10 --max-time 30 \
    --header "@$WORK_DIR/authorization" --request DELETE \
    --output /dev/null --write-out '%{http_code}' "$RUNNERS_URL/$STALE_RUNNER_ID")"
  case "$HTTP_STATUS" in
  204 | 404) ;;
  *)
    printf 'Failed to revoke stale runner %s: HTTP %s\n' "$STALE_RUNNER_ID" "$HTTP_STATUS" >&2
    exit 1
    ;;
  esac
done <"$WORK_DIR/stale-runners"
rm --force "$WORK_DIR/runners.json" "$WORK_DIR/stale-runners"

# Register a single-use runner for this VM.
printf 'Registering an ephemeral runner for %s...\n' "$VM_HOSTNAME"
jq --null-input --arg name "$VM_HOSTNAME" '{name: $name, ephemeral: true}' |
  curl --fail --silent --show-error --connect-timeout 10 --max-time 30 --header "@$WORK_DIR/authorization" --header 'Content-Type: application/json' --data-binary @- --output "$WORK_DIR/registration.json" "$RUNNERS_URL"

# Read the ID first so cleanup can revoke a registration with invalid credentials.
RUNNER_ID="$(jq --exit-status --raw-output '.id | select(type == "number" and . > 0 and . == floor)' "$WORK_DIR/registration.json")"
FORGEJO_RUNNER_UUID="$(jq --exit-status --raw-output '.uuid | select(type == "string") | select(test("^[a-fA-F0-9-]{36}$"))' "$WORK_DIR/registration.json")"
FORGEJO_RUNNER_TOKEN="$(jq --exit-status --raw-output '.token | select(type == "string") | select(test("^[a-zA-Z0-9_-]+$"))' "$WORK_DIR/registration.json")"
rm --force "$WORK_DIR/registration.json"

# Configure the guest.
cat <<EOF >"$WORK_DIR/user-data"
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
  - path: /etc/docker/daemon.json
    permissions: "0644"
    owner: root:root
    content: |
      {
        "registry-mirrors": ["http://$REGISTRY_ADDRESS:5000"],
        "insecure-registries": ["$REGISTRY_ADDRESS:5000"]
      }

  - path: /vm/storage/config.yaml
    permissions: "0600"
    owner: root:root
    content: |
      runner:
        capacity: 1
        labels:
          - docker:docker://node:lts
          - ubuntu-latest:docker://node:lts

      cache:
        enabled: true
        dir: /vm/storage/cache

      container:
        enable_ipv6: true

      server:
        connections:
          homelab:
            url: "$FORGEJO_INSTANCE_URL"
            uuid: "$FORGEJO_RUNNER_UUID"
            token: "$FORGEJO_RUNNER_TOKEN"

runcmd:
  # Docker
  # The mirror's address can overlap Docker's default bridge subnet in the guest.
  - ip route replace "$REGISTRY_ADDRESS/32" via 10.0.2.2
  - systemctl restart docker

  # Forgejo Runner: https://forgejo.org/docs/latest/admin/actions/installation/binary
  - export ARCH=\$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/')
  - export RUNNER_VERSION=\$(curl -X 'GET' https://data.forgejo.org/api/v1/repos/forgejo/runner/releases/latest | jq .name -r | cut -c 2-)
  - export FORGEJO_URL="https://code.forgejo.org/forgejo/runner/releases/download/v\${RUNNER_VERSION}/forgejo-runner-\${RUNNER_VERSION}-linux-\${ARCH}"

  - curl --fail --location --output /usr/local/bin/forgejo-runner --silent \${FORGEJO_URL}
  - chmod +x /usr/local/bin/forgejo-runner

  - forgejo-runner --config /vm/storage/config.yaml one-job --wait
  - systemctl poweroff
EOF

printf 'local-hostname: %s\n' "$VM_HOSTNAME" >"$WORK_DIR/meta-data"

# Create disposable VM disks.
qemu-img create -f qcow2 -b "$BASE_IMAGE" -F qcow2 "$WORK_DIR/disk.qcow2" "$VM_STORAGE"
cloud-localds "$WORK_DIR/seed.img" "$WORK_DIR/user-data" "$WORK_DIR/meta-data"
rm --force "$WORK_DIR/user-data" "$WORK_DIR/meta-data"

# QEMU retains the open files, but their paths cannot survive the VM's lifetime.
exec 3<>"$WORK_DIR/disk.qcow2"
exec 4<>"$WORK_DIR/seed.img"
rm --force "$WORK_DIR/disk.qcow2" "$WORK_DIR/seed.img"

# Wait for QEMU so the exit trap can revoke the runner afterwards.
qemu-system-x86_64 \
  -enable-kvm \
  -cpu host \
  -smp "$VM_CPU" \
  -m "$VM_RAM" \
  -drive file=/dev/fd/3,if=virtio,format=qcow2 \
  -drive file=/dev/fd/4,format=raw,if=virtio,readonly=on \
  -device virtio-net-pci,netdev=vmnic \
  -netdev user,id=vmnic,hostfwd=tcp::22-:22 \
  -nographic \
  -snapshot &
QEMU_PID="$!"
wait "$QEMU_PID"
QEMU_PID=''
