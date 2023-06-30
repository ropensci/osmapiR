#' Configure connections from osmapiR
#'
#' Functions to configure the connections. Probably, you should only use `set_osmapi_connection`.
#'
#' @param server If `openstreetmap.org` (default), the API calls will be performed to the servers in production. If
#'   `testing`, the calls will be against <https://master.apis.dev.openstreetmap.org> without affecting the main OSM
#'    data.
#' @param cache_authentication If `TRUE`, the authentication token will be cached on disk. This reduces the number of
#'   times that you need to re-authenticate at the cost of storing access credentials on disk. Cached tokens are
#'   encrypted and automatically deleted 30 days after creation. If missing (default), no changes will be applied. On
#'   package load time, the option is set to `FALSE` if it's not yet set.
#'
#' @details
#' When testing your software against the API you should consider using <https://master.apis.dev.openstreetmap.org>
#' instead of the live-api (`set_osmapi_connection("testing")`). Your account for the live service is not in the same
#' database, so you probably need a new username and password for the test service; please visit that page in a browser
#' to sign up.
#'
#' `set_osmapi_url()` and `get_osmapi_url` only deal with the API base URL. On the other hand, `set_osmapi_connection`
#' also configure the authentication parameters needed for `PUT`, `POST` and `DELETE` calls.
#'
#' For further details, see <https://wiki.openstreetmap.org/wiki/API_v0.6>.
#'
#' @return
#' Configure `.Options[grep("^osmapir\\.[a-z]+_(?!secret$)", names(.Options), perl = TRUE)]` :) and return
#' `osmapir.base_api_url`.
#'
#' @family API functions
#' @rdname API_configuration
#' @export
#'
#' @examples
#' set_osmapi_connection(server = "testing")
set_osmapi_connection <- function(server = c("openstreetmap.org", "testing"), cache_authentication) {
  server <- match.arg(server)

  if (server == "openstreetmap.org") {
    options(osmapir.base_api_url = "https://api.openstreetmap.org")
    options(osmapir.base_auth_url = "https://www.openstreetmap.org")
    options(osmapir.oauth_id = "t5kHJqAo7HjRPTFY3jfabysEE0GqUECukGP2BFPlFMA")
    options(osmapir.oauth_secret = "wK2AGsWGO1BEXER0wMpPI8OLTAmk4RUcfAFUXF7VAZUTwcmHJLwDEX6cINWgt5f2FG0WjyFD7o-5Gvw")
  } else if (server == "testing") {
    options(osmapir.base_api_url = "https://master.apis.dev.openstreetmap.org")
    options(osmapir.base_auth_url = "https://master.apis.dev.openstreetmap.org")
    options(osmapir.oauth_id = "xMH6POI0E_9xU7P0mcUW5PubXiunYTnC_uvAy9E7S8s")
    options(osmapir.oauth_secret = "CPeZrFeAhjMQOj4rADsnDv0MekszVztJeJSNq9VORx-50gJcas041GzrpjyjWN0GNJM1b5pAQCXNyR4")
  }

  if (!missing(cache_authentication)) {
    options(osmapir.cache_authentication = cache_authentication)
  }
  ## TODO: persistent options

  invisible(getOption("osmapir.base_api_url"))
}


#' Get current OSM API URL
#'
#' @rdname API_configuration
#' @export
get_osmapi_url <- function() {
  op <- options()
  if (!"osmapir.base_api_url" %in% names(op)) {
    stop("OSM API url can not be retrieved")
  }

  return(options()$osmapir.base_api_url)
}


#' Set OSM API URL
#'
#' @param osmapi_url The desired API URL to send the calls.
#'
#' @rdname API_configuration
#' @export
set_osmapi_url <- function(osmapi_url) {
  # old_url <- get_osmapi_url()
  options(osmapir.base_api_url = osmapi_url)

  # st <- osmapi_status(quiet = TRUE)
  # if (!"available" %in% names(st)) {
  #   set_osmapi_url(old_url)
  #   stop("osmapi_url not valid")
  # }

  invisible(osmapi_url)
}
