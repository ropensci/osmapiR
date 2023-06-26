## Map Notes API
#
# This provides access to the [[notes]] feature, which allows users to add geo-referenced textual "post-it" notes. This feature was not originally in the API 0.6 and was only added later ( 04/23/2013 in commit 0c8ad2f86edefed72052b402742cadedb0d674d9 )
#
#
## Retrieving notes data by bounding box: `GET /api/0.6/notes` ----
#
# Returns the existing notes in the specified bounding box. The notes will be ordered by the date of their last change, the most recent one will be first. The list of notes can be returned in several different forms (e.g. as executable JavaScript, XML, RSS, json and GPX) depending on the file extension.
#
# '''Note:''' the XML format returned by the API is different from the, equally undocumented, format used for "osm" format files, available from [https://planet.openstreetmap.org/notes/ planet.openstreetmap.org], and as output from JOSM and Vespucci.
#
# '''URL:''' <code>https://api.openstreetmap.org/api/0.6/notes?bbox=<span style="border:thin solid black">''left''</span>,<span style="border:thin solid black">''bottom''</span>,<span style="border:thin solid black">''right''</span>,<span style="border:thin solid black">''top''</span>
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
## TODO ----
osm_read_bbox_notes <- function(bbox) {
  osm_type <- match.arg(osm_type)

  req <- osmapi_request()
  req <- httr2::req_method(req, "GET")
  req <- httr2::req_url_path_append(req, "notes")

  resp <- httr2::req_perform(req)
  obj_xml <- httr2::resp_body_xml(resp)

  # cat(as.character(obj_xml))
}


## Read: `GET /api/0.6/notes/#id` ----
#
# Returns the existing note with the given ID. The output can be in several formats (e.g. XML, RSS, json or GPX) depending on the file extension.
#
# '''URL:''' <code><nowiki>https://api.openstreetmap.org/api/0.6/notes/#id</nowiki></code> ([https://api.openstreetmap.org/api/0.6/notes/100])<br />
# '''Return type:''' application/xml <br />
#
### Error codes ----
# ; HTTP status code 404 (Not Found)
# : When no note with the given id could be found

osm_read_note <- function(note_id) {
  req <- osmapi_request()
  req <- httr2::req_method(req, "GET")
  req <- httr2::req_url_path_append(req, "notes", note_id)

  resp <- httr2::req_perform(req)
  obj_xml <- httr2::resp_body_xml(resp)

  # cat(as.character(obj_xml))
}


## Create a new note: `POST /api/0.6/notes` ----
#
### XML ----
#
# '''URL:''' <code><nowiki>https://api.openstreetmap.org/api/0.6/notes?lat=51.00&lon=0.1&text=ThisIsANote</nowiki></code>
# (''use Postman or similar tools to test the endpoint - note that it must be a POST request'')<br />
# '''Return type:''' application/xml
#
# An XML-file with the details of the note will be returned
#
### JSON ----
#
# '''URL:''' <code><nowiki>https://api.openstreetmap.org/api/0.6/notes.json</nowiki></code> <br />
# '''Body content''': <code><nowiki>{"lat":51.00, "lon": 0.1&, "text":"This is a note\n\nThis is another line"}</nowiki></code> <br />
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

osm_create_note <- function() {
  req <- osmapi_request()
  req <- httr2::req_method(req, "POST")
  req <- httr2::req_url_path_append(req, "notes")

  resp <- httr2::req_perform(req)
  obj_xml <- httr2::resp_body_xml(resp)

  # cat(as.character(obj_xml))
}


## Create a new comment: `POST /api/0.6/notes/#id/comment` ----
#
# Add a new comment to note #id
#
# '''URL:''' <code><nowiki>https://api.openstreetmap.org/api/0.6/notes/#id/comment?text=ThisIsANoteComment
# </nowiki></code> (''use Postman or similar tools to test the endpoint - note that it must be a POST request'')<br />
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

osm_create_comment_note <- function(note_id) {
  req <- osmapi_request()
  req <- httr2::req_method(req, "POST")
  req <- httr2::req_url_path_append(req, "notes", note_id, "comment")

  resp <- httr2::req_perform(req)
  obj_xml <- httr2::resp_body_xml(resp)

  # cat(as.character(obj_xml))
}


## Close: `POST /api/0.6/notes/#id/close` ----
#
# Close a note as fixed.
#
# '''URL:''' <code><nowiki>https://api.openstreetmap.org/api/0.6/notes/#id/close?text=Comment</nowiki></code> (''use Postman or similar tools to test the endpoint - note that it must be a POST request'')<br />
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

osm_close_note <- function(note_id) {
  req <- osmapi_request()
  req <- httr2::req_method(req, "POST")
  req <- httr2::req_url_path_append(req, "notes", note_id, "close")

  resp <- httr2::req_perform(req)
  obj_xml <- httr2::resp_body_xml(resp)

  # cat(as.character(obj_xml))
}


## Reopen: `POST /api/0.6/notes/#id/reopen` ----
#
# Reopen a closed note.
#
# '''URL:''' <code><nowiki>https://api.openstreetmap.org/api/0.6/notes/#id/reopen?text=Comment</nowiki></code> (''use Postman or similar tools to test the endpoint'')<br />
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

osm_reopen_note <- function(note_id) {
  req <- osmapi_request()
  req <- httr2::req_method(req, "POST")
  req <- httr2::req_url_path_append(req, "notes", note_id, "reopen")

  resp <- httr2::req_perform(req)
  obj_xml <- httr2::resp_body_xml(resp)

  # cat(as.character(obj_xml))
}


## Search for notes: `GET /api/0.6/notes/search` ----
#
# Returns the existing notes matching either the initial note text or any of the comments. The notes will be ordered by the date of their last change, the most recent one will be first. If no query was specified, the latest notes are returned. The list of notes can be returned in several different forms (e.g. XML, RSS, json or GPX) depending on file extension given.
#
# '''URL:''' <code><nowiki>https://api.openstreetmap.org/api/0.6/notes/search?q=SearchTerm
# </nowiki></code> ([https://api.openstreetmap.org/api/0.6/notes/search?q=Spam example])<br />
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

osm_search_notes <- function(...) {
  req <- osmapi_request()
  req <- httr2::req_method(req, "GET")
  req <- httr2::req_url_path_append(req, "notes", "search")

  resp <- httr2::req_perform(req)
  obj_xml <- httr2::resp_body_xml(resp)

  # cat(as.character(obj_xml))
}


## RSS Feed: `GET /api/0.6/notes/feed` ----
#
# Gets an RSS feed for notes within an area.
#
# '''URL:''' <code><nowiki>https://api.openstreetmap.org/api/0.6/notes/feed?bbox=</nowiki><span style="border:thin solid black">''left''</span>,<span style="border:thin solid black">''bottom''</span>,<span style="border:thin solid black">''right''</span>,<span style="border:thin solid black">''top''</span></code>
#
# '''Return type:''' application/xml

osm_feed_notes <- function(note_id) {
  req <- osmapi_request()
  req <- httr2::req_method(req, "GET")
  req <- httr2::req_url_path_append(req, "notes", "feed")

  resp <- httr2::req_perform(req)
  obj_xml <- httr2::resp_body_xml(resp)

  # cat(as.character(obj_xml))
}
