osmapi_request <- function(authenticate = FALSE) {
  req <- httr2::request(base_url = get_osmapi_url())
  req <- httr2::req_url_path(req, "api", getOption("osmapir.api_version"))
  req <- httr2::req_retry(req, max_tries = 10L)
  req <- httr2::req_user_agent(req, string = getOption("osmapir.user_agent"))
  req <- httr2::req_error(req, body = error_body)

  if (authenticate && !getOption("osmapir.R_CMD_check", FALSE)) {
    req <- oauth_request(req) # nocov
  }

  return(req)
}


error_body <- function(resp) {
  if (!httr2::resp_has_body(resp)) {
    out <- httr2::resp_header(resp, "error") # only when there is a body in resp? Identical content than body
    if (is.null(out)) {
      out <- NULL
    }
  } else {
    out <- switch(httr2::resp_content_type(resp),
      "text/plain" = httr2::resp_body_string(resp),
      "text/html" = parse_html_error_body(resp),
      httr2::resp_header(resp, "error")
    )
  }

  return(out)
}

parse_html_error_body <- function(resp) {
  html <- httr2::resp_body_html(resp)
  msg <- xml2::xml_find_all(html, ".//p")
  out <- xml2::xml_text(msg)
  out <- c(
    out,
    paste(
      "Please, open an issue at `https://github.com/jmaspons/osmapiR/issues`",
      "and report a reproducible example and the output of `httr2::last_response()`."
    )
  )

  return(out)
}
