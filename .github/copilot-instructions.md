# Copilot Instructions

Multi-environment Docker Compose homelab with reverse-proxy architecture and layered security.

## Architecture

Each top-level directory = physical machine:

- `phantom/` - Current production server (subdirectory structure)
- `helion/` - Decommissioned (flat `.compose.yaml` files, reference only)
- `corsair/` - Dev machine
- `olea/` - Cloud server

**Structure evolution**: `phantom/` uses service subdirectories (`jellyfin/compose.yaml`), while legacy `helion/` uses flat naming (`jellyfin.compose.yaml`). Main `compose.yaml` includes all services via `include:` directive.

## Security Layers

1. **Caddy** - Reverse proxy with automatic HTTPS (Porkbun DNS + Let's Encrypt)
2. **Anubis** - AI crawler protection (public services)
3. **Authentik** - SSO authentication (internal services)
4. **GeoIP blocking** - MaxMind geolocation (Québec/Ontario regions)
5. **Fail2Ban** - Intrusion prevention

## Service Configuration

### Compose Keys (Alphabetical)

```yaml
services:
  potato:
    build:
    cap_add:
    command:
    container_name:
    depends_on:
    devices:
    entrypoint:
    env_file:
    environment:
    extends:
    group_add:
    healthcheck:
    hostname:
    image:
    networks:
    ports:
    restart:
    secrets:
    volumes:
```

### Mandatory Patterns

**Timezone sync** (all services):

```yaml
volumes:
  - /etc/localtime:/etc/localtime:ro
  - /etc/timezone:/etc/timezone:ro
```

**Container naming**: Match primary image (`natoboram/potato` → `container_name: potato`)
**Exception**: Dependencies use `service-dependency` (e.g., `authentik-postgres`, `send-redis`)

### Environment Files

**Two files per service** (never shared):

- `.env.potato` - Template with all keys present (committed, empty values serve as documentation)
- `.env.potato.local` - Actual secrets (gitignored)

Example:

```yaml
env_file:
  - .env.potato
  - .env.potato.local
```

**Critical**:

- Even related services (e.g., `nextcloud` + `nextcloud-postgres`) have separate env files
- All keys must be present in `.env.potato` even if empty (e.g., `KEY=`) - this documents what's needed in `.local`

### Network Architecture

**Caddy networks**: Defined in `caddy/compose.yaml` as `caddy-servicename`, consumed by service compose files without redeclaration.

**Internal networks**: Named `service-dependency` (e.g., `authentik-postgres`, `authentik-redis`).

**Cross-service dependencies**: Use dedicated networks (e.g., `authentik-server` connects to multiple service-specific networks like `authentik-dozzle`, `authentik-metube`).

### Dependencies

```yaml
depends_on:
  - caddy # All exposed services
  - authentik-server # Protected services
  authentik-postgres: # With health checks
    condition: service_healthy
```

Use **named volumes**, not bind mounts for persistence (exception: main config files like `Caddyfile`).

## Adding New Service

For service `potato` exposed via Caddy:

1. **Create subdirectory** (phantom structure):

   ```log
   phantom/potato/
     ├── compose.yaml
     ├── .env.potato
     └── .env.potato.local
   ```

2. **Add network to `caddy/compose.yaml`**:

   ```yaml
   networks:
     caddy-potato:
   services:
     caddy:
       networks:
         - caddy-potato
   ```

3. **Configure routing in `Caddyfile`**:

   ```caddyfile
   @potato host potato.{$PORKBUN_DOMAIN}
   handle @potato {
       import maxmind_geolocation { allow_subdivisions QC }
       import authentik  # or: import anubis (public services)
       reverse_proxy potato:3000
   }
   ```

4. **Include in main `compose.yaml`**:

   ```yaml
   include:
     - path: potato/compose.yaml
   ```

5. **Create env files**: Template `.env.potato` + local `.env.potato.local`

### Protection Patterns

- **Public**: `import anubis` only (Kubo, Leanish, Send)
- **Internal**: `import authentik` + geolocation (Jellyfin, Dozzle, Glances)
- **Admin**: Authentik + strict geolocation `QC` only (Authentik itself, Dozzle)
- **APIs**: Basic auth + geolocation (Ollama, Kubo RPC)

## Development Workflow

**Linting**: `pnpm lint` (Prettier + MarkdownLint via `.prettierrc.yaml`)
**Format**: `pnpm format`

**Deployment**: Push to `main` → GitHub Actions calls Watchtower webhook → Watchtower pulls/restarts containers

**Reload Caddy**: `./reload_caddy.sh` (runs `docker compose exec caddy caddy reload`)

**Service structure comparison**:

- Legacy `helion/`: `include: - path: jellyfin.compose.yaml`
- Current `phantom/`: `include: - path: jellyfin/compose.yaml`

## Common Patterns

**Database health checks**:

```yaml
healthcheck:
  test: ["CMD-SHELL", "pg_isready -d $${POSTGRES_DB} -U $${POSTGRES_USER}"]
  interval: 30s
  timeout: 5s
  retries: 5
  start_period: 20s
```

**Shared media volumes**: Cross-mount with `:ro` (e.g., Jellyfin reads `metube:/metube:ro`, `qbittorrent-downloads:/qbittorrent`)

**Hardware access** (GPU transcoding):

```yaml
devices:
  - /dev/dri
  - /dev/kfd
group_add:
  - 110 # render
  - 44 # video
```

**Disable Watchtower auto-update** (locally-built images only):

```yaml
build:
  dockerfile: ./Dockerfile
labels:
  - com.centurylinklabs.watchtower.enable=false
```

Watchtower is disabled only for services with `build:` directive (e.g. Caddy with xcaddy extensions and Jellyfin). Public images are always auto-updated.

## Key Files

- `phantom/caddy/Caddyfile` - Routing rules and protection snippets
- `phantom/compose.yaml` - Service includes for production
- `phantom/README.md` - Service inventory with protection levels
- `.prettierrc.yaml` - Code style (tabs, no semicolons, avoid arrow parens)

## Spelling

`ollama` (not `olloma`) - Two "a"s
