# Docker Compose

[![Docker CI](https://github.com/NatoBoram/docker-compose/actions/workflows/docker.yaml/badge.svg)](https://github.com/NatoBoram/docker-compose/actions/workflows/docker.yaml) [![Node.js CI](https://github.com/NatoBoram/docker-compose/actions/workflows/node.js.yaml/badge.svg)](https://github.com/NatoBoram/docker-compose/actions/workflows/node.js.yaml) [![CodeQL](https://github.com/NatoBoram/docker-compose/actions/workflows/github-code-scanning/codeql/badge.svg)](https://github.com/NatoBoram/docker-compose/actions/workflows/github-code-scanning/codeql) [![Deploy](https://github.com/NatoBoram/docker-compose/actions/workflows/deploy.yaml/badge.svg)](https://github.com/NatoBoram/docker-compose/actions/workflows/deploy.yaml) [![Wakapi](https://wakapi.dev/api/badge/NatoBoram/interval:any/project:docker-compose)](https://wakapi.dev/summary?interval=any&project=docker-compose)

My personal homelab setup using Docker Compose.

To get started with your own homelab, take an hour to watch [Christian Lempa](https://youtube.com/@christianlempa)'s videos on Docker:

- <https://www.youtube.com/playlist?list=PLhXpdPiinNzm08YNXkQnGSjgSq1g1dDiI>

Docker volumes are at `/var/lib/docker/volumes`.

The `daemon.json` file goes at `/etc/docker/daemon.json`.

## Usage

Top-level folders represent a different machine in which Docker Compose is used to manage containers.

The machines are:

- [Corsair](./corsair) (dev machine)
- [Helion](./helion) (decommissioned)
- [Olea](./olea) (cloud server)
- [Phantom](./phantom) (current)

Each folder contains a `compose.yaml` that orchestrates the services running on that machine. The `compose.yaml` file loads services at `${service}/compose.yaml` and may expect overrides at `compose.override.yaml`. You'll have to read service definitions to see what needs to be overridden.

Each service has its own `.env.${service}` file. This is a template that contains all environment variables and their defaults for that service, with empty values serving as documentation. Copy that file to `.env.${service}.local` and fill in the actual values. The service compose files expect the `.env.${service}.local` file to exist and won't start without it.
