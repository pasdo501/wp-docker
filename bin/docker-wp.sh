#!/usr/bin/env bash

# Simple wrapper script to call wp cli inside the docker container
cmd="wp --allow-root $*"
docker exec -i $(docker-compose ps -q wp) sh -c "$cmd"