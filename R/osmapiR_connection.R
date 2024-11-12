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
#' ori <- get_osmapi_url()
#' set_osmapi_connection(server = "testing")
#' get_osmapi_url()
#' set_osmapi_connection(server = "openstreetmap.org")
#' get_osmapi_url()
#'
#' ## Restore options
#' if (ori == "https://api.openstreetmap.org") {
#'   set_osmapi_connection(server = "openstreetmap.org")
#' } else if (ori == "https://master.apis.dev.openstreetmap.org") {
#'   set_osmapi_connection(server = "testing")
#' } else {
#'   warning(
#'     "A non standard osmapiR connection detected (", ori,
#'     "). If you configured manually options like \"osmapir.base_api_url\" or \"osmapir.oauth_id\", ",
#'     "configure it again."
#'   )
#' }
set_osmapi_connection <- function(server = c("openstreetmap.org", "testing"), cache_authentication) {
  server <- match.arg(server)

  if (missing(cache_authentication)) {
    cache_authentication <- getOption("osmapir.cache_authentication")
  }

  if (!cache_authentication && # cached authentication can keep multiple tokens ?httr2::req_oauth_auth_code / cache_key
    (
      (server == "openstreetmap.org" && getOption("osmapir.base_api_url") != "https://api.openstreetmap.org") ||
        (server == "testing" && getOption("osmapir.base_api_url") != "https://master.apis.dev.openstreetmap.org")
    )) {
    logout_osmapi() # no cached authentication and server change
  }

  if (server == "openstreetmap.org") {
    options(osmapir.base_api_url = "https://api.openstreetmap.org")
    options(osmapir.base_auth_url = "https://www.openstreetmap.org")
    options(osmapir.oauth_id = "kROTgNMsqmMNusvGXhuQlXBbNaUjSwkrGehdBMqE2jo")
    options(osmapir.oauth_secret = "VowQ59fpIRjZepLYkVpybvXBfVcZnCJNYUYLXeVxGLC1rLPVTb_oMEDe6px6ceSCH7Y-B57nvc8ilhc")
  } else if (server == "testing") {
    options(osmapir.base_api_url = "https://master.apis.dev.openstreetmap.org")
    options(osmapir.base_auth_url = "https://master.apis.dev.openstreetmap.org")
    options(osmapir.oauth_id = "Vpy5lyTqBl_iO1LKbAcjNxEbl2LDH9eyZynyh4VU6M4")
    options(osmapir.oauth_secret = "i8a4oQxyTmVDuRL4sTYvLCSzqWEr9fcPhw2A_0dZmglWhuYfMwEPrmadEEqBY0TjXc7Gg_b3YKuXPEI")
  }

  if (!missing(cache_authentication)) {
    options(osmapir.cache_authentication = cache_authentication)
  }
  ## TODO: persistent options ?tools::R_user_dir()

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


#' Authenticate or logout osmapiR
#'
#' Log in/out osmapiR.
#'
#' @details
#' All functions that require authentication will trigger the log in if the session is not yet authenticated, so calling
#' this function is not really needed. Use `authenticate_osmapi` to sign in before executing scripts that require
#' authentication to avoid interruptions.
#'
#' @return For `authenticate_osmapi`, print the user and permissions of the connection and return invisibly the display
#'   name of the logged user. `logout_osmapi` clear the OAuth2 token and can be useful to change user.
#' @family API functions
#' @rdname authenticate_osmapiR
#' @export
#'
#' @examples
#' \dontrun{
#' authenticate_osmapi()
#' logout_osmapi()
#' }
authenticate_osmapi <- function() {
  details <- osm_details_logged_user()
  display_name <- details$user["display_name"]

  perms <- osm_permissions()

  message(
    "Logged in at ", get_osmapi_url(), " as: ", display_name,
    "\nWith the following permissions:\n\t", paste(perms, collapse = ", ")
  )

  invisible(display_name)
}


#' Log out osmapiR
#'
#' @rdname authenticate_osmapiR
#' @export
logout_osmapi <- function() {
  httr2::oauth_cache_clear(
    client = oauth_client_osmapi(),
    cache_disk = getOption("osmapir.cache_authentication"),
    cache_key = getOption("osmapir.base_api_url")
  )

  message("Logged out from ", get_osmapi_url())

  invisible()
}
