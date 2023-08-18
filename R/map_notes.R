## Map Notes API
#
# This provides access to the [[notes]] feature, which allows users to add geo-referenced textual "post-it" notes. This feature was not originally in the API 0.6 and was only added later ( 04/23/2013 in commit 0c8ad2f86edefed72052b402742cadedb0d674d9 )


## Retrieving notes data by bounding box: `GET /api/0.6/notes` ----
#
# TODO: executable JavaScript (format `js`) not implemented in the server? https://github.com/openstreetmap/openstreetmap-website/blob/512f7de4a95b0522bcb26ac03cc31e1a91521662/app/controllers/api/notes_controller.rb#L47
# Returns the existing notes in the specified bounding box. The notes will be ordered by the date of their last change, the most recent one will be first. The list of notes can be returned in several different forms (e.g. as executable JavaScript, XML, RSS, json and GPX) depending on the file extension.
#
# '''Note:''' the XML format returned by the API is different from the, equally undocumented, format used for "osm" format files, available from [https://planet.openstreetmap.org/notes/ planet.openstreetmap.org], and as output from JOSM and Vespucci.
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
# | Floating point numbers in degrees, expressing a valid bounding box, not larger than the configured size limit, 25 square degrees [https://github.com/openstreetmap/openstreetmap-website/blob/master/config/settings.yml#L27], not overlapping the dateline.
# | none, parameter required
# |-
# | <code>limit</code>
# | Specifies the number of entries returned at max
# | A value of between 1 and 10000 is valid
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
# 	<note lon="0.1000000" lat="51.0000000">
# 		<id>16659</id>
# 		<url>https://master.apis.dev.openstreetmap.org/api/0.6/notes/16659</url>
# 		<comment_url>https://master.apis.dev.openstreetmap.org/api/0.6/notes/16659/comment</comment_url>
# 		<close_url>https://master.apis.dev.openstreetmap.org/api/0.6/notes/16659/close</close_url>
# 		<date_created>2019-06-15 08:26:04 UTC</date_created>
# 		<status>open</status>
# 		<comments>
# 			<comment>
# 				<date>2019-06-15 08:26:04 UTC</date>
#                 <uid>1234</uid>
#                 <user>userName</user>
#                 <user_url>https://master.apis.dev.openstreetmap.org/user/userName</user_url>
# 				<action>opened</action>
# 				<text>ThisIsANote</text>
# 				<html>&lt;p&gt;ThisIsANote&lt;/p&gt;</html>
# 			</comment>
# 			...
# 		</comments>
# 	</note>
# 	...
# </osm>
# </syntaxhighlight>
#
### Response JSON ----
#  GET /api/0.6/notes.json
# <syntaxhighlight lang="json">
# {
#  "type": "FeatureCollection",
#  "features": [
#   {
#    "type": "Feature",
#    "geometry": {"type": "Point", "coordinates": [0.1000000, 51.0000000]},
#    "properties": {
#     "id": 16659,
#     "url": "https://master.apis.dev.openstreetmap.org/api/0.6/notes/16659.json",
#     "comment_url": "https://master.apis.dev.openstreetmap.org/api/0.6/notes/16659/comment.json",
#     "close_url": "https://master.apis.dev.openstreetmap.org/api/0.6/notes/16659/close.json",
#     "date_created": "2019-06-15 08:26:04 UTC",
#     "status": "open",
#     "comments": [
#      {"date": "2019-06-15 08:26:04 UTC", "uid": 1234, "user": "userName", "user_url": "https://master.apis.dev.openstreetmap.org/user/userName", "action": "opened", "text": "ThisIsANote", "html": "<p>ThisIsANote</p>"},
#      ...
#     ]
#    }
#   }
#  ]
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
#'   overlapping the dateline.
#' @param limit Specifies the number of entries returned at max. A value between 1 and 10000 is valid. Default to 100.
#' @param closed Specifies the number of days a note needs to be closed to no longer be returned. A value of 0 means
#'   only open notes are returned. A value of -1 means all notes are returned. Default to 7.
#' @param format Format of the output. Can be `R` (default), `xml`, `rss`, `json` or `gpx`.
#'
#' @note The comment properties (`uid`, `user`, `user_url`) will be omitted if the comment was anonymous.
#'
#' @return
#' @family get notes' functions
#' @export
#'
#' @examples
#' notes <- osm_read_bbox_notes(bbox = c(3.7854767, 39.7837403, 4.3347931, 40.1011851), limit = 10)
#' ## bbox as a character value also works. Equivalent call:
#' # osm_read_bbox_notes(bbox = "3.7854767,39.7837403,4.3347931,40.1011851", limit = 10)
#' notes
osm_read_bbox_notes <- function(bbox, limit = 100, closed = 7, format = c("R", "xml", "rss", "json", "gpx")) {
  format <- match.arg(format)

  if (format == "R") {
    ext <- "notes.xml"
  } else {
    ext <- paste0("notes.", format)
  }

  req <- osmapi_request()
  req <- httr2::req_method(req, "GET")
  req <- httr2::req_url_path_append(req, ext)
  req <- httr2::req_url_query(req, bbox = paste(bbox, collapse = ","), limit = limit, closed = closed)

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


## Read: `GET /api/0.6/notes/#id` ----
#
# Returns the existing note with the given ID. The output can be in several formats (e.g. XML, RSS, json or GPX) depending on the file extension.
#
# '''URL:''' <code>https://api.openstreetmap.org/api/0.6/notes/#id</code> ([https://api.openstreetmap.org/api/0.6/notes/100])<br />
# '''Return type:''' application/xml <br />
#
### Error codes ----
# ; HTTP status code 404 (Not Found)
# : When no note with the given id could be found

#' Read notes
#'
#' Returns the existing note with the given ID.
#'
#' @param note_id Note id represented by a numeric or a character value.
#' @param format Format of the output. Can be `R` (default), `xml`, `rss`, `json` or `gpx`.
#'
#' @return
#' @family get notes' functions
#' @export
#'
#' @examples
#' \dontrun{
#' note <- osm_read_note(note_id = "2067786")
#' note
#' }
osm_read_note <- function(note_id, format = c("R", "xml", "rss", "json", "gpx")) {
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
# If the request is made as an authenticated user, the note is associated to that user account.
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
#' If the request is made as an authenticated user, the note is associated to that user account.
#'
#' @return
#' @family edit notes' functions
#' @export
#'
#' @examples
osm_create_note <- function(lat, lon, text, authenticate = TRUE) { # TODO: , format = c("R", "xml", "json")
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
# : if no note with that id is not available
# : This also applies, if the request is not a HTTP POST request
# ; <s>HTTP status code 405 (Method Not Allowed)</s>
# : <s>If the request is not a HTTP POST request</s>
# ; HTTP status code 409 (Conflict)
# : When the note is closed

#' Create a new comment in a note
#'
#' Add a new comment to an existeing note. Requires authentication.
#'
#' @param note_id Note id represented by a numeric or a character value.
#' @param text The comment as arbitrary text.
#'
#' @return
#' @family edit notes' functions
#' @export
#'
#' @examples
osm_create_comment_note <- function(note_id, text) {
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
# : When no note with the given id could be found
# : This also applies, if the request is not a HTTP POST request
# ; <s>HTTP status code 405 (Method Not Allowed)</s>
# : <s>If the request is not a HTTP POST request</s>
# ; HTTP status code 409 (Conflict)
# : When closing an already closed note

#' Close a note
#'
#' Close a note as fixed. Requires authentication.
#'
#' @param note_id Note id represented by a numeric or a character value.
#'
#' @return
#' @family edit notes' functions
#' @export
#'
#' @examples
osm_close_note <- function(note_id) {
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

#' Reopen a note
#'
#' Reopen a closed note. Requires authentication.
#'
#' @param note_id Note id represented by a numeric or a character value.
#'
#' @return
#' @family edit notes' functions
#' @export
#'
#' @examples
osm_reopen_note <- function(note_id) {
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
#'
#' @details Use [osm_reopen_note()]to make the note visible again.
#'
#' @return
#' @family functions for moderators
#' @export
#'
#' @examples
osm_delete_note <- function(note_id) {
  req <- osmapi_request(authenticate = TRUE)
  req <- httr2::req_method(req, "DELETE")
  req <- httr2::req_url_path_append(req, "notes", note_id)

  resp <- httr2::req_perform(req)
  obj_xml <- httr2::resp_body_xml(resp)

  # TODO: parse unknown xml response (only available for moderator)

  return(obj_xml)
}


## Search for notes: `GET /api/0.6/notes/search` ----
#
# Returns the existing notes matching either the initial note text or any of the comments. The notes will be ordered by the date of their last change, the most recent one will be first. If no query was specified, the latest notes are returned. The list of notes can be returned in several different forms (e.g. XML, RSS, json or GPX) depending on file extension given.
#
# '''URL:''' <code>https://api.openstreetmap.org/api/0.6/notes/search?q=SearchTerm
# </code> ([https://api.openstreetmap.org/api/0.6/notes/search?q=Spam example])<br />
# '''Return type:''' application/xml<br />
#
# {| class="wikitable"
# |-
# ! Parameter
# ! Description
# ! Allowed values
# ! Default value
# |-
# | <code>q</code>
# | Specifies the search query
# | String
# | none, parameter required
# |-
# | <code>limit</code>
# | Specifies the number of entries returned at max
# | A value of between 1 and 10000 is valid
# | 100 is the default
# |-
# | <code>closed</code>
# | Specifies the number of days a note needs to be closed to no longer be returned
# | A value of 0 means only open notes are returned. A value of -1 means all notes are returned.
# | 7 is the default
# |-
# |<code>display_name</code>
# |Specifies the person involved in actions of the returned notes, query by the display name. Does not work together with the <code>user</code> parameter (Returned are all where this user has taken some action - opened note, commented on, reactivated, or closed)
# |A valid user name
# |none, optional parameter
# |-
# |<code>user</code>
# |Specifies the creator of the returned notes by the id of the user. Does not work together with the <code>display_name</code> parameter
# |A valid user id
# |none, optional parameter
# |-
# |<code>from</code>
# |Specifies the beginning of a date range to search in for a note
# |A valid [https://en.wikipedia.org/wiki/ISO_8601 ISO 8601] date
# |none, optional parameter
# |-
# |<code>to</code>
# |Specifies the end of a date range to search in for a note
# |A valid [https://en.wikipedia.org/wiki/ISO_8601 ISO 8601] date
# |the date of today is the default, optional parameter
# |-
# |<code>sort</code>
# |Specifies the value which should be used to sort the notes. It is either possible to sort them by their creation date or the date of the last update.
# |<code>created_at</code> or <code>updated_at</code>
# |<code>updated_at</code>
# |-
# |<code>order</code>
# |Specifies the order of the returned notes. It is possible to order them in ascending or descending order.
# |<code>oldest</code> or <code>newest</code>
# |<code>newest</code>
# |}
#
### Error codes ----
# ; HTTP status code 400 (Bad Request)
# : When any of the limits are crossed

#' Search for notes
#'
#' Returns the existing notes matching either the initial note text or any of the comments.
#'
#' @param q Specifies the search query.
#' @param user Find notes by the user with the given user id (numeric) or display name (character).
#' @param from Specifies the beginning of a date range to search in for a note. A valid
#'   [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) date.
#' @param to Specifies the end of a date range to search in for a note. A valid
#'   [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) date. The date of today is the default.
#' @param closed Specifies the number of days a note needs to be closed to no longer be returned. A value of 0 means
#'   only open notes are returned. A value of -1 means all notes are returned. 7 is the default.
#' @param sort Specifies the value which should be used to sort the notes. It is either possible to sort them by their
#'   creation date (`created_at`) or the date of the last update (`updated_at`, the default).
#' @param order Specifies the order of the returned notes. It is possible to order them in ascending (`oldest`) or
#'   descending (`newest`, the default) order.
#' @param limit Specifies the number of entries returned at max. A value of between 1 and 10000 is valid.	100 is the
#'   default.
#' @param format Format of the the returned list of notes. Can be `R` (default), `xml`, `rss`, `json` or `gpx`.
#'
#' @details
#' The notes will be ordered by the date of their last change, the most recent one will be first. If no query was
#' specified, the latest notes are returned.
#'
#' @return
#' @family get notes' functions
#' @export
#'
#' @examples
#' notes <- osm_search_notes(q = "POI", from = "2017-10-01", to = "2017-10-27T15:27A", limit = 10)
#' notes
#'
#' my_notes <- osm_search_notes(user = "jmaspons", closed = -1, format = "json")
#' my_notes
osm_search_notes <- function(
    q, user, from, to, closed = 7,
    sort = c("updated_at", "created_at"), order = c("newest", "oldest"),
    limit = 100, format = c("R", "xml", "rss", "json", "gpx")) {
  sort <- match.arg(sort)
  order <- match.arg(order)
  format <- match.arg(format)

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

  if (missing(from)) {
    from <- NULL
  }
  if (missing(to)) {
    to <- NULL
  }

  if (format == "R") {
    ext <- "search.xml"
  } else {
    ext <- paste0("search.", format)
  }

  req <- osmapi_request()
  req <- httr2::req_method(req, "GET")
  req <- httr2::req_url_path_append(req, "notes", ext)

  req <- httr2::req_url_query(
    req,
    q = q, user = user, display_name = display_name,
    from = from, to = to, sort = sort, order = order, limit = limit
  )

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


## RSS Feed: `GET /api/0.6/notes/feed` ----
#
# Gets an RSS feed for notes within an area.
#
# '''URL:''' <code>https://api.openstreetmap.org/api/0.6/notes/feed?bbox=''left'',''bottom'',''right'',''top''</code>
#
# '''Return type:''' application/xml

#' RSS Feed of notes in a bbox
#'
#' @param bbox Coordinates for the area to retrieve the notes from (`left,bottom,right,top`). Floating point numbers in
#'   degrees, expressing a valid bounding box.
#'
#' @return
#' @family get notes' functions
#' @export
#'
#' @examples
#' feed_notes <- osm_feed_notes(bbox = c(0.8205414, 40.6686604, 0.8857727, 40.7493377))
#' ## bbox as a character value also works. Equivalent call:
#' # feed_notes <- osm_feed_notes(bbox = "0.8205414,40.6686604,0.8857727,40.7493377")
#' feed_notes
osm_feed_notes <- function(bbox) {
  req <- osmapi_request()
  req <- httr2::req_method(req, "GET")
  req <- httr2::req_url_path_append(req, "notes", "feed")
  req <- httr2::req_url_query(req, bbox = paste(bbox, collapse = ","))

  resp <- httr2::req_perform(req)
  obj_xml <- httr2::resp_body_xml(resp)

  # cat(as.character(obj_xml))
  return(obj_xml)
}
