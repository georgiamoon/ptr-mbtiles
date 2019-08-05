#!/bin/bash

set -eux

# Run bq query with generous row limit.
cat query.sql | bq --project measurement-lab query --format=prettyjson \
    --nouse_legacy_sql --max_rows=4000000 > results.json

# NOTE: bq converts all types to strings, including ints and floats. Jsonnet
# does this conversion, but it is slow. ~4min. sjsonnet.jar is faster but
# harder to install.

# Get jsonnet and convert raw results to geojson.
go get -u github.com/google/go-jsonnet/cmd/jsonnet
time ${GOPATH}/bin/jsonnet -J . convert.jsonnet > geo.json
