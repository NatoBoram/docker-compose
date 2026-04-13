---
applyTo: **/.env,**/.env.!(local),**/.env.*.!(local)
---

This file is meant to be committed and public. It documents the default values of environment variables that are prone to getting changed locally. It serves as a template for the secrets stored in `.env.local` files.

For environment variables that are not changing or not secrets, they should be directly put into the service's `compose.yaml`.

For example:

```yaml
services:
	authentik-server:
		env_file:
			- .env.authentik-server
			- .env.authentik-server.local
		environment:
			AUTHENTIK_POSTGRESQL__HOST: authentik-postgres
			AUTHENTIK_POSTGRESQL__NAME: authentik
			AUTHENTIK_POSTGRESQL__USER: authentik
```

```ini
AUTHENTIK_POSTGRESQL__PASSWORD=
AUTHENTIK_SECRET_KEY=
```

Each individual service should have its own `.env.*` files. Do not share `.env` files between services even if they have the same key and value.
