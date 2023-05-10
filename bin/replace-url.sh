#!/usr/bin/env bash

from=$1
to=$2


if [[ -z "$from" || -z "$to" ]]; then
    echo "USAGE: replace-url <from> <to>"
    exit 1;
fi


# Replace "From" with "To" using WP-CLI in wp container
cmd="su www-data -c 'wp search-replace \"$from\" \"$to\" --skip-columns=guid' -s /bin/bash"
docker-compose exec wp sh -c "$cmd"
