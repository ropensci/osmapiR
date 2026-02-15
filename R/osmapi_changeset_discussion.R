## Changeset discussion
#
# Changeset discussions were added in November 2014 ([https://blog.openstreetmap.org/2014/11/02/introducing-changeset-discussions/ See blog])


## Comment: `POST /api/0.6/changeset/#id/comment` ----
#
# Add a comment to a changeset. The changeset must be closed.
#
# '''URL:''' <code>https://api.openstreetmap.org/api/0.6/changeset/#id/comment
# </code> ([https://api.openstreetmap.org/api/0.6/changeset/1000/comment example])<br />
# '''Return type:''' application/xml<br />
#
# This request needs to be done as an authenticated user.
#
### Parameters ----
# ; text
# : The comment text. The content type is `application/x-www-form-urlencoded`.
#
### Error codes ----
# ; HTTP status code 400 (Bad Request)
# : If the text field was not present
# ; HTTP status code 409 (Conflict)
# : The changeset is not closed
#
### Notes ----
# * requires either <code>write_api</code> or <code>write_changeset_comments</code> OAuth scope

#' Comment a changeset
#'
#' Add a comment to a changeset and subscribe to the discussion. The changeset must be closed. Requires authentication.
#'
#' @param changeset_id The id of the changeset to comment represented by a numeric or a character value.
#' @param comment The text of the comment to post.
#'
#' @note Requires either `write_api` or `write_changeset_comments` OAuth scope.
#'
#' @return Returns a data frame with the changeset (same format as [osm_get_changesets()] with `format = "R"`).
#' @family changeset discussion's functions
#' @export
#'
#' @examples
#' \dontrun{
#' set_osmapi_connection("testing") # use the testing server
#' changeset <- osm_get_changesets(300626)
#' updated_changeset <- osm_comment_changeset_discussion(
#'   changeset_id = changeset$id,
#'   comment = "A new comment to test osmapiR"
#' )
#' updated_changeset
#' }
osm_comment_changeset_discussion <- function(changeset_id, comment) { # TODO: , format = c("R", "xml", "json")
  req <- osmapi_request(authenticate = TRUE)
  req <- httr2::req_method(req, "POST")
  req <- httr2::req_url_path_append(req, "changeset", changeset_id, "comment")
  req <- httr2::req_body_form(req, text = comment)

  resp <- httr2::req_perform(req)
  obj_xml <- httr2::resp_body_xml(resp)

  out <- changeset_xml2DF(obj_xml)

  return(out)
}


## Subscribe: `POST /api/0.6/changeset/#id/subscription` ----
#
# Also available at `POST /api/0.6/changeset/#id/subscribe` (deprecated)
#
# Subscribe to the discussion of a changeset to receive notifications for new comments.
#
# '''URL:''' <code>https://api.openstreetmap.org/api/0.6/changeset/#id/subscription
# </code> ([https://api.openstreetmap.org/api/0.6/changeset/1000/subscription example])<br />
# '''Return type:''' application/xml<br />
#
# This request needs to be done as an authenticated user.
#
### Error codes ----
# ; HTTP status code 409 (Conflict)
# : if the user is already subscribed to this changeset

#' Subscribe or unsubscribe to a changeset discussion
#'
#' @describeIn osm_subscribe_changeset_discussion Subscribe to the discussion of a changeset to receive notifications
#'   for new comments.
#'
#' @param changeset_id The id of the changeset represented by a numeric or a character value.
#'
#' @return Returns the changeset information.
#' @family changeset discussion's functions
#' @export
#'
#' @examples
#' \dontrun{
#' # set_osmapi_connection(server = "openstreetmap.org")
#' osm_subscribe_changeset_discussion(137595351)
#' osm_unsubscribe_changeset_discussion("137595351")
#' }
osm_subscribe_changeset_discussion <- function(changeset_id) { # TODO: , format = c("R", "xml", "json")
  req <- osmapi_request(authenticate = TRUE)
  req <- httr2::req_method(req, "POST")
  req <- httr2::req_url_path_append(req, "changeset", changeset_id, "subscription")

  resp <- httr2::req_perform(req)
  obj_xml <- httr2::resp_body_xml(resp)

  out <- changeset_xml2DF(obj_xml)

  return(out)
}


## Unsubscribe: `DELETE /api/0.6/changeset/#id/subscription` ----
#
# Also available at `POST /api/0.6/changeset/#id/unsubscribe` (deprecated)
#
# Unsubscribe from the discussion of a changeset to stop receiving notifications.
#
# '''URL:''' <code>https://api.openstreetmap.org/api/0.6/changeset/#id/subscription
# </code> ([https://api.openstreetmap.org/api/0.6/changeset/1000/subscription example])<br />
# '''Return type:''' application/xml<br />
#
# This request needs to be done as an authenticated user.
#
### Error codes ----
# ; HTTP status code 404 (Not Found)
# : if the user is not subscribed to this changeset

#' @describeIn osm_subscribe_changeset_discussion Unsubscribe from the discussion of a changeset to stop receiving
#'   notifications.
#'
#' @export
osm_unsubscribe_changeset_discussion <- function(changeset_id) { # TODO: , format = c("R", "xml", "json")
  req <- osmapi_request(authenticate = TRUE)
  req <- httr2::req_method(req, "DELETE")
  req <- httr2::req_url_path_append(req, "changeset", changeset_id, "subscription")

  resp <- httr2::req_perform(req)
  obj_xml <- httr2::resp_body_xml(resp)

  out <- changeset_xml2DF(obj_xml)

  return(out)
}


## Search changeset comments: `GET /api/0.6/changeset_comments` ----
#
# Returns changeset comments that match the specified query. If no query is provided, the most recent changeset comments are returned.
#
# '''URL:''' <code>https://api.openstreetmap.org/api/0.6/changeset_comments
# </code>
### Parameters ----
# {| class="wikitable"
# |-
# !Parameter
# !Description
# !Allowed values
# !Default value
# |-
# |<code>display_name</code>
# | Search for changeset comments created by the given user.
# |String; User display name
# |none, optional parameter
# |-
# |<code>user</code>
# |Same as <code>display_name</code>, but search based on user id instead of display name. When both options are provided, <code>display_name</code> takes priority.
# |Integer; User id
# |none, optional parameter
# |-
# |<code>from</code>
# | Beginning date range.
# |Date; Preferably in [https://wikipedia.org/wiki/ISO_8601 ISO 8601] format
# |none, optional parameter
# |-
# |<code>to</code>
# |End date range. Only works when <code>from</code> is supplied.
# |Date; Preferably in [https://wikipedia.org/wiki/ISO_8601 ISO 8601] format
# |none, optional parameter
# |}
#
### Examples ----
# See the latest changeset comments globally:
#   https://api.openstreetmap.org/api/0.6/changeset_comments
# Search for changeset comments by a specific user:
#   https://api.openstreetmap.org/api/0.6/changeset_comments?display_name=Steve
# Search for changeset comments between January 1st and January 2nd, 2015:
#   https://www.openstreetmap.org/api/0.6/changeset_comments?from=2015-01-01&to=2015-01-02
### Error codes ----
# ;HTTP status code 400 (Bad Request)
# :When any of the limits are crossed

#' Search changeset comments
#'
#' Returns changeset comments that match the specified query. If no query is provided, the most recent changeset
#' comments are returned.
#'
#' @param user Search for changeset comments created by the user with the given user id (numeric) or display name
#'   (character).
#' @param from Beginning date range. See details for the valid formats.
#' @param to End date range. Only works when `from` is supplied. See details for the valid formats.
#' @param format Format of the output. Can be `"R"` (default), `"xml"`, or `"json"`.
#' @param tags_in_columns If `FALSE` (default), the tags of the changesets are saved in a single list column `tags`
#'   containing a `data.frame` for each changeset with the keys and values. If `TRUE`, add a column for each key.
#'   Ignored if `format != "R"`.
#'
#' @details
#' The valid formats for `from` and `to` parameters are [POSIXt] values or characters preferably in
#' [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format.
#'
#'
#' @returns
#' If `format = "R"`, returns a data frame with one comment per  If `format = "xml"`, returns a
#' [xml2::xml_document-class]. If `format = "json"`, returns a list with the json structure.
#'
#' @family changeset discussion's functions
#' @export
#'
#' @examples
#' # See the latest changeset comments globally:
#' osm_search_comment_changeset_discussion()
#'
#' # Search for changeset comments by a specific user:
#' osm_search_comment_changeset_discussion(user = "Steve", format = "json")
#'
#' # Search for changeset comments between January 1st and January 2nd, 2015:
#' osm_search_comment_changeset_discussion(from = "2015-01-01", to = "2015-01-02", format = "xml")
osm_search_comment_changeset_discussion <- function(user, from, to,
                                                    format = c("R", "xml", "json"), tags_in_columns = FALSE) {
  format <- match.arg(format)

  if (missing(user) || is.null(user)) {
    user <- NULL
    display_name <- NULL
  } else {
    if (is.numeric(user)) {
      display_name <- NULL
    } else {
      display_name <- user
      user <- NULL
    }
  }

  if (missing(from)) {
    from <- NULL
  } else if (inherits(from, "POSIXt")) {
    from <- format(from, "%Y-%m-%dT%H:%M:%SZ")
  }

  if (missing(to)) {
    to <- NULL
  } else if (inherits(to, "POSIXt")) {
    to <- format(to, "%Y-%m-%dT%H:%M:%SZ")
  }

  if (format == "json") {
    ext <- "changeset_comments.json"
  } else {
    ext <- "changeset_comments"
  }

  req <- osmapi_request()
  req <- httr2::req_method(req, "GET")
  req <- httr2::req_url_path_append(req, ext)
  req <- httr2::req_url_query(req, user = user, display_name = display_name, from = from, to = to)

  resp <- httr2::req_perform(req)

  if (format %in% c("R", "xml")) {
    out <- httr2::resp_body_xml(resp)
    if (format == "R") {
      out <- changeset_comments_xml2DF(out)
    }
  } else if (format %in% "json") {
    out <- httr2::resp_body_json(resp)
  }

  return(out)
}


## Hide changeset comment: `DELETE /api/0.6/changeset_comments/#id/visibility` ----
#
# Also available at `POST /api/0.6/changeset/comment/#comment_id/hide` (deprecated)
#
# Sets visible flag on changeset comment to false.
#
# '''URL:''' <code>https://api.openstreetmap.org/api/0.6/changeset/comment/#comment_id/hide</code><br />
# '''Return type:''' application/xml<br />
#
# This request needs to be done as an authenticated user with moderator role.
#
# Note that the changeset comment id differs from the changeset id.
#
### Error codes ----
# ; HTTP status code 403 (Forbidden)
# : if the user is not a moderator
# ; HTTP status code 404 (Not Found)
# : if the changeset comment id is unknown
#
### Notes ----
# * requires either <code>write_api</code> or <code>write_changeset_comments</code> OAuth scope

#' Hide or unhide a changeset comment
#'
#' This request needs to be done as an authenticated user with moderator role.
#'
#' @describeIn osm_hide_comment_changeset_discussion Sets visible flag on changeset comment to false.
#'
#' @param comment_id Note that the changeset comment id differs from the changeset id.
#'
#' @return Returns a data frame with the changeset (same format as [osm_get_changesets()] with `format = "R"`).
#' @family changeset discussion's functions
#' @family functions for moderators
#' @export
#'
#' @examples
#' \dontrun{
#' chdis <- osm_get_changesets("265646", include_discussion = TRUE)
#' hide_com <- osm_hide_comment_changeset_discussion(comment_id = chdis$discussion[[1]]$id[1])
#' unhide_com <- osm_unhide_comment_changeset_discussion(comment_id = chdis$discussion[[1]]$id[1])
#' }
osm_hide_comment_changeset_discussion <- function(comment_id) { # TODO: , format = c("R", "xml", "json")
  req <- osmapi_request(authenticate = TRUE)
  req <- httr2::req_method(req, "DELETE")
  req <- httr2::req_url_path_append(req, "changeset_comments", comment_id, "visibility")

  resp <- httr2::req_perform(req)
  obj_xml <- httr2::resp_body_xml(resp)

  out <- changeset_xml2DF(obj_xml)

  return(out)
}


## Unhide changeset comment: `POST /api/0.6/changeset_comments/#id/visibility` ----
#
# Also available at `POST /api/0.6/changeset/comment/#comment_id/unhide` (deprecated)
#
# Sets visible flag on changeset comment to true.
#
# '''URL:''' <code>https://api.openstreetmap.org/api/0.6/changeset_comments/#id/visibility</code><br />
# '''Return type:''' application/xml<br />
#
# This request needs to be done as an authenticated user with moderator role.
#
# Note that the changeset comment id differs from the changeset id.
#
### Error codes ----
# ; HTTP status code 403 (Forbidden)
# : if the user is not a moderator
# ; HTTP status code 404 (Not Found)
# : if the changeset comment id is unknown
#
### Notes ----
# * requires either <code>write_api</code> or <code>write_changeset_comments</code> OAuth scope

#' @describeIn osm_hide_comment_changeset_discussion Sets visible flag on changeset comment to true.
#' @export
osm_unhide_comment_changeset_discussion <- function(comment_id) { # TODO: , format = c("R", "xml", "json")
  req <- osmapi_request(authenticate = TRUE)
  req <- httr2::req_method(req, "POST")
  req <- httr2::req_url_path_append(req, "changeset_comments", comment_id, "visibility")

  resp <- httr2::req_perform(req)
  obj_xml <- httr2::resp_body_xml(resp)

  out <- changeset_xml2DF(obj_xml)

  return(out)
}
