function(response) {
  response <- httptest2::gsub_response(
    response,
    "https://api.openstreetmap.org/",
    "osm.org/",
    fixed = TRUE
  )

  response <- httptest2::gsub_response(
    response,
    "https://master.apis.dev.openstreetmap.org/",
    "osm.org/",
    fixed = TRUE
  )

  # xml
  response <- httptest2::gsub_response(
    response,
    'generator="CGImap ([0-9.]+) \\([0-9]+ .+\\.openstreetmap\\.org\\)" copyright="OpenStreetMap and contributors"',
    'generator="CGImap \\1 (012345 ******.openstreetmap.org)" copyright="OpenStreetMap and contributors"'
  )

  # json
  response <- httptest2::gsub_response(
    response,
    '"CGImap ([0-9.]+) \\([0-9]+ .+\\.openstreetmap\\.org\\)",',
    '"CGImap \\1 (012345 ******.openstreetmap.org)",'
  )

  # simplify = FALSE
  response <- httptest2::redact_headers(
    response,
    headers = c("x-request-id", "date", "x-amz-id-2", "x-amz-request-id")
  )

  return(response)
}
