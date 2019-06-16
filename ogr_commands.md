## Commands

### Prep

xsv select '!WKT' results-20190616-022230.csv | \
  xsv stats | \
  xsv select type | \
  tail -n +2 | \
  sed 's/.*/"&"/' | \
  sed 's/Unicode/String/g' | \
  sed 's/Float/Real/g' | \
  tr '\n' , > results-20190616-022230.csvt

  echo '"WKT"' >> results-20190616-022230.csvt

ogr2ogr -f GeoJSON /dev/stdout -oo KEEP_GEOM_COLUMNS=no results-20190616-022230.csv | tippecanoe -o ptr_lines.mbtiles -f -l ptr_lines /dev/stdin -z6 --simplification=10 --detect-shared-borders --coalesce-densest-as-needed

## UPLOADING to MAPBOX

mapbox upload --name 'PTR Test' newamerica.ptr_lines ptr_lines.mbtiles
