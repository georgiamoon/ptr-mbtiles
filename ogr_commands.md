## Commands

### Prep

xsv select '!WKT' ptr_hops_2019.csv | \
  xsv stats | \
  xsv select type | \
  tail -n +2 | \
  sed 's/.*/"&"/' | \
  sed 's/Unicode/String/g' | \
  sed 's/Float/Real/g' | \
  tr '\n' , > ptr_hops_2019.csvt

  echo '"WKT"' >> ptr_hops_2019.csvt

ogr2ogr -f GeoJSON /dev/stdout -oo KEEP_GEOM_COLUMNS=no ptr_hops_2019.csv | tippecanoe -o ptr_lines_2019.mbtiles -f -l ptr_lines /dev/stdin -z6 --simplification=10 --detect-shared-borders --coalesce-densest-as-needed

## UPLOADING to MAPBOX

mapbox upload --name 'PTR 2019' newamerica.ptr_lines_2019 ptr_lines_2019.mbtiles
