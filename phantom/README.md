# Phantom

Phantom is my newest homelab server. It replaces Helion.

It's managed entirely via Docker Compose. It uses Caddy as a reverse proxy for its simplicity and it's protected by Anubis, Authentik and Fail2Ban. Some parts are open to the public, such as Kubo, Leanish and Send.

## Software

|                                                                              | Service                                                        | Protection           | About                                                                                                                |
| :--------------------------------------------------------------------------: | :------------------------------------------------------------- | :------------------- | :------------------------------------------------------------------------------------------------------------------- |
| <img alt="Anubis logo"       src="../logos/anubis.png"       width="48px" /> | [Anubis](https://github.com/TecharoHQ/anubis)                  |                      | Weighs the soul of incoming HTTP requests to stop AI crawlers                                                        |
| <img alt="Authentik logo"    src="../logos/authentik.png"    width="48px" /> | [Authentik](https://github.com/goauthentik/authentik)          | Geoblock             | The authentication glue you need                                                                                     |
| <img alt="Beszel logo"       src="../logos/beszel.png"       width="48px" /> | [Beszel](https://github.com/henrygd/beszel)                    | Authentik, Geoblock  | Lightweight server monitoring hub with historical data, docker stats and alerts                                      |
| <img alt="Caddy logo"        src="../logos/caddy.png"        width="48px" /> | [Caddy](https://github.com/caddyserver/caddy)                  |                      | Fast and extensible multi-platform HTTP/1-2-3 web server with automatic HTTPS                                        |
|                                                                              | [ClamAV](https://github.com/Cisco-Talos/clamav)                |                      | An open source antivirus engine for detecting trojans, viruses, malware & other malicious threats                    |
| <img alt="Dozzle logo"       src="../logos/dozzle.png"       width="48px" /> | [Dozzle](https://github.com/amir20/dozzle)                     | Authentik, Geoblock  | Realtime log viewer for containers                                                                                   |
|                                                                              | [GeoIP Update](https://github.com/maxmind/geoipupdate)         |                      | GeoIP update client                                                                                                  |
| <img alt="Glances logo"      src="../logos/glances.png"      width="48px" /> | [Glances](https://github.com/nicolargo/glances)                | Authentik, Geoblock  | Glances an eye on your system                                                                                        |
| <img alt="GoAccess logo"     src="../logos/goaccess.png"     width="48px" /> | [GoAccess](https://github.com/allinurl/goaccess)               | Authentik, Geoblock  | A real-time web log analyzer and interactive viewer that runs in a terminal in \*nix systems or through your browser |
| <img alt="Jellyfin logo"     src="../logos/jellyfin.png"     width="48px" /> | [Jellyfin](https://github.com/jellyfin/jellyfin)               | Authentik, Geoblock  | The free software media system                                                                                       |
| <img alt="Jellyfin Vue logo" src="../logos/jellyfin-vue.png" width="48px" /> | [Jellyfin Vue](https://github.com/jellyfin/jellyfin-vue)       | Anubis, Geoblock     | A modern web client for Jellyfin based on Vue                                                                        |
| <img alt="Kubo logo"         src="../logos/ipfs.png"         width="48px" /> | [Kubo](https://github.com/ipfs/kubo)                           |                      | An IPFS implementation in Go                                                                                         |
| <img alt="Kubo logo"         src="../logos/ipfs.png"         width="48px" /> | [Kubo RPC](https://github.com/ipfs/kubo)                       | Geoblock             | Kubo's RPC API                                                                                                       |
| <img alt="Leanish logo"      src="../logos/leanish.png"      width="48px" /> | [Leanish](https://github.com/NatoBoram/leanish)                | Anubis               | A lean-ish web client for Lemmy                                                                                      |
| <img alt="MeTube logo"       src="../logos/metube.png"       width="48px" /> | [MeTube](https://github.com/alexta69/metube)                   | Authentik, Geoblock  | Self-hosted YouTube downloader                                                                                       |
| <img alt="MySpeed logo"      src="../logos/myspeed.png"      width="48px" /> | [MySpeed](https://github.com/gnmyt/myspeed)                    | Authentik, Geoblock  | A speed test analysis software that shows your internet speed for up to 30 days                                      |
| <img alt="Nextcloud logo"    src="../logos/nextcloud.png"    width="48px" /> | [Nextcloud](https://github.com/nextcloud/server)               | Geoblock             | A safe home for all your data                                                                                        |
| <img alt="Ollama logo"       src="../logos/ollama.png"       width="48px" /> | [Ollama](https://github.com/ollama/ollama)                     | Basic Auth, Geoblock | Get up and running with large language models                                                                        |
| <img alt="qBittorrent logo"  src="../logos/qbittorrent.png"  width="48px" /> | [qBittorrent](https://github.com/qbittorrent/qBittorrent)      | Authentik, Geoblock  | A BitTorrent client                                                                                                  |
| <img alt="Send logo"         src="../logos/send.png"         width="48px" /> | [Send](https://gitlab.com/timvisee/send)                       | Anubis, Geoblock     | Simple, private file sharing                                                                                         |
| <img alt="Stirling PDF logo" src="../logos/stirling-pdf.png" width="48px" /> | [Stirling PDF](https://github.com/Stirling-Tools/Stirling-PDF) | Authentik, Geoblock  | #1 locally hosted web application that allows you to perform various operations on PDF files                         |
| <img alt="Syncthing logo"    src="../logos/syncthing.png"    width="48px" /> | [Syncthing](https://github.com/syncthing/syncthing)            | Authentik, Geoblock  | Open source continuous file synchronization                                                                          |
| <img alt="Uptime Kuma logo"  src="../logos/uptime-kuma.png"  width="48px" /> | [Uptime Kuma](https://github.com/louislam/uptime-kuma)         | Authentik, Geoblock  | A fancy self-hosted monitoring tool                                                                                  |
| <img alt="Watchtower logo"   src="../logos/watchtower.png"   width="48px" /> | [Watchtower](https://github.com/containrrr/watchtower)         | Geoblock             | A process for automating Docker container base image updates                                                         |

## Hardware

[PCPartPicker Part List](https://ca.pcpartpicker.com/list/VPDrt3)

| Type               | Item                                                                                                                                                                                                                 |
| :----------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **CPU**            | [AMD Ryzen 7 9800X3D 4.7 GHz 8-Core Processor](https://ca.pcpartpicker.com/product/fPyH99/amd-ryzen-7-9800x3d-47-ghz-8-core-processor-100-1000001084wof)                                                             |
| **CPU Cooler**     | [Noctua NH-D9L chromax.black 46.44 CFM CPU Cooler](https://ca.pcpartpicker.com/product/KQMMnQ/noctua-nh-d9l-chromaxblack-4644-cfm-cpu-cooler-nh-d9l-chromaxblack)                                                    |
| **Motherboard**    | [MSI MPG X670E CARBON WIFI ATX AM5 Motherboard](https://ca.pcpartpicker.com/product/rmbTwP/msi-mpg-x670e-carbon-wifi-atx-am5-motherboard-mpg-x670e-carbon-wifi)                                                      |
| **Memory**         | [Kingston FURY Beast 64 GB (2 x 32 GB) DDR5-4800 CL38 Memory](https://ca.pcpartpicker.com/product/7YxRsY/kingston-fury-beast-64-gb-2-x-32-gb-ddr5-4800-cl38-memory-kf548c38bbk2-64)                                  |
| **Memory**         | [Kingston FURY Beast 64 GB (2 x 32 GB) DDR5-4800 CL38 Memory](https://ca.pcpartpicker.com/product/7YxRsY/kingston-fury-beast-64-gb-2-x-32-gb-ddr5-4800-cl38-memory-kf548c38bbk2-64)                                  |
| **Storage**        | [Samsung 990 Pro 4 TB M.2-2280 PCIe 4.0 X4 NVME Solid State Drive](https://ca.pcpartpicker.com/product/RKYmP6/samsung-990-pro-4-tb-m2-2280-pcie-40-x4-nvme-solid-state-drive-mz-v9p4t0bw)                            |
| **Video Card**     | [Gigabyte GAMING OC Radeon RX 7700 XT 12 GB Video Card](https://ca.pcpartpicker.com/product/VTFmP6/gigabyte-gaming-oc-radeon-rx-7700-xt-12-gb-video-card-gv-r77xtgaming-oc-12gd)                                     |
| **Case**           | [Phanteks Enthoo Pro 2 Server Edition ATX Full Tower Case](https://ca.pcpartpicker.com/product/FQGhP6/phanteks-enthoo-pro-2-server-edition-atx-full-tower-case-ph-es620pc_bk02)                                      |
| **Power Supply**   | [Corsair HX1200i 1200 W 80+ Platinum Certified Fully Modular ATX Power Supply](https://ca.pcpartpicker.com/product/fGgrxr/corsair-hx1200i-1200-w-80-platinum-certified-fully-modular-atx-power-supply-cp-9020281-na) |
| **Case Fan**       | [Noctua S12A PWM chromax.black.swap 63.27 CFM 120 mm Fan](https://ca.pcpartpicker.com/product/CKFXsY/noctua-nf-s12a-pwm-chromaxblackswap-633-cfm-120mm-fan-nf-s12a-pwm-chromaxblackswap)                             |
| **Case Fan**       | [Noctua S12A PWM chromax.black.swap 63.27 CFM 120 mm Fan](https://ca.pcpartpicker.com/product/CKFXsY/noctua-nf-s12a-pwm-chromaxblackswap-633-cfm-120mm-fan-nf-s12a-pwm-chromaxblackswap)                             |
| **Case Fan**       | [Noctua S12A PWM chromax.black.swap 63.27 CFM 120 mm Fan](https://ca.pcpartpicker.com/product/CKFXsY/noctua-nf-s12a-pwm-chromaxblackswap-633-cfm-120mm-fan-nf-s12a-pwm-chromaxblackswap)                             |
| **Case Fan**       | [Noctua S12A PWM chromax.black.swap 63.27 CFM 120 mm Fan](https://ca.pcpartpicker.com/product/CKFXsY/noctua-nf-s12a-pwm-chromaxblackswap-633-cfm-120mm-fan-nf-s12a-pwm-chromaxblackswap)                             |
| **Case Fan**       | [Noctua S12A PWM chromax.black.swap 63.27 CFM 120 mm Fan](https://ca.pcpartpicker.com/product/CKFXsY/noctua-nf-s12a-pwm-chromaxblackswap-633-cfm-120mm-fan-nf-s12a-pwm-chromaxblackswap)                             |
| **Case Fan**       | [Noctua S12A PWM chromax.black.swap 63.27 CFM 120 mm Fan](https://ca.pcpartpicker.com/product/CKFXsY/noctua-nf-s12a-pwm-chromaxblackswap-633-cfm-120mm-fan-nf-s12a-pwm-chromaxblackswap)                             |
| **Case Fan**       | [Noctua S12A PWM chromax.black.swap 63.27 CFM 120 mm Fan](https://ca.pcpartpicker.com/product/CKFXsY/noctua-nf-s12a-pwm-chromaxblackswap-633-cfm-120mm-fan-nf-s12a-pwm-chromaxblackswap)                             |
| **Case Fan**       | [Noctua S12A PWM chromax.black.swap 63.27 CFM 120 mm Fan](https://ca.pcpartpicker.com/product/CKFXsY/noctua-nf-s12a-pwm-chromaxblackswap-633-cfm-120mm-fan-nf-s12a-pwm-chromaxblackswap)                             |
| **Case Fan**       | [Noctua A14 PWM chromax.black.swap 82.52 CFM 140 mm Fan](https://ca.pcpartpicker.com/product/sWM323/noctua-nf-a14-pwm-chromaxblackswap-825-cfm-140mm-fan-nf-a14-pwm-chromaxblackswap)                                |
| **Case Fan**       | [Noctua A14 PWM chromax.black.swap 82.52 CFM 140 mm Fan](https://ca.pcpartpicker.com/product/sWM323/noctua-nf-a14-pwm-chromaxblackswap-825-cfm-140mm-fan-nf-a14-pwm-chromaxblackswap)                                |
| **Case Fan**       | [Noctua A14 PWM chromax.black.swap 82.52 CFM 140 mm Fan](https://ca.pcpartpicker.com/product/sWM323/noctua-nf-a14-pwm-chromaxblackswap-825-cfm-140mm-fan-nf-a14-pwm-chromaxblackswap)                                |
| **Fan Controller** | [Noctua NA-FH1 Fan Controller](https://ca.pcpartpicker.com/product/mHYRsY/noctua-na-fh1-fan-controller-na-fh1)                                                                                                       |
| **Fan Controller** | [Noctua NA-FH1 Fan Controller](https://ca.pcpartpicker.com/product/mHYRsY/noctua-na-fh1-fan-controller-na-fh1)                                                                                                       |

## Configuration

### Kubo

Kubo's RPC API is exposed publicly. Before using it, protect it.

- <https://docs.ipfs.tech/how-to/kubo-rpc-tls-auth>

Example:

```json
{
	"API": {
		"Authorizations": {
			"api": {
				"AllowedPaths": ["/api/v0"],
				"AuthSecret": "bearer:17c5a864-4f38-4605-89e8-5e1a5a99a951"
			}
		},
		"HTTPHeaders": {
			"Access-Control-Allow-Credentials": ["true"],
			"Access-Control-Allow-Headers": ["*"],
			"Access-Control-Allow-Methods": [
				"GET",
				"POST",
				"PUT",
				"DELETE",
				"OPTIONS"
			],
			"Access-Control-Allow-Origin": [
				"https://rpc.kubo.example.org",
				"https://webui.ipfs.io"
			]
		}
	}
}
```

You can verify it works by using:

```sh
ipfs id --api /dns/rpc.kubo.example.org/tcp/443/https --api-auth bearer:17c5a864-4f38-4605-89e8-5e1a5a99a951
```

To connect to the IPFS Web UI at `https://rpc.kubo.example.org/webui`, use:

```json
{
	"url": "https://rpc.kubo.example.org",
	"headers": { "Authorization": "Bearer 17c5a864-4f38-4605-89e8-5e1a5a99a951" }
}
```

Enable the subdomain gateway:

```json
{
	"Gateway": {
		"PublicGateways": {
			"kubo.example.org": {
				"Paths": ["/ipfs", "/ipns"],
				"UseSubdomains": true
			}
		}
	}
}
```
