#!/bin/bash

set -e

host="$1"
shift
cmd="$@"


until $(curl --output /dev/null --silent --head --fail "$host"); do
    printf '.'
    sleep 1
done

# First wait for ES to start...
response='unresponsive'

until [ "$response" = '200' ]; do
    if [ "$response" != 'unresponsive' ]; then
        >&2 echo 'Elastic Search is unavailable - sleeping'
        sleep 1
    fi
    response=$(curl --write-out %{http_code} --silent --output /dev/null "$host")
done

# next wait for ES status to turn to Green or Yellow
health='unhealthy'

until [ "$health" = 'yellow' ] || [ "$health" = 'green' ]; do
    if [ "$health" != 'unhealthy' ]; then
        >&2 echo 'Elastic Search is unavailable - sleeping'
        sleep 1
    fi

    health="$(curl -fsSL "$host/_cat/health?h=status")"
    health="$(echo "$health" | sed -r 's/^[[:space:]]+|[[:space:]]+$//g')" # trim whitespace (otherwise we'll have "green ")    
done

>&2 echo 'Elastic Search is up'
exec $cmd
