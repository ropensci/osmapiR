# https://wiki.openstreetmap.org/wiki/OAuth
# https://github.com/openstreetmap/openstreetmap-website/issues/3494

oauth_client_osmapi <- function() {
  token_url <- httr2::req_url_path(
    req = httr2::request(base_url = getOption("osmapir.base_auth_url")),
    "oauth2", "token"
  )$url

  client <- httr2::oauth_client(
    id = getOption("osmapir.oauth_id"),
    token_url = token_url,
    secret = httr2::obfuscated(getOption("osmapir.oauth_secret")),
    auth = "header",
    name = "osmapiR"
  )

  return(client)
}


oauth_request <- function(req) {
  auth_url <- httr2::req_url_path(
    req = httr2::request(base_url = getOption("osmapir.base_auth_url")),
    "oauth2", "authorize"
  )$url

  scope <- c("read_prefs", "write_prefs", "write_api", "read_gpx", "write_gpx", "write_notes")
  # "write_diary" # (Supported scope by OAuth2 but is not required by the API v0.6)

  req <- httr2::req_oauth_auth_code(
    req = req,
    client = oauth_client_osmapi(),
    auth_url = auth_url,
    cache_disk = getOption("osmapir.cache_authentication"),
    cache_key = getOption("osmapir.base_api_url"),
    scope = paste(scope, collapse = " "),
    pkce = TRUE,
    redirect_uri = "http://127.0.0.1"
  )

  return(req)
}
