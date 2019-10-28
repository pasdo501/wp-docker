#!/usr/bin/env bash

# Simple wrapper script to call wp cli inside the docker container
cmd="su www-data -c 'wp $*' -s /bin/bash"
docker exec -i $(docker-compose ps -q wp) sh -c "$cmd"