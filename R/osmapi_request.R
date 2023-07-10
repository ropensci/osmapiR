osmapi_request <- function(authenticate = FALSE) {
  req <- httr2::request(base_url = get_osmapi_url())
  req <- httr2::req_url_path(req, "api", getOption("osmapir.api_version"))
  req <- httr2::req_retry(req, max_tries = 10L)
  req <- httr2::req_user_agent(req, string = "osmapiR (https://github.com/jmaspons/osmapiR)")

  if (authenticate & !getOption("osmapir.R_CMD_check", FALSE)) {
    req <- oauth_request(req)
  }

  return(req)
}
