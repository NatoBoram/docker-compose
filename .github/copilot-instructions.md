When creating a new `compose.yaml` file, it must be consistent with the style and structure of existing files.

Key conventions to follow:

1. Any service protected by Authentik must include `depends_on: - authentik-server`.

2. The keys within a service definition should be in alphabetical order.
   - `build`
   - `cap_add`
   - `command`
   - `container_name`
   - `depends_on`
   - `devices`
   - `entrypoint`
   - `env_file`
   - `environment`
   - `extends`
   - `group_add`
   - `healthcheck`
   - `hostname`
   - `image`
   - `networks`
   - `ports`
   - `restart`
   - `secrets`
   - `volumes`

3. All services must mount the host's timezone and localtime.

   ```yaml
   volumes:
     - /etc/localtime:/etc/localtime:ro
     - /etc/timezone:/etc/timezone:ro
   ```

4. Adhere to the patterns already present in the codebase. For example, if existing services use an implicit `:latest` tag for Docker images, continue to do so.

5. `ollama` is spelled with two "a". Do not misspell it as `olloma`.

6. Do not wrap the contents of this file in markdown code blocks like "```instructions".

7. Containers are named after their image. For example, `image: natoboram/potato` should have `container_name: potato`. An exception is made for services that are installed privately to other services. For example, if an instance of Redis is used exclusively by an instance of Send, then it'll be named `send-redis`.

8. Each service may have its own dedicated environment files, typically named `.env.${container_name}` and `.env.${container_name}.local`. The `.env.${container_name}` file lists all expected environment variables without their values, while the gitignored `.env.${container_name}.local` file contains the actual values. Crucially, do not share environment files between services, even if they are related. For example, a service like `nextcloud` and its database `nextcloud-postgres` must have separate environment files (`.env.nextcloud` and `.env.nextcloud-postgres`). The `environment` key in the compose file should only be used for public, non-changing values.

9. Services protected by Authentik must `depends_on: - authentik-server` and services behind Caddy must `depends_on: - caddy`.

10. A network is defined in the compose file of the service that needs to connect to another service. For example, for Caddy to connect to Send, the network `caddy-send` is defined in `caddy.compose.yaml`. The other service's compose file (`send.compose.yaml` in this case) must not redefine it with a top-level `networks:` block.

11. Internal networks connecting a service to a private dependency should be named `[service]-[dependency]`, mirroring the container naming convention. For example, the network connecting `taskcafe` to `taskcafe-postgres` should be named `taskcafe-postgres`, not the generic `taskcafe-db`.

12. When adding a new service `potato` that is exposed via Caddy, remember to:
    1. Add it to the `Caddyfile`.
    2. Define and use the `caddy-potato` network in `caddy.compose.yaml`.
    3. Use it (without re-declaring) it in `potato.compose.yaml`.
    4. Import `potato.compose.yaml` in the `compose.yaml` of that environment.

13. Persist data using named volumes, not bind mounts.

14. In Caddyfiles, the `{blocks.key}` syntax is valid for passing block arguments to an `import` statement. Do not suggest replacing it with `{args.N}`.

15. The project is organized into environments (`phantom`, `corsair`), each with its own set of `compose.yaml` files. A top-level `compose.yaml` in each environment aggregates the individual service files. When adding a new service, ensure it is included in the main `compose.yaml` for that environment.
