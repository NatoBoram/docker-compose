---
applyTo: **/compose.yaml,**/compose.override.yaml,**/*.compose.yaml
---

# Compose Instructions

## Compose Keys (Alphabetical Order)

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

## Mandatory Patterns

### Timezone Sync

**ALWAYS at the END of volumes list**:

```yaml
volumes:
  - potato-data:/data
  - potato-config:/config

  - /etc/localtime:/etc/localtime:ro
  - /etc/timezone:/etc/timezone:ro
```

### Container Naming

Match primary image: `natoboram/potato` → `container_name: potato`

**Exception**: Dependencies use `service-dependency` format (e.g., `authentik-postgres`, `send-redis`)

### Environment Files

**Two files per service** (never shared):

- `.env.potato` - Template with all keys present (committed, empty values serve as documentation)
- `.env.potato.local` - Actual secrets (gitignored)

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
  - anubis # Protected by Anubis
  - authentik-server # Protected by Authentik
```

### Volumes

Use **named volumes**, not bind mounts for persistence (exception: main config files like `Caddyfile`).

**Volume declarations**: Services only declare their own volumes. When mounting volumes from other services, do NOT redeclare them as `external: true` - Docker Compose automatically finds them.

```yaml
# ✅ Correct - only declare owned volumes
volumes:
  backrest-data:
  backrest-config:

# ❌ Wrong - don't redeclare external volumes
volumes:
  backrest-data:
  nextcloud-postgres:
    external: true
```

**Volume naming**: Use simple declarations without `name:` property unless required.

```yaml
# ✅ Correct
volumes:
  potato-data:

# ❌ Wrong - redundant name property
volumes:
  potato-data:
    name: potato-data
```

### Secrets

For sensitive files (certificates, tokens), use Docker Compose secrets:

```yaml
secrets:
  WATCHTOWER_HTTP_API_TOKEN:
    file: ./secrets/WATCHTOWER_HTTP_API_TOKEN

services:
  watchtower:
    environment:
      WATCHTOWER_HTTP_API_TOKEN: /run/secrets/WATCHTOWER_HTTP_API_TOKEN
    secrets:
      - WATCHTOWER_HTTP_API_TOKEN
```

Secrets are mounted at `/run/secrets/SECRET_NAME` inside containers.

## Common Patterns

### Database Health Checks (PostgreSQL)

```yaml
healthcheck:
  test: ["CMD-SHELL", "pg_isready -d $${POSTGRES_DB} -U $${POSTGRES_USER}"]
  interval: 30s
  timeout: 5s
  retries: 5
  start_period: 20s
```

### Shared Media Volumes

Cross-mount with `:ro` (e.g., Jellyfin reads `metube:/metube:ro`)

### Hardware Access (GPU transcoding)

```yaml
devices:
  - /dev/dri
  - /dev/kfd
group_add:
  - 110 # render
  - 44 # video
```

### Disable Watchtower Auto-Update

**Only for locally-built images**:

```yaml
build:
  dockerfile: ./Dockerfile
labels:
  - com.centurylinklabs.watchtower.enable=false
```

Watchtower is disabled only for services with `build:` directive (e.g. Caddy with xcaddy extensions and Jellyfin). Public images are always auto-updated. When the `:latest` tag is unavailable, then updates are handled by Dependabot.
