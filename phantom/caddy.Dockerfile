FROM caddy:builder AS builder

RUN xcaddy build \
	--with github.com/caddy-dns/acmedns \
	--with github.com/caddy-dns/porkbun \
	--with github.com/mholt/caddy-dynamicdns \
	--with github.com/porech/caddy-maxmind-geolocation

FROM caddy:latest

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
