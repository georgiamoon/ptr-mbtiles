# ptr-mbtiles


Build container:

    docker build -t ptr-mbtiles .

Generate input data:

    ./prep-geojson-input.sh

Generate tiles:

    docker run --net=host -w /data -v $PWD:/data -it ptr-mbtiles bash -c \
	   "cat geo.json | tippecanoe -e one_day -f -l one_day /dev/stdin -z6 \
	     --simplification=10 --detect-shared-borders \
         --coalesce-densest-as-needed --no-tile-compression"

Copy to GCS:

    gsutil -m -h 'Cache-Control:private, max-age=0, no-transform' \
	  cp -r one_day.html one_day gs://soltesz-mlab-sandbox/

NOTE: if the html and tiles are served from different domains we'll need to
apply a CORS policy to GCS.
