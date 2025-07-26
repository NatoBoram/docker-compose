# Docker Compose

[![Docker CI](https://github.com/NatoBoram/docker-compose/actions/workflows/docker.yaml/badge.svg)](https://github.com/NatoBoram/docker-compose/actions/workflows/docker.yaml) [![Node.js CI](https://github.com/NatoBoram/docker-compose/actions/workflows/node.js.yaml/badge.svg)](https://github.com/NatoBoram/docker-compose/actions/workflows/node.js.yaml) [![Deploy](https://github.com/NatoBoram/docker-compose/actions/workflows/deploy.yaml/badge.svg)](https://github.com/NatoBoram/docker-compose/actions/workflows/deploy.yaml) [![Wakapi](https://wakapi.dev/api/badge/NatoBoram/interval:any/project:docker-compose)](https://wakapi.dev/summary?interval=any&project=docker-compose)

My personal homelab setup using Docker Compose.

To get started with your own homelab, take an hour to watch [Christian Lempa](https://youtube.com/@christianlempa)'s videos on Docker:

- <https://www.youtube.com/playlist?list=PLhXpdPiinNzm08YNXkQnGSjgSq1g1dDiI>

## Usage

Top-level folders represent a different machine in which Docker Compose is used to manage containers.

The machines are:

- [Helion](./helion) (decomissioned)
- [Olea](./olea) (cloud server)
- [Phantom](./phantom) (current)

Each folder contains a `compose.yaml` that orchestrates the services running on that machine. The `compose.yaml` file loads services at `compose.${service}.yaml` and may expect overrides at `compose.override.yaml`. You'll have to read service definitions to see what needs to be overridden.

Each service has its own `.env.${service}` file. This is a template that contains default environment variables for that service that are expected to be modified. Copy that file to `.env.${service}.local` and override the defaults. The `compose.${service}.yaml` files will expect the `.env.${service}.local` file to exist and won't start without it.
