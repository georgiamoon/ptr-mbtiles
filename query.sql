SELECT
  COUNT(*) AS count,
  REGEXP_EXTRACT(connection_spec.server_hostname, "mlab[1-4].([a-z]{3}[0-9]{2}).*") AS site,
  CAST(APPROX_QUANTILES(8 * SAFE_DIVIDE(web100_log_entry.snap.HCThruOctetsAcked,
      (web100_log_entry.snap.SndLimTimeRwin +
        web100_log_entry.snap.SndLimTimeCwnd +
        web100_log_entry.snap.SndLimTimeSnd)), 101)[SAFE_ORDINAL(51)] * 1000 AS INT64) AS download_Mbps,
  APPROX_QUANTILES(web100_log_entry.snap.MinRTT, 101)[SAFE_ORDINAL(51)] AS min_rtt,
  CAST(connection_spec.client_geolocation.longitude * 1000 AS INT64) as longitude,
  CAST(connection_spec.client_geolocation.latitude * 1000 AS INT64) as latitude

FROM
  `measurement-lab.ndt.downloads`

WHERE partition_date = DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY)
  AND connection_spec.client_geolocation.longitude is not NULL
  AND connection_spec.client_geolocation.latitude is not NULL

GROUP BY
  site,
  connection_spec.client_geolocation.longitude,
  connection_spec.client_geolocation.latitude
