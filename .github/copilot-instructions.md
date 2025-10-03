# Copilot Instructions

This is a multi-environment Docker Compose homelab setup organized around reverse-proxy architecture with strong security layers.

## Project Architecture

The project follows a **modular, environment-based** structure where each top-level directory represents a physical machine:

- `phantom` - Current production homelab server
- `helion` - Decommissioned server (reference only)
- `corsair` - Secondary build machine
- `olea` - Cloud server

Each environment uses a **service-per-file** approach where the main `compose.yaml` includes individual service files like `jellyfin.compose.yaml`, `caddy.compose.yaml`, etc.

## Core Infrastructure Pattern

The homelab uses **layered security** with these core components:

1. **Caddy** as reverse proxy with automatic HTTPS (Porkbun DNS + Let's Encrypt)
2. **Anubis** for AI crawler protection on public services
3. **Authentik** for SSO authentication on internal services
4. **GeoIP blocking** restricting access to Québec/Ontario regions
5. **Fail2Ban** for intrusion prevention

## Service Configuration Conventions

### Compose Service Keys (Alphabetical Order)

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

### Mandatory Volume Mounts

All services must include timezone synchronization:

```yaml
volumes:
  - /etc/localtime:/etc/localtime:ro
  - /etc/timezone:/etc/timezone:ro
```

### Container Naming Convention

Containers are named after their primary image: `image: natoboram/potato` → `container_name: potato`.

Exception: Private dependencies use `service-dependency` format (e.g., `authentik-postgres`, `send-redis`).

### Environment File Pattern

Each service has **two** environment files:

- `.env.${container_name}` - Template with empty variables (committed to git)
- `.env.${container_name}.local` - Actual values (gitignored)

**Critical**: Never share environment files between services, even related ones. `nextcloud` and `nextcloud-postgres` must have separate env files.

### Network Architecture

- **Caddy networks**: Defined in `caddy.compose.yaml` as `caddy-servicename`
- **Internal networks**: Named `service-dependency` (e.g., `authentik-postgres`)
- Services consuming networks do **not** redeclare them in their own files

### Dependency Management

- Services behind Authentik: `depends_on: - authentik-server`
- Services behind Caddy: `depends_on: - caddy`
- Use **named volumes**, not bind mounts for persistence

## Adding New Services Workflow

When adding a service `potato` exposed via Caddy:

1. Create `potato.compose.yaml` with service definition
2. Add `caddy-potato` network to `caddy.compose.yaml`
3. Configure routing in `Caddyfile` with appropriate protection:

   ```Caddyfile
   @potato host potato.{$PORKBUN_DOMAIN}
   handle @potato {
       import maxmind_geolocation { allow_subdivisions QC }
       import authentik  # or import anubis for public services
       reverse_proxy potato:{$PORT}
   }
   ```

4. Include `potato.compose.yaml` in main environment `compose.yaml`
5. Create `.env.potato` template and `.env.potato.local` files

## Protection Patterns in Caddyfile

- **Public services**: `import anubis` (AI crawler protection only)
- **Internal services**: `import authentik` + geolocation
- **Admin services**: Authentik + strict geolocation to Québec only
- **API endpoints**: Basic auth or bearer tokens + geolocation

## Development Workflow

- **Linting**: `npm run lint` (Prettier + MarkdownLint)
- **Deployment**: Push to main branch triggers Watchtower update via webhook
- **Service Updates**: Watchtower handles automatic container updates
- **Log Access**: Dozzle provides web UI for container logs (Authentik protected)

## Common Patterns

- **Database services**: Always use Alpine images with health checks
- **Media services**: Mount shared volumes (e.g., `metube:/metube:ro` in Jellyfin)
- **Hardware access**: Use `devices:` and `group_add:` for GPU access (e.g., in Jellyfin)
- **Custom builds**: Place Dockerfiles in environment directory (`./jellyfin.Dockerfile`)

## Spelling: `ollama` (not `olloma`) - LLM service with two "a"s
