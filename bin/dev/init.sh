#!/bin/sh

# -------------------------------------------------------------
# This file brings up the local development stack
# -------------------------------------------------------------

# Bring down any running containers and reset the Docker state
docker-compose down
docker rm charliemcgrady-db charliemcgrady-node-server
docker-compose rm -v

# Bring everything back up
docker-compose up -d

# Tail the logs
docker-compose logs -f
