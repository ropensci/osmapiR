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
# : The comment text. The content type is "application/x-www-form-urlencoded".
#
### Error codes ----
# ; HTTP status code 400 (Bad Request)
# : if the text field was not present
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
