osmapi_request <- function(authenticate = FALSE) {
  req <- httr2::request(base_url = get_osmapi_url())
  req <- httr2::req_url_path(req, "api", getOption("osmapir.api_version"))
  req <- httr2::req_retry(req, max_tries = 10L)
  req <- httr2::req_user_agent(req, string = "osmapiR (https://github.com/jmaspons/osmapiR)")
  req <- httr2::req_error(req, body = error_body)

  if (authenticate && !getOption("osmapir.R_CMD_check", FALSE)) {
    req <- oauth_request(req) # nocov
  }

  return(req)
}


error_body <- function(resp) {
  out <- switch(httr2::resp_content_type(resp),
    "text/plain" = httr2::resp_body_string(resp),
    "text/html" = parse_html_error(resp),
    httr2::resp_headers(resp)$status
  )

  return(out)
}

parse_html_error <- function(resp) {
  if (length(resp$body) == 0) {
    return(httr2::resp_headers(resp)$status)
  }
  html <- httr2::resp_body_html(resp)
  msg <- xml2::xml_children(xml2::xml_find_all(html, ".//div"))
  out <- xml2::xml_text(msg)

  return(out)
}
