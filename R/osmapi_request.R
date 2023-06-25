osmapi_request <- function() {
  osmapi_url <- get_osmapi_url()
  req <- httr2::request(osmapi_url)
  req <- httr2::req_url_path(req, "api", getOption("osmapir.api_version"))
  req <- httr2::req_retry(req, max_tries = 10L)
  req <- httr2::req_user_agent(req, "osmapiR (https://github.com/jmaspons/osmapiR)")

  return(req)
}
