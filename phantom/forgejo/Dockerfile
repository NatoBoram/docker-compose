FROM ubuntu

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y --no-install-recommends \
	ca-certificates \
	cloud-image-utils \
	curl \
	iptables \
	jq \
	qemu-system-x86 \
	qemu-utils \
	util-linux \
	&& rm -rf /var/lib/apt/lists/*

WORKDIR /vm

COPY vm.sh /vm.sh
COPY egress.sh /egress.sh
RUN chmod +x /vm.sh /egress.sh
ENTRYPOINT ["/egress.sh"]
CMD ["/vm.sh"]
