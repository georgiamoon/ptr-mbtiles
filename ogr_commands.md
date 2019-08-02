## Commands

### data Prep

xsv select '!WKT' ptr_hops_2019.csv | \
  xsv stats | \
  xsv select type | \
  tail -n +2 | \
  sed 's/.*/"&"/' | \
  sed 's/Unicode/String/g' | \
  sed 's/Float/Real/g' | \
  tr '\n' , > ptr_hops_2019.csvt

  echo '"WKT"' >> ptr_hops_2019.csvt

_Output to mbtiles_
ogr2ogr -f GeoJSON /dev/stdout -oo KEEP_GEOM_COLUMNS=no ptr_hops_2019.csv | tippecanoe -o ptr_lines_2019.mbtiles -f -l ptr_lines /dev/stdin -z6 --simplification=10 --detect-shared-borders --coalesce-densest-as-needed

_Output to a directory_
ogr2ogr -f GeoJSON /dev/stdout -oo KEEP_GEOM_COLUMNS=no one_day_points_07252019.csv | tippecanoe -e one_day -f -l one_day /dev/stdin -z6 --simplification=10 --detect-shared-borders --coalesce-densest-as-needed

## UPLOADING to MAPBOX

mapbox upload --name 'PTR 2019' newamerica.ptr_lines_2019 ptr_lines_2019.mbtiles

## QUERIES

#standardSQL
```
SELECT
  test_id,
  log_time,
  connection_spec.client_ip as client_ip,
  APPROX_QUANTILES(8 * SAFE_DIVIDE(web100_log_entry.snap.HCThruOctetsAcked,
      (web100_log_entry.snap.SndLimTimeRwin +
        web100_log_entry.snap.SndLimTimeCwnd +
        web100_log_entry.snap.SndLimTimeSnd)), 101)[SAFE_ORDINAL(51)] AS download_Mbps,
  APPROX_QUANTILES(web100_log_entry.snap.MinRTT, 101)[SAFE_ORDINAL(51)] AS min_rtt,
  ST_GEOGPOINT(ANY_VALUE(connection_spec.client_geolocation.longitude),ANY_VALUE(connection_spec.client_geolocation.latitude)) as WKT
FROM
  `measurement-lab.ndt.downloads`
WHERE partition_date = '2019-07-25'
group by test_id, log_time, client_ip
```


