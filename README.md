# ptr-mbtiles


Build container:

    docker build -t ptr-mbtiles .

Generate input data:

    docker run -e PROJECT=mlab-sandbox -v $PWD:/mlab-tiles \
        -v ~/.config/gcloud:/root/.config/gcloud -it ptr-mbtiles \
        ./prep-geojson-input.sh mlab-sandbox

NOTE: if the html and tiles are served from different domains we'll need to
apply a CORS policy to GCS.

## CORS

NOTE: may not be needed if served from an iframe.

* create a GCS bucket for the tile data.
* set defacl on bucket:

  ```
  $ gsutil defacl set public-read gs://soltesz-mlab-sandbox/
  ```

* set cors policy on bucket, so requests evaluate `Access-Control-Allow-Origin`
  headers correctly.

  ```
  $ gsutil cors set cors.json  gs://soltesz-mlab-sandbox
  ```

  `cors.json` contains, a project-specific origin:
  ```
  [
    {
      "origin": ["http://localhost:4000", "https://grafana.mlab-sandbox.measurementlab.net"],
      "responseHeader": ["Content-Type"],
      "method": ["GET", "HEAD", "DELETE"],
      "maxAgeSeconds": 3600
    }
  ]
  ```
