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

osm_comment_changeset_discussion <- function(changeset_id) {
  req <- osmapi_request()
  req <- httr2::req_method(req, "POST")
  req <- httr2::req_url_path_append(req, "changeset", changeset_id, "comment")

  resp <- httr2::req_perform(req)
  obj_xml <- httr2::resp_body_xml(resp)

  # cat(as.character(obj_xml))
  return(obj_xml)
}


## Subscribe: `POST /api/0.6/changeset/#id/subscribe` ----
#
# Subscribe to the discussion of a changeset to receive notifications for new comments.
#
# '''URL:''' <code>https://api.openstreetmap.org/api/0.6/changeset/#id/subscribe
# </code> ([https://api.openstreetmap.org/api/0.6/changeset/1000/subscribe example])<br />
# '''Return type:''' application/xml<br />
#
# This request needs to be done as an authenticated user.
#
### Error codes ----
# ; HTTP status code 409 (Conflict)
# : if the user is already subscribed to this changeset

osm_subscribe_changeset_discussion <- function(changeset_id) {
  req <- osmapi_request()
  req <- httr2::req_method(req, "POST")
  req <- httr2::req_url_path_append(req, "changeset", changeset_id, "subscribe")

  resp <- httr2::req_perform(req)
  obj_xml <- httr2::resp_body_xml(resp)

  # cat(as.character(obj_xml))
  return(obj_xml)
}


## Unsubscribe: `POST /api/0.6/changeset/#id/unsubscribe` ----
#
# Unsubscribe from the discussion of a changeset to stop receiving notifications.
#
# '''URL:''' <code>https://api.openstreetmap.org/api/0.6/changeset/#id/unsubscribe
# </code> ([https://api.openstreetmap.org/api/0.6/changeset/1000/unsubscribe example])<br />
# '''Return type:''' application/xml<br />
#
# This request needs to be done as an authenticated user.
#
### Error codes ----
# ; HTTP status code 404 (Not Found)
# : if the user is not subscribed to this changeset

osm_unsubscribe_changeset_discussion <- function(changeset_id) {
  req <- osmapi_request()
  req <- httr2::req_method(req, "POST")
  req <- httr2::req_url_path_append(req, "changeset", changeset_id, "unsubscribe")

  resp <- httr2::req_perform(req)
  obj_xml <- httr2::resp_body_xml(resp)

  # cat(as.character(obj_xml))
  return(obj_xml)
}


## Hide changeset comment: `POST /api/0.6/changeset/comment/#comment_id/hide` ----
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

osm_hide_comment_changeset_discussion <- function(comment_id) {
  req <- osmapi_request()
  req <- httr2::req_method(req, "POST")
  req <- httr2::req_url_path_append(req, "changeset", "comment", comment_id, "hide")

  resp <- httr2::req_perform(req)
  obj_xml <- httr2::resp_body_xml(resp)

  # cat(as.character(obj_xml))
  return(obj_xml)
}


## Unhide changeset comment: `POST /api/0.6/changeset/comment/#comment_id/unhide` ----
#
# Sets visible flag on changeset comment to true.
#
# '''URL:''' <code>https://api.openstreetmap.org/api/0.6/changeset/comment/#comment_id/unhide</code><br />
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

osm_unhide_comment_changeset_discussion <- function(comment_id) {
  req <- osmapi_request()
  req <- httr2::req_method(req, "POST")
  req <- httr2::req_url_path_append(req, "changeset", "comment", comment_id, "unhide")

  resp <- httr2::req_perform(req)
  obj_xml <- httr2::resp_body_xml(resp)

  # cat(as.character(obj_xml))
  return(obj_xml)
}
