# Forgejo

## `app.ini`

It's easier to view the `app.ini` file locally.

```sh
# Export
sudo cp /var/lib/docker/volumes/phantom_forgejo/_data/gitea/conf/app.ini ./forgejo/secrets/app.ini
sudo chown $USER:$USER -Rc ./forgejo/secrets/app.ini

# Import
sudo cp ./forgejo/secrets/app.ini /var/lib/docker/volumes/phantom_forgejo/_data/gitea/conf/app.ini
sudo chown git:git -Rc /var/lib/docker/volumes/phantom_forgejo/_data/gitea/conf/app.ini
```

## Setup SSH Passthrough

1. Create a user

   ```sh
   sudo adduser git
   ```

2. Set `USER_UID` and `USER_GID` in `.env.forgejo.local`

   ```sh
   echo "USER_UID=$(id -u git)" >> .env.forgejo.local
   echo "USER_GID=$(id -g git)" >> .env.forgejo.local
   ```

3. Generate an SSH key

   ```sh
   sudo -u git ssh-keygen -t ed25519 -C "Forgejo"
   sudo -u git cat /home/git/.ssh/id_ed25519.pub | sudo -u git tee -a /home/git/.ssh/authorized_keys
   sudo -u git chmod 600 /home/git/.ssh/authorized_keys
   ```

4. Setup `ssh-shell`

   ```sh
   cat <<"EOF" | sudo tee /home/git/ssh-shell
   #!/bin/bash
   shift
   SAFE_COMMAND=$(printf '%q' "$SSH_ORIGINAL_COMMAND")
   ssh -p 2222 -o StrictHostKeyChecking=no git@127.0.0.1 "SSH_ORIGINAL_COMMAND=$SAFE_COMMAND $@"
   EOF
   sudo chmod +x /home/git/ssh-shell
   sudo usermod -s /home/git/ssh-shell git
   ```

5. Fix ownership

   ```sh
   sudo chown git:git -Rc /home/git
   ```

## Runners

You'll need an administrator token to register ephemeral runners.

1. Create an administrator account and a token

   ```sh
   docker exec --user git forgejo forgejo admin user generate-access-token \
     --username forgejo-runner \
     --token-name ephemeral-runner-provisioning \
     --scopes write:admin \
     --raw
   ```

2. Save its value in `forgejo/secrets/FORGEJO_RUNNER_API_TOKEN`.
3. Register that account with Authentik
