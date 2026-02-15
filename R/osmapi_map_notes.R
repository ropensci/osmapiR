## Map Notes API
#
# This provides access to the [[notes]] feature, which allows users to add geo-referenced textual "post-it" notes. This feature was not originally in the API 0.6 and was only added later ( 04/23/2013 in commit 0c8ad2f86edefed72052b402742cadedb0d674d9 ). As this was intended as a compatible replacement for the [[OpenStreetBugs]] API there are numerous idiosyncrasies relative to how the other parts of the OSM API work.


## Retrieving notes data by bounding box: `GET /api/0.6/notes` ----
#
# TODO: executable JavaScript (format `js`) not implemented in the server? https://github.com/openstreetmap/openstreetmap-website/blob/512f7de4a95b0522bcb26ac03cc31e1a91521662/app/controllers/api/notes_controller.rb#L47
# Returns the existing notes in the specified bounding box. The notes will be ordered by the date of their last change, the most recent one will be first. The list of notes can be returned in several different forms (e.g. as executable JavaScript, XML, RSS, json and GPX) depending on the file extension.
#
# '''Note:''' the XML format returned by the API is different from the, equally undocumented, format used for "osn" format files, available from [https://planet.openstreetmap.org/notes/ planet.openstreetmap.org], and as output from JOSM and Vespucci.
#
# '''URL:''' <code>https://api.openstreetmap.org/api/0.6/notes?bbox=''left'',''bottom'',''right'',''top''
# </code> ([https://api.openstreetmap.org/api/0.6/notes?bbox=-0.65094,51.312159,0.374908,51.669148 example])<br />
# '''Return type:''' application/xml <br />
#
# {| class="wikitable"
# |-
# ! Parameter
# ! Description
# ! Allowed values
# ! Default value
# |-
# | <code>bbox</code>
# | Coordinates for the area to retrieve the notes from
# | Floating point numbers in degrees, expressing a valid bounding box, not larger than the configured size limit, 25 square degrees{{efn| see [[API_v0.6#Capabilities:_GET_/api/capabilities| capabilities]] and [https://github.com/openstreetmap/openstreetmap-website/blob/master/config/settings.yml#L27 this line in settings] for the current value}}, not overlapping the dateline.
# | none, parameter required
# |-
# | <code>limit</code>
# | Specifies the number of entries returned at max
# | A value of between 1 and 10000 {{efn|name=limit| may change, see [[API_v0.6#Capabilities:_GET_/api/capabilities| capabilities]] for current value}} is valid
# | 100 is the default
# |-
# | <code>closed</code>
# | Specifies the number of days a note needs to be closed to no longer be returned
# | A value of 0 means only open notes are returned. A value of -1 means all notes are returned.
# | 7 is the default
# |}
#
# You can specify the format you want the results returned as by specifying a file extension. E.g. [https://api.openstreetmap.org/api/0.6/notes.json?bbox=-0.65094,51.312159,0.374908,51.669148 example] to get results in json. Currently the format RSS, XML, json and gpx are supported.
#
# The comment properties [uid, user, user_url] will be omitted if the comment was anonymous.
#
### Response XML ----
#  GET /api/0.6/notes
# <syntaxhighlight lang="xml">
# <?xml version="1.0" encoding="UTF-8"?>
# <osm version="0.6" generator="OpenStreetMap server" copyright="OpenStreetMap and contributors" attribution="https://www.openstreetmap.org/copyright" license="https://opendatacommons.org/licenses/odbl/1-0/">
#   <note lon="0.1000000" lat="51.0000000">
#     <id>16659</id>
#     <url>https://master.apis.dev.openstreetmap.org/api/0.6/notes/16659</url>
#     <comment_url>https://master.apis.dev.openstreetmap.org/api/0.6/notes/16659/comment</comment_url>
#     <close_url>https://master.apis.dev.openstreetmap.org/api/0.6/notes/16659/close</close_url>
#     <date_created>2019-06-15 08:26:04 UTC</date_created>
#     <status>open</status>
#     <comments>
#       <comment>
#         <date>2019-06-15 08:26:04 UTC</date>
#         <uid>1234</uid>
#         <user>userName</user>
#         <user_url>https://master.apis.dev.openstreetmap.org/user/userName</user_url>
#         <action>opened</action>
#         <text>ThisIsANote</text>
#         <html>&lt;p&gt;ThisIsANote&lt;/p&gt;</html>
#       </comment>
#       ...
#     </comments>
#   </note>
#   ...
# </osm>
# </syntaxhighlight>
#
### Response JSON ----
#  GET /api/0.6/notes.json
# <syntaxhighlight lang="json">
# {
#   "type": "FeatureCollection",
#   "features": [
#     {
#       "type": "Feature",
#       "geometry": {"type": "Point", "coordinates": [0.1000000, 51.0000000]},
#       "properties": {
#         "id": 16659,
#         "url": "https://master.apis.dev.openstreetmap.org/api/0.6/notes/16659.json",
#         "comment_url": "https://master.apis.dev.openstreetmap.org/api/0.6/notes/16659/comment.json",
#         "close_url": "https://master.apis.dev.openstreetmap.org/api/0.6/notes/16659/close.json",
#         "date_created": "2019-06-15 08:26:04 UTC",
#         "status": "open",
#         "comments": [
#          {"date": "2019-06-15 08:26:04 UTC", "uid": 1234, "user": "userName", "user_url": "https://master.apis.dev.openstreetmap.org/user/userName", "action": "opened", "text": "ThisIsANote", "html": "<p>ThisIsANote</p>"},
#          ...
#         ]
#       }
#     }
#   ]
# }
# </syntaxhighlight>
#
### Error codes ----
# ; HTTP status code 400 (Bad Request)
# : When any of the limits are crossed

#' Retrieve notes by bounding box
#'
#' Returns the existing notes in the specified bounding box. The notes will be ordered by the date of their last change,
#' the most recent one will be first.
#'
#' @param bbox Coordinates for the area to retrieve the notes from (`left,bottom,right,top`). Floating point numbers in
#'   degrees, expressing a valid bounding box, not larger than the configured size limit, 25 square degrees, not
#'   overlapping the dateline. It can be specified by a character, matrix, vector, `bbox` object from \pkg{sf}, a
#'   `SpatExtent` from \pkg{terra}. Unnamed vectors and matrices will be sorted appropriately and must merely be in the
#'   order (`x`, `y`, `x`, `y`) or `x` in the first column and `y` in the second column.
#' @param limit Specifies the number of entries returned at max. A value between 1 and 10000 is valid. Default to 100.
#' @param closed Specifies the number of days a note needs to be closed to no longer be returned. A value of 0 means
#'   only open notes are returned. A value of -1 means all notes are returned. Default to 7.
#' @param format Format of the output. Can be `"R"` (default), `"sf"` `"xml"`, `"rss"`, `"json"` or `"gpx"`.
#'
#' @note The comment properties (`uid`, `user`, `user_url`) will be omitted if the comment was anonymous.
#'
#' @return
#' If `format = "R"`, returns a data frame with one map note per row. If `format = "sf"`, returns a `sf` object from
#' \pkg{sf}.
#'
#' ## `format = "xml"`
#'
#' Returns a [xml2::xml_document-class] with the following format:
#' ``` xml
#' <?xml version="1.0" encoding="UTF-8"?>
#' <osm version="0.6" generator="OpenStreetMap server" copyright="OpenStreetMap and contributors" attribution="https://www.openstreetmap.org/copyright" license="https://opendatacommons.org/licenses/odbl/1-0/">
#'   <note lon="0.1000000" lat="51.0000000">
#'     <id>16659</id>
#'     <url>https://master.apis.dev.openstreetmap.org/api/0.6/notes/16659</url>
#'     <comment_url>https://master.apis.dev.openstreetmap.org/api/0.6/notes/16659/comment</comment_url>
#'     <close_url>https://master.apis.dev.openstreetmap.org/api/0.6/notes/16659/close</close_url>
#'     <date_created>2019-06-15 08:26:04 UTC</date_created>
#'     <status>open</status>
#'     <comments>
#'       <comment>
#'         <date>2019-06-15 08:26:04 UTC</date>
#'         <uid>1234</uid>
#'         <user>userName</user>
#'         <user_url>https://master.apis.dev.openstreetmap.org/user/userName</user_url>
#'         <action>opened</action>
#'         <text>ThisIsANote</text>
#'         <html>&lt;p&gt;ThisIsANote&lt;/p&gt;</html>
#'       </comment>
#'       ...
#'     </comments>
#'   </note>
#'   ...
#' </osm>
#' ```
#'
#' ## `format = "json"`
#'
#' Returns a list with the following json structure:
#' ``` json
#' {
#'   "type": "FeatureCollection",
#'   "features": [
#'     {
#'       "type": "Feature",
#'       "geometry": {"type": "Point", "coordinates": [0.1000000, 51.0000000]},
#'       "properties": {
#'         "id": 16659,
#'         "url": "https://master.apis.dev.openstreetmap.org/api/0.6/notes/16659.json",
#'         "comment_url": "https://master.apis.dev.openstreetmap.org/api/0.6/notes/16659/comment.json",
#'         "close_url": "https://master.apis.dev.openstreetmap.org/api/0.6/notes/16659/close.json",
#'         "date_created": "2019-06-15 08:26:04 UTC",
#'         "status": "open",
#'         "comments": [
#'           {"date": "2019-06-15 08:26:04 UTC", "uid": 1234, "user": "userName", "user_url": "https://master.apis.dev.openstreetmap.org/user/userName", "action": "opened", "text": "ThisIsANote", "html": "<p>ThisIsANote</p>"},
#'           ...
#'         ]
#'       }
#'     }
#'   ]
#' }
#' ```
#'
#' ## `format = "rss"` & `format = "gpx"`
#' For `format` in `"rss"`, and `"gpx"`, a [xml2::xml_document-class] with the corresponding format.
#'
#' @family get notes' functions
#' @export
#'
#' @examples
#' notes <- osm_read_bbox_notes(bbox = c(3.7854767, 39.7837403, 4.3347931, 40.1011851), limit = 10)
#' ## bbox as a character value also works (bbox = "3.7854767,39.7837403,4.3347931,40.1011851").
#' notes
osm_read_bbox_notes <- function(bbox, limit = 100, closed = 7, format = c("R", "sf", "xml", "rss", "json", "gpx")) {
  format <- match.arg(format)

  if (format == "sf" && !requireNamespace("sf", quietly = TRUE)) {
    stop("Missing `sf` package. Install with:\n\tinstall.package(\"sf\")")
  }

  if (format %in% c("R", "sf")) {
    ext <- "notes.xml"
  } else {
    ext <- paste0("notes.", format)
  }

  req <- osmapi_request()
  req <- httr2::req_method(req, "GET")
  req <- httr2::req_url_path_append(req, ext)
  req <- httr2::req_url_query(req, bbox = bbox_to_string(bbox), limit = limit, closed = closed)

  resp <- httr2::req_perform(req)

  if (format %in% c("R", "sf", "xml", "gpx", "rss")) {
    out <- httr2::resp_body_xml(resp)
    if (format == "R") {
      out <- note_xml2DF(out)
    } else if (format == "sf") {
      out <- sf::st_as_sf(x = note_xml2DF(out))
    }
  } else if (format == "json") {
    out <- httr2::resp_body_json(resp)
  }

  return(out)
}


## Read: `GET /api/0.6/notes/#id` ----
#
# Returns the existing note with the given ID. The output can be in several formats (e.g. XML, RSS, json or GPX) depending on the file extension.
#
# '''URL:''' <code>https://api.openstreetmap.org/api/0.6/notes/#id</code> ([https://api.openstreetmap.org/api/0.6/notes/100 xml], [https://api.openstreetmap.org/api/0.6/notes/100.json json])<br />
# '''Return type:''' application/xml <br />
#
### Error codes ----
# ; HTTP status code 404 (Not Found)
# : When no note with the given id could be found. This should only be returned for not yet existing notes.

#' Read notes
#'
#' Returns the existing note with the given ID.
#'
#' @param note_id Note id represented by a numeric or a character value.
#' @param format Format of the output. Can be `"R"` (default), `"xml"`, `"rss"`, `"json"` or `"gpx"`.
#'
#' @return
#' If `format = "R"`, returns a data frame with one map note per row. If `format = "json"`, returns a list with the json
#' structure. For `format` in `"xml"`, `"rss"`, and `"gpx"`, a [xml2::xml_document-class] with the corresponding format.
# @family get notes' functions
#' @noRd
#'
#' @examples
#' note <- .osm_read_note(note_id = "2067786")
#' note
.osm_read_note <- function(note_id, format = c("R", "xml", "rss", "json", "gpx")) {
  format <- match.arg(format)

  if (format == "R") {
    note_id <- paste0(note_id, ".xml")
  } else {
    note_id <- paste0(note_id, ".", format)
  }

  req <- osmapi_request()
  req <- httr2::req_method(req, "GET")
  req <- httr2::req_url_path_append(req, "notes", note_id)

  resp <- httr2::req_perform(req)

  if (format %in% c("R", "xml", "gpx", "rss")) {
    out <- httr2::resp_body_xml(resp)
    if (format == "R") {
      out <- note_xml2DF(out)
    }
  } else if (format %in% "json") {
    out <- httr2::resp_body_json(resp)
  }

  return(out)
}


## Create a new note: `POST /api/0.6/notes` ----
#
### XML ----
#
# '''URL:''' <code>https://api.openstreetmap.org/api/0.6/notes?lat=51.00&lon=0.1&text=ThisIsANote</code>
# (''use Postman or similar tools to test the endpoint - note that it must be a POST request'')<br />
# '''Return type:''' application/xml
#
# An XML-file with the details of the note will be returned
#
### JSON ----
#
# '''URL:''' <code>https://api.openstreetmap.org/api/0.6/notes.json</code> <br />
# '''Body content''': <code>{"lat":51.00, "lon": 0.1&, "text":"This is a note\n\nThis is another line"}</code> <br />
# '''Return type:''' application/json
#
# A JSON-file with the details of the note will be returned
#
### Parameters ----
#
# {| class="wikitable"
# |-
# ! Parameter
# ! Description
# ! Allowed values
# ! Default value
# |-
# | <code>lat</code>
# | Specifies the latitude of the note
# | floatingpoint number in degrees
# | No default, needs to be specified
# |-
# | <code>lon</code>
# | Specifies the longitude of the note
# | floatingpoint number in degrees
# | No default, needs to be specified
# |-
# | <code>text</code>
# | A text field with arbitrary text containing the note
# |
# | No default, needs to be present
# |}
#
# If the request is made as an authenticated user, the note is associated to that user account. If the OAuth access token used does not have the `allow_write_notes` permission, it is created as an anonymous note instead.
#
### Error codes ----
# ; HTTP status code 400 (Bad Request)
# : if the text field was not present
# ; HTTP status code 404 (Not found)
# : This applies, if the request is not a HTTP POST request
# ; <s>HTTP status code 405 (Method Not Allowed)</s>
# : <s>If the request is not a HTTP POST request</s>

#' Create a new note
#'
#' @param lat Specifies the latitude in decimal degrees of the note.
#' @param lon Specifies the longitude in decimal degrees of the note.
#' @param text A text field with arbitrary text containing the note.
#' @param authenticate If `TRUE` (default), the note is authored by the logged user. Otherwise, anonymous note.
#'
#' @details
#' If the request is made as an authenticated user, the note is associated to that user account. If the OAuth access
#' token used does not have the `allow_write_notes` permission, it is created as an anonymous note instead.
#'
#' @return Returns a data frame with the map note (same format as [osm_get_notes()] with `format = "R"`).
#' @family edit notes' functions
#' @export
#'
#' @examples
#' \dontrun{
#' set_osmapi_connection("testing") # use the testing server
#' new_note <- osm_create_note(lat = 41.38373, lon = 2.18233, text = "Testing osmapiR")
#' new_note
#' }
osm_create_note <- function(lat, lon, text, authenticate = TRUE) { # TODO: , format = c("R", "sf", "xml", "json")
  req <- osmapi_request(authenticate = authenticate)
  req <- httr2::req_method(req, "POST")
  req <- httr2::req_url_path_append(req, "notes")
  req <- httr2::req_url_query(req, lat = lat, lon = lon, text = text)

  resp <- httr2::req_perform(req)
  obj_xml <- httr2::resp_body_xml(resp)

  out <- note_xml2DF(obj_xml)

  return(out)
}


## Create a new comment: `POST /api/0.6/notes/#id/comment` ----
#
# Add a new comment to note #id
#
# '''URL:''' <code>https://api.openstreetmap.org/api/0.6/notes/#id/comment?text=ThisIsANoteComment
# </code> (''use Postman or similar tools to test the endpoint - note that it must be a POST request'')<br />
# '''Return type:''' application/xml
#
# Since 28 August 2019, this request needs to be done as an authenticated user.
#
# The response will contain the XML of note.
#
# {| class="wikitable"
# |-
# ! Parameter
# ! Description
# ! Allowed values
# ! Default value
# |-
# | <code>text</code>
# | The comment
# | A text field with arbitrary text
# | No default, needs to be present
# |}
#
### Error codes ----
# ; HTTP status code 400 (Bad Request)
# : if the text field was not present
# ; HTTP status code 404 (Not found)
# : if no note with that id is not available. This should only happen for not yet existing notes.
# : This also applies, if the request is not a HTTP POST request
# ; <s>HTTP status code 405 (Method Not Allowed)</s>
# : <s>If the request is not a HTTP POST request</s>
# ; HTTP status code 409 (Conflict)
# : When the note is closed
# ; HTTP status code 410 (Gone)
# : When the note has been hidden by a moderator. Note that the error message "The note with the id nnnnnnnnn has already been deleted" is misleading, as it isn't actually possible for non-moderators to delete (hide) Notes via the API.

#' Create a new comment in a note
#'
#' Add a new comment to an existing note. Requires authentication.
#'
#' @param note_id Note id represented by a numeric or a character value.
#' @param text The comment as arbitrary text.
#'
#' @return Returns a data frame with the map note and the new comment (same format as [osm_get_notes()] with
#'   `format = "R"`).
#' @family edit notes' functions
#' @export
#'
#' @examples
#' \dontrun{
#' set_osmapi_connection("testing") # use the testing server
#' note <- osm_get_notes(53726)
#' updated_note <- osm_create_comment_note(note$id, text = "A new comment to the note")
#' updated_note
#' }
osm_create_comment_note <- function(note_id, text) { # TODO: , format = c("R", "sf", "xml", "json")
  req <- osmapi_request(authenticate = TRUE)
  req <- httr2::req_method(req, "POST")
  req <- httr2::req_url_path_append(req, "notes", note_id, "comment")
  req <- httr2::req_url_query(req, text = text)

  resp <- httr2::req_perform(req)
  obj_xml <- httr2::resp_body_xml(resp)

  out <- note_xml2DF(obj_xml)

  return(out)
}


## Close: `POST /api/0.6/notes/#id/close` ----
#
# Close a note as fixed.
#
# '''URL:''' <code>https://api.openstreetmap.org/api/0.6/notes/#id/close?text=Comment</code> (''use Postman or similar tools to test the endpoint - note that it must be a POST request'')<br />
# '''Return type:''' application/xml<br />
#
# This request needs to be done as an authenticated user.
#
### Error codes ----
# ; HTTP status code 404 (Not Found)
# : When no note with the given id could be found. This should only happen for not yet existing notes.
# : This also applies, if the request is not a HTTP POST request
# ; <s>HTTP status code 405 (Method Not Allowed)</s>
# : <s>If the request is not a HTTP POST request</s>
# ; HTTP status code 409 (Conflict)
# : When closing an already closed note
# ; HTTP status code 410 (Gone)
# : When the note has been hidden by a moderator. Note that the error message "The note with the id nnnnnnnnn has already been deleted" is misleading, as it isn't actually possible for a non-moderator to delete/hide Notes via the API.

#' Close or reopen a note
#'
#' Requires authentication.
#'
#' @describeIn osm_close_note Close a note as fixed.
#'
#' @param note_id Note id represented by a numeric or a character value.
#'
#' @return Returns a data frame with the closed map note (same format as [osm_get_notes()] with `format = "R"`).
# @family edit notes' functions
#' @noRd
#'
#' @examples
#' \dontrun{
#' set_osmapi_connection("testing") # use the testing server
#' note <- osm_create_note(lat = 41.38373, lon = 2.18233, text = "Testing osmapiR")
#' closed_note <- osm_close_note(note$id)
#' closed_note
#' reopened_note <- osm_reopen_note(note$id)
#' reopened_note
#' }
.osm_close_note <- function(note_id) { # TODO: , format = c("R", "xml", "json")
  req <- osmapi_request(authenticate = TRUE)
  req <- httr2::req_method(req, "POST")
  req <- httr2::req_url_path_append(req, "notes", note_id, "close")

  resp <- httr2::req_perform(req)
  obj_xml <- httr2::resp_body_xml(resp)

  out <- note_xml2DF(obj_xml)

  return(out)
}


## Reopen: `POST /api/0.6/notes/#id/reopen` ----
#
# Reopen a closed note.
#
# '''URL:''' <code>https://api.openstreetmap.org/api/0.6/notes/#id/reopen?text=Comment</code> (''use Postman or similar tools to test the endpoint'')<br />
# '''Return type:''' application/xml<br />
#
# This request needs to be done as an authenticated user.
#
### Error codes ----
# ; HTTP status code 404 (Not Found)
# : When no note with the given id could be found
# : This also applies, if the request is not a HTTP POST request
# ; <s>HTTP status code 405 (Method Not Allowed)</s>
# : <s>If the request is not a HTTP POST request</s>
# ; HTTP status code 409 (Conflict)
# : When reopening an already open note
# ; HTTP status code 410 (Gone)
# : When reopening a deleted note

#' @describeIn osm_close_note Reopen a closed note.
#'
#' @noRd
.osm_reopen_note <- function(note_id) { # TODO: , format = c("R", "xml", "json")
  req <- osmapi_request(authenticate = TRUE)
  req <- httr2::req_method(req, "POST")
  req <- httr2::req_url_path_append(req, "notes", note_id, "reopen")

  resp <- httr2::req_perform(req)
  obj_xml <- httr2::resp_body_xml(resp)

  out <- note_xml2DF(obj_xml)

  return(out)
}


## Hide: `DELETE /api/0.6/notes/#id` ----
#
# Hide (delete) a note.
#
# '''URL:''' <code>https://api.openstreetmap.org/api/0.6/notes/#id?text=Comment</code> (''use Postman or similar tools to test the endpoint'')<br />
# '''Return type:''' application/xml<br />
#
# This request needs to be done as an authenticated user with moderator role.
#
# Use ''Reopen'' request to make the note visible again.
#
### Error codes ----
# ; HTTP status code 403 (Forbidden)
# : if the user is not a moderator
# ; HTTP status code 404 (Not Found)
# : When no note with the given id could be found
# ; HTTP status code 410 (Gone)
# : When hiding a note that is already hidden

#' Delete a note
#'
#' Hide (delete) a note. This request needs to be done as an authenticated user with moderator role.
#'
#' @param note_id Note id represented by a numeric or a character value.
#' @param text A non-mandatory comment as text.
#'
#' @details Use [osm_reopen_note()] to make the note visible again.
#'
#' @return Returns a data frame with the hided map note (same format as [osm_get_notes()] with `format = "R"`).
# @family edit notes' functions
# @family functions for moderators
#' @noRd
#'
#' @examples
#' \dontrun{
#' set_osmapi_connection("testing") # use the testing server
#' note <- osm_create_note(lat = "40.7327375", lon = "0.1702526", text = "Test note to delete.")
#' del_note <- osm_delete_note(note_id = note$id, text = "Hide note")
#' del_note
#' }
.osm_delete_note <- function(note_id, text) { # TODO: , format = c("R", "xml", "json")
  req <- osmapi_request(authenticate = TRUE)
  req <- httr2::req_method(req, "DELETE")
  req <- httr2::req_url_path_append(req, "notes", note_id)
  if (!missing(text)) {
    req <- httr2::req_url_query(req, text = text)
  }

  resp <- httr2::req_perform(req)
  obj_xml <- httr2::resp_body_xml(resp)

  out <- note_xml2DF(obj_xml)

  return(out)
}


## Subscribe: `POST /api/0.6/notes/#id/subscription` ----
#
# Subscribe to the discussion of a note to receive notifications for new comments.
#
# '''URL:''' <code>https://api.openstreetmap.org/api/0.6/notes/:id/subscription</code><br />
# '''Return type:''' (empty response)<br />
#
# This request needs to be done as an authenticated user.
#
### Error codes ----
# ; HTTP status code 404 (Not Found)
# : if the note doesn't exist
# ; HTTP status code 409 (Conflict)
# : if the user is already subscribed to this note

#' Subscribe or unsubscribe to a note
#'
#' @describeIn osm_subscribe_note Subscribe to the discussion of a note to receive notifications
#'   for new comments.
#'
#' @param note_id The id of the note represented by a numeric or a character value.
#'
#' @return Returns nothing.
#' @family subscription to notes' functions
#' @export
#'
#' @examples
#' \dontrun{
#' # set_osmapi_connection(server = "openstreetmap.org")
#' osm_subscribe_note(2067786)
#' osm_unsubscribe_note("2067786")
#' }
osm_subscribe_note <- function(note_id) {
  req <- osmapi_request(authenticate = TRUE)
  req <- httr2::req_method(req, "POST")
  req <- httr2::req_url_path_append(req, "notes", note_id, "subscription")

  resp <- httr2::req_perform(req)

  invisible()
}


## Unsubscribe: `DELETE /api/0.6/notes/#id/subscription` ----
#
# Unsubscribe to the discussion of a note.
#
# '''URL:''' <code>https://api.openstreetmap.org/api/0.6/notes/:id/subscription</code><br />
# '''Return type:''' (empty response)<br />
#
# This request needs to be done as an authenticated user.
#
### Error codes ----
# ; HTTP status code 404 (Not Found)
# : if the note doesn't exist or the user is not subscribed to this note

#' @describeIn osm_subscribe_note Unsubscribe from the discussion of a note to stop receiving notifications for new
#'   comments.
#'
#' @export
osm_unsubscribe_note <- function(note_id) { # TODO: , format = c("R", "xml", "json")
  req <- osmapi_request(authenticate = TRUE)
  req <- httr2::req_method(req, "DELETE")
  req <- httr2::req_url_path_append(req, "notes", note_id, "subscription")

  resp <- httr2::req_perform(req)

  invisible()
}


## Search for notes: `GET /api/0.6/notes/search` ----
#
# Returns notes that match the specified query. If no query is provided, the most recently updated notes are returned.
#
# The result can be encoded in several different formats (XML, RSS, JSON, or GPX), depending on the file extension provided.
#
# '''URL:''' <code>https://api.openstreetmap.org/api/0.6/notes/search
#
# {| class="wikitable"
# |-
# ! Parameter
# ! Description
# ! Allowed values
# ! Default value
# |-
# | <code>q</code>
# | Text search query, matching either note text or comments.
# | String
# | none, optional parameter
# |-
# | <code>limit</code>
# | Maximum number of results.
# | Integer between 1 and 10000{{efn|name=limit| may change, see [[API_v0.6#Capabilities:_GET_/api/capabilities| capabilities]] for the current value}}
# | 100{{efn|name=limit}}
# |-
# | <code>closed</code>
# | Maximum number of days a note has been closed for.
# | Number; Value of 0 returns only open notes, Negative numbers return all notes
# | 7
# |-
# |<code>display_name</code>
# | Search for notes which the given user interacted with.
# | String; User display name
# | none, optional parameter
# |-
# |<code>user</code>
# | Same as <code>display_name</code>, but search based on user id instead of display name. When both options are provided, <code>display_name</code> takes priority.
# | Integer; User id
# | none, optional parameter
# |-
# |<code>bbox</code>
# | Search area.
# | [[API_v0.6#Retrieving_notes_data_by_bounding_box:_GET_/api/0.6/notes|Bounding box]]; Area of at most 25 square degrees{{efn| see [[API_v0.6#Capabilities:_GET_/api/capabilities| capabilities]] and [https://github.com/openstreetmap/openstreetmap-website/blob/master/config/settings.yml#L27 this line in settings] for the current value}}
# | none, optional parameter
# |-
# |<code>from</code>
# | Beginning date range for <code>created_at</code> or <code>updated_at</code> (specified by <code>sort</code>).
# | Date; Preferably in [https://wikipedia.org/wiki/ISO_8601 ISO 8601] format
# | none, optional parameter
# |-
# |<code>to</code>
# | End date range for <code>created_at</code> or <code>updated_at</code> (specified by <code>sort</code>). Only works when <code>from</code> is supplied.
# | Date; Preferably in [https://wikipedia.org/wiki/ISO_8601 ISO 8601] format
# | none, optional parameter
# |-
# |<code>sort</code>
# | Sort results by creation or update date.
# | <code>created_at</code> or <code>updated_at</code>
# | <code>created_at</code>
# |-
# |<code>order</code>
# | Sorting order. <code>oldest</code> is ascending order, <code>newest</code> is descending order.
# | <code>oldest</code> or <code>newest</code>
# | <code>newest</code>
# |}
#
### Examples ----
# See latest note updates globally:
#   https://api.openstreetmap.org/api/0.6/notes/search
# Search for a text in comments:
#   https://api.openstreetmap.org/api/0.6/notes/search?q=business%20spam
# See notes of a single user:
#   https://api.openstreetmap.org/api/0.6/notes/search?user=123
# Search for oldest notes near Null Island:
#   https://api.openstreetmap.org/api/0.6/notes/search?bbox=-1%2C-1%2C1%2C1&sort=created_at&order=oldest&closed=-1&limit=20
#
### Error codes ----
# ; HTTP status code 400 (Bad Request)
# : When any of the limits are crossed

#' Search for notes
#'
#' Returns notes that match the specified query. If no query is provided, the most recently updated notes are returned.
#'
#' @param q Text search query, matching either note text or comments.
#' @param user Search for notes which the given user interacted with. The value can be the user id (`numeric`) or the
#'   display name (`character`).
#' @param bbox Search area expressed as a string or a numeric vector of 4 coordinates of a valid bounding box
#'   (`left,bottom,right,top`) in decimal degrees. It can be specified by a character, matrix, vector, `bbox` object
#'   from \pkg{sf}, a `SpatExtent` from \pkg{terra}. Unnamed vectors and matrices will be sorted appropriately and must
#'   merely be in the order (`x`, `y`, `x`, `y`) or `x` in the first column and `y` in the second column. Area must be
#'   at most 25 square degrees (see `osm_capabilities()$note_area` and
#'   [this line in settings](https://github.com/openstreetmap/openstreetmap-website/blob/master/config/settings.yml#L27)
#'   for the current value).
#' @param from Beginning date range for `created_at` or `updated_at` (specified by `sort`). Preferably in
#'   [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) date format.
#' @param to End date range for `created_at` or `updated_at` (specified by `sort`). Preferably in
#'   [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) date format. Only works when `from` is supplied.
#' @param closed Specifies the number of days a note needs to be closed to no longer be returned. A value of 0 means
#'   only open notes are returned. A value of -1 means all notes are returned. 7 is the default.
#' @param sort Sort results by creation (`"created_at"`, the default) or update date (`"updated_at"`).
#' @param order Sorting order. `"oldest"` is ascending order, `"newest"` is descending order (the default).
#' @param limit Maximum number of results between 1 and 10000 (may change, see `osm_capabilities()$api$notes` for the
#'   current value). Default to 100.
#' @param format Format of the the returned list of notes. Can be `"R"` (default), `"sf"`, `"xml"`, `"rss"`, `"json"` or
#'   `"gpx"`.
#'
#' @details
#' The notes will be ordered by the date of their last change, the most recent one will be first.
#'
#' @return
#' If `format = "R"`, returns a data frame with one map note per row. If `format = "sf"`, returns a `sf` object from
#' \pkg{sf}. If `format = "json"`, returns a list with the json structure. For `format` in `"xml"`, `"rss"`, and
#' `"gpx"`, a [xml2::xml_document-class] with the corresponding format.
#' @family get notes' functions
#' @export
#'
#' @examples
#' notes <- osm_search_notes(
#'   q = "POI", bbox = "0.1594133,40.5229822,3.3222508,42.8615226",
#'   from = "2017-10-01", to = "2018-10-27T15:27A", limit = 10
#' )
#' notes
#'
#' my_notes <- osm_search_notes(
#'   user = "jmaspons", bbox = c(-0.1594133, 40.5229822, 3.322251, 42.861523),
#'   closed = -1, format = "json"
#' )
#' my_notes
osm_search_notes <- function(
    q, user, bbox, from, to, closed = 7,
    sort = c("created_at", "updated_at"), order = c("newest", "oldest"),
    limit = getOption("osmapir.api_capabilities")$api$notes["default_query_limit"],
    format = c("R", "sf", "xml", "rss", "json", "gpx")) {
  sort <- match.arg(sort)
  order <- match.arg(order)
  format <- match.arg(format)

  # if (limit > getOption("osmapir.api_capabilities")$api$notes["maximum_query_limit"]) {
  #   # TODO: calls in batches by date range as in osm_query_changesets()
  # }

  if (missing(q)) {
    q <- NULL
  }

  if (missing(user)) {
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

  if (missing(bbox)) {
    bbox <- NULL
  } else {
    bbox <- bbox_to_string(bbox)
  }
  if (missing(from)) {
    from <- NULL
  }
  if (missing(to)) {
    to <- NULL
  }

  if (format %in% c("R", "sf")) {
    ext <- "search.xml"
  } else {
    ext <- paste0("search.", format)
  }

  req <- osmapi_request()
  req <- httr2::req_method(req, "GET")
  req <- httr2::req_url_path_append(req, "notes", ext)

  req <- httr2::req_url_query(
    req,
    q = q, user = user, display_name = display_name, bbox = bbox,
    from = from, to = to, sort = sort, order = order, limit = limit
  )

  resp <- httr2::req_perform(req)

  if (format %in% c("R", "sf", "xml", "gpx", "rss")) {
    out <- httr2::resp_body_xml(resp)
    if (format == "R") {
      out <- note_xml2DF(out)
    } else if (format == "sf") {
      out <- sf::st_as_sf(note_xml2DF(out))
    }
  } else if (format %in% "json") {
    out <- httr2::resp_body_json(resp)
  }

  return(out)
}


## RSS Feed: `GET /api/0.6/notes/feed` ----
#
# Gets an RSS feed for notes within an area.
#
# '''URL:''' <code>https://api.openstreetmap.org/api/0.6/notes/feed
#
# '''Return type:''' application/xml
#
# {| class="wikitable"
# |-
# ! Parameter
# ! Description
# ! Allowed values
# ! Default value
# |-
# |<code>bbox</code>
# | Coordinates for the area to retrieve the notes from
# | Floating point numbers in degrees, expressing a valid bounding box, not larger than the configured size limit, 25 square degrees [https://github.com/openstreetmap/openstreetmap-website/blob/master/config/settings.yml#L27], not overlapping the dateline.
# | none, optional parameter
# |}

#' RSS Feed of notes in a bbox
#'
#' @param bbox Coordinates for the area to retrieve the notes from (`left,bottom,right,top`). Floating point numbers in
#'   degrees, expressing a valid bounding box, not larger than the configured size limit, 25 square degrees (see
#'   `osm_capabilities()$note_area` and
#'   [this line in settings](https://github.com/openstreetmap/openstreetmap-website/blob/master/config/settings.yml#L27)
#'   for the current value), not overlapping the dateline. It can be specified by a character, matrix, vector, `bbox`
#'   object from \pkg{sf}, a `SpatExtent` from \pkg{terra}. Unnamed vectors and matrices will be sorted appropriately
#'   and must merely be in the order (`x`, `y`, `x`, `y`) or `x` in the first column and `y` in the second column.
#'
#' @return
#' Returns a [xml2::xml_document-class] in the `RSS` format.
#' @family get notes' functions
#' @export
#'
#' @examples
#' feed_notes <- osm_feed_notes(bbox = c(0.8205414, 40.6686604, 0.8857727, 40.7493377))
#' ## bbox as a character value also works (bbox = "0.8205414,40.6686604,0.8857727,40.7493377").
#' feed_notes
osm_feed_notes <- function(bbox) {
  req <- osmapi_request()
  req <- httr2::req_method(req, "GET")
  req <- httr2::req_url_path_append(req, "notes", "feed")
  req <- httr2::req_url_query(req, bbox = bbox_to_string(bbox))

  resp <- httr2::req_perform(req)
  obj_xml <- httr2::resp_body_xml(resp)

  # cat(as.character(obj_xml))
  return(obj_xml)
}
