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

5. Networks are named according to the pattern `<app_that_needs_access>-<app_accessed>`. For example, `caddy-authelia` means that Caddy needs to access Authelia.

6. Networks are only _declared_ in the compose file of the app that needs access. The app being accessed should only list the network under its `networks` key, but not declare it at the top level of its compose file.

7. Ollama is spelled with two "a". Do not misspell it as "olloma".
