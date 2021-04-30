#!/bin/bash

set -e

curl -XDELETE 'http://es-container:9200/elife_search?ignore_unavailable=true'

curl -XPUT 'http://es-container:9200/elife_search' -H 'Content-Type: application/json' -d`yq prefix mappings.yaml mappings --tojson`

elasticdump --input=es_data.json --output=http://es-container:9200/elife_search --type=data
