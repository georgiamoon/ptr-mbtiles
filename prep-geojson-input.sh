#!/bin/bash

set -eux

PROJECT=${1:?Please provide a GCP project for tile upload}

# Run bq query with generous row limit.
cat query.sql | bq --project measurement-lab query --format=prettyjson \
    --nouse_legacy_sql --max_rows=4000000 > results.json

# NOTE: bq converts all types to strings, including ints and floats. Jsonnet
# does this conversion, but it is slow. ~4min. sjsonnet.jar is faster but
# harder to install.

# Get jsonnet and convert raw results to geojson.
time ${GOPATH}/bin/jsonnet -J . convert.jsonnet > geo.json

cat geo.json | tippecanoe -e one_day -f -l one_day /dev/stdin -z6 \
  --simplification=10 --detect-shared-borders \
  --coalesce-densest-as-needed --no-tile-compression

gsutil -m -h 'Cache-Control:private, max-age=0, no-transform' \
  cp -r one_day.html one_day gs://soltesz-${PROJECT}/

# NOTE: if the html and tiles are served from different domains we'll need to
# apply a CORS policy to GCS.
