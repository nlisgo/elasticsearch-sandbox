#!/bin/bash

set -e

index=$1
data=$2

if [ -z "$index" ]; then
    >&2 echo 'Usage: ./es-setup.sh [INDEX] [DATA] (data file optional)'
    exit 1
fi

response=$(curl --write-out %{http_code} --silent --output /dev/null "$index")

if [ "$response" = '404' ]; then
    >&2 echo 'Creating index'

    curl -XPUT "$index" -H 'Content-Type: application/json' -d`yq prefix mappings.yaml mappings --tojson`

    if [ ! -z "$data" ] && [ -f "$data" ]; then
        >&2 echo 'Import data into index'
        elasticdump --input="$data" --output="$index" --type=data
    fi
else
    >&2 echo 'Index already exists'
fi
