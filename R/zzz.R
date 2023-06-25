# inspired by osmdata package

.onLoad <- function(libname, pkgname) {
  op <- options()

  if (!"osmapir.base_url" %in% names(op)) {
    options(osmapir.base_url = "https://api.openstreetmap.org/")
  }
  if (!"osmapir.api_version" %in% names(op)) {
    options(osmapir.api_version = "0.6")
  }
  invisible()
}


.onAttach <- function(libname, pkgname) {
  packageStartupMessage("Data (c) OpenStreetMap contributors, ODbL 1.0. https://www.openstreetmap.org/copyright")
}


#' get_osmapi_url
#'
#' Return the URL of the specified OSM API. Default is <https://api.openstreetmap.org/>.
#'
#' @return The OSM API URL
#'
#' @seealso [set_osmapi_url()]
#'
#' @family osmapi
#' @export
get_osmapi_url <- function() {
  op <- options()
  if (!"osmapir.base_url" %in% names(op)) {
    stop("OSM API url can not be retrieved")
  }
  options()$osmapir.base_url
}


#' set_osmapi_url
#'
#' Set the URL of the specified OSM API. By default `https://api.openstreetmap.org/`.
#' When testing your software against the API you should consider using `https://master.apis.dev.openstreetmap.org/`
#' instead of the live-api. Your account for the live service is not in the same database, so you probably need a new
#' username and password for the test service; please visit that page in a browser to sign up.
#'
#' For further details, see
#' <https://wiki.openstreetmap.org/wiki/API_v0.6>
#'
#' @param osmapi_url The desired API URL. By default, `https://api.openstreetmap.org`.
#'
#' @return The API URL
#'
#' @seealso [get_osmapi_url()]
#'
#' @family osmapi
#' @export
set_osmapi_url <- function(osmapi_url = "https://api.openstreetmap.org") {
  # old_url <- get_osmapi_url()
  options(osmapir.base_url = osmapi_url)

  # st <- osmapi_status(quiet = TRUE)
  # if (!"available" %in% names(st)) {
  #   set_osmapi_url(old_url)
  #   stop("osmapi_url not valid")
  # }

  invisible(osmapi_url)
}
