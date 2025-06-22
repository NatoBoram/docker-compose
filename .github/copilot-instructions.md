When creating a new `compose.yaml` file, it must be consistent with the style and structure of existing files.

Key conventions to follow:

1. Any service protected by Authentik must include `depends_on: - authentik-server`.

2. The keys within a service definition should be in alphabetical order.

   - `command`
   - `container_name`
   - `depends_on`
   - `image`
   - `networks`
   - `restart`
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

7. Containers are named after their image. For example, `image: techarohq/anubis` should have `container_name: anubis`. An exception is made for services that are installed privately to other services. For example, if an instance of Redis is used exclusively by an instance of Send, then it'll be named `send-redis`.

8. A service may have its own environment files named `.env.${container_name}` and `.env.${container_name}.local`. The `.env.${container_name}` file lists all the expected environment variables without their values, while the `.env.${container_name}.local` file, which is gitignored, contains the actual values. Do not share environment files between services. The `environment` key in the compose file should only be used for public, non-changing values.

9. Services protected by Authentik must `depends_on: - authentik-server` and services behind Caddy must `depends_on: - caddy`.
