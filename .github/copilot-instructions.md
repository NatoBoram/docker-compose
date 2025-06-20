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
