# inspired by osmdata package

.onLoad <- function(libname, pkgname) { # nocov start
  # register S3 methods for a generic in a suggested package
  s3_register("sf::st_as_sf", "osmapi_map_notes")
  s3_register("sf::st_as_sf", "osmapi_changesets")
  s3_register("sf::st_as_sf", "osmapi_gps_track")
  s3_register("sf::st_as_sf", "osmapi_gpx")


  op <- options()

  if (!"osmapir.osmapir_version" %in% names(op)) {
    options(osmapir.osmapir_version = utils::packageVersion("osmapiR"))
  }

  if (!"osmapir.user_agent" %in% names(op)) {
    options(
      osmapir.user_agent = paste(
        "osmapiR", getOption("osmapir.osmapir_version"), "(https://github.com/ropensci/osmapiR)"
      )
    )
  }

  if (!"osmapir.base_api_url" %in% names(op)) {
    options(osmapir.base_api_url = "https://api.openstreetmap.org")
  }

  if (!"osmapir.base_auth_url" %in% names(op)) {
    options(osmapir.base_auth_url = "https://www.openstreetmap.org")
  }

  if (!"osmapir.oauth_id" %in% names(op)) {
    options(osmapir.oauth_id = "kROTgNMsqmMNusvGXhuQlXBbNaUjSwkrGehdBMqE2jo")
  }

  if (!"osmapir.oauth_secret" %in% names(op)) {
    options(osmapir.oauth_secret = "VowQ59fpIRjZepLYkVpybvXBfVcZnCJNYUYLXeVxGLC1rLPVTb_oMEDe6px6ceSCH7Y-B57nvc8ilhc")
  }

  if (!"osmapir.cache_authentication" %in% names(op)) {
    options(osmapir.cache_authentication = FALSE)
  }

  if (!"osmapir.api_version" %in% names(op)) {
    options(osmapir.api_version = "0.6")
  }

  if (!"osmapir.api_capabilities" %in% names(op)) {
    # api_capabilities <- osm_capabilities()
    # dput(api_capabilities["api"])
    ## Avoid a server request when loading the package but requires to update values
    api_capabilities <- list(
      api = list(
        version = c(minimum = "0.6", maximum = "0.6"),
        area = c(maximum = 0.25),
        note_area = c(maximum = 25),
        tracepoints = c(per_page = 5000L),
        waynodes = c(maximum = 2000L),
        relationmembers = c(maximum = 32000L),
        changesets = c(maximum_elements = 10000L, default_query_limit = 100L, maximum_query_limit = 100L),
        notes = c(default_query_limit = 100L, maximum_query_limit = 10000L),
        timeout = c(seconds = 300),
        status = c(database = "online", api = "online", gpx = "online")
      )
    )
    options(osmapir.api_capabilities = api_capabilities)
  }

  invisible()
} # nocov end


.onAttach <- function(libname, pkgname) {
  packageStartupMessage("Data (c) OpenStreetMap contributors, ODbL 1.0. https://www.openstreetmap.org/copyright")
}
