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

  response <- httptest2::gsub_response(
    response,
    'generator="CGImap 0.8.8 \\([0-9]+ .+.openstreetmap.org\\)" copyright="OpenStreetMap and contributors"',
    'generator="CGImap 0.8.8 (012345 ******.openstreetmap.org)" copyright="OpenStreetMap and contributors"'
  )

  return(response)
}
