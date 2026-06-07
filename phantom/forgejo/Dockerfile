FROM ubuntu

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y --no-install-recommends \
	ca-certificates \
	cloud-image-utils \
	curl \
	jq \
	qemu-system-x86 \
	qemu-utils \
	&& rm -rf /var/lib/apt/lists/*

WORKDIR /vm

COPY vm.sh /vm.sh
RUN chmod +x /vm.sh
ENTRYPOINT ["/vm.sh"]
