## GPS traces
#
# In violation of the [https://www.topografix.com/GPX/1/1/#type_trksegType GPX standard] when downloading public GPX traces through the API, all waypoints of non-trackable traces are randomized (or rather sorted by lat/lon) and delivered as one trackSegment for privacy reasons. Trackable traces are delivered, sorted by descending upload time, before the waypoints of non-trackable traces.

# TODO: I found that `GET /api/0.6/gpx/#id/details` & `GET /api/0.6/gpx/#id/data` doesn't work without authentication (HTTP 401 Unauthorized) even for public or identificable tracks. Seems a bug in the API implementation or the documentation should be amended.


## Get GPS Points: `GET /api/0.6/trackpoints?bbox=*'left','bottom','right','top'*&page=*'pageNumber'*` ----
# Use this to retrieve the GPS track points that are inside a given bounding box (formatted in a GPX format).
#
# where:
# * <code>''left''</code> is the longitude of the left (westernmost) side of the bounding box.
# * <code>''bottom''</code> is the latitude of the bottom (southernmost) side of the bounding box.
# * <code>''right''</code> is the longitude of the right (easternmost) side of the bounding box.
# * <code>''top''</code> is the latitude of the top (northernmost) side of the bounding box.
# * <code>''pageNumber''</code> specifies which group of 5,000 points, or ''page'', to return. Since the command does not return more than 5,000 points at a time, this parameter must be incremented&mdash;and the command sent again (using the same bounding box)&mdash;in order to retrieve all of the points for a bounding box that contains more than 5,000 points. When this parameter is 0 (zero), the command returns the first 5,000 points; when it is 1, the command returns points 5,001&ndash;10,000, etc.
# The maximal width (right - left) and height (top - bottom) of the bounding box is 0.25 degree.
#
### Examples ----
# Retrieve the first 5,000 points for a bounding box:
#  https://api.openstreetmap.org/api/0.6/trackpoints?bbox=0,51.5,0.25,51.75&page=0
# Retrieve the next 5,000 points (points 5,001&ndash;10,000) for the same bounding box:
#  https://api.openstreetmap.org/api/0.6/trackpoints?bbox=0,51.5,0.25,51.75&page=1
#
### Response ----
#
# * This response is NOT wrapped in an OSM xml parent element.
# * The file format is GPX Version 1.0 which is not the current version. Verify that your tools support it.
# <syntaxhighlight lang="xml">
# <?xml version="1.0" encoding="UTF-8"?>
# <gpx version="1.0" creator="OpenStreetMap.org" xmlns="http://www.topografix.com/GPX/1/0">
# 	<trk>
# 		<name>20190626.gpx</name>
# 		<desc>Footpaths near Blackweir Pond, Epping Forest</desc>
# 		<url>https://api.openstreetmap.org/user/John%20Leeming/traces/3031013</url>
# 		<trkseg>
# 			<trkpt lat="51.6616100" lon="0.0534560">
# 				<time>2019-06-26T14:27:58Z</time>
# 			</trkpt>
# 			...
# 		</trkseg>
# 		...
# 	</trk>
# 	...
# </gpx>
# </syntaxhighlight>

#' Get GPS Points
#'
#' Use this to retrieve the GPS track points that are inside a given bounding box (formatted in a GPX format).
#'
#' @param bbox Coordinates for the area to retrieve the notes from (`left,bottom,right,top`). Floating point numbers in
#'   degrees, expressing a valid bounding box. The maximal width (`right - left`) and height (`top - bottom`) of the
#'   bounding box is 0.25 degree.
#' @param page_number Specifies which group of 5,000 points, or page, to return. Since the command does not return more
#'   than 5,000 points at a time, this parameter must be incremented —and the command sent again (using the same bounding
#'   box)— in order to retrieve all of the points for a bounding box that contains more than 5,000 points. When this
#'   parameter is 0 (zero), the command returns the first 5,000 points; when it is 1, the command returns points
#'   5,001–10,000, etc.
#' @param format Format of the output. Can be `R` (default) or `gpx`.
#'
#' @note In violation of the [GPX standard](https://www.topografix.com/GPX/1/1/#type_trksegType) when downloading public
#'   GPX traces through the API, all waypoints of non-trackable traces are randomized (or rather sorted by lat/lon) and
#'   delivered as one trackSegment for privacy reasons. Trackable traces are delivered, sorted by descending upload
#'   time, before the waypoints of non-trackable traces.
#'
#' @return
#' @family get GPS' functions
#' @export
#'
#' @examples
#' pts_gps <- osm_get_points_gps(bbox = c(-0.3667545, 40.2153246, -0.3354263, 40.2364915))
#' ## bbox as a character value also works. Equivalent call:
#' # pts_gps <- osm_get_points_gps(bbox = "-0.3667545,40.2153246,-0.3354263,40.2364915")
#' pts_gps
osm_get_points_gps <- function(bbox, page_number = 0, format = c("R", "gpx")) {
  format <- match.arg(format)

  req <- osmapi_request()
  req <- httr2::req_method(req, "GET")
  req <- httr2::req_url_path_append(req, "trackpoints")
  req <- httr2::req_url_query(req, bbox = paste(bbox, collapse = ","), page = page_number)

  resp <- httr2::req_perform(req)
  obj_xml <- httr2::resp_body_xml(resp)

  if (format == "R") {
    out <- gpx_xml2list(obj_xml)
    names(out) <- vapply(out, function(x) {
      url <- attr(x, "url")
      if (is.null(url)) { # for private traces?
        url <- ""
      }
      url
    }, FUN.VALUE = character(1))
  } else {
    out <- obj_xml
  }

  return(out)
}


## Create: `POST /api/0.6/gpx/create` ----
#
# Use this to upload a GPX file or archive of GPX files. Requires authentication.
#
# The following parameters are required in a multipart/form-data HTTP message:
#
# {| class=wikitable
# !parameter
# !description
# |-
# |file
# |The GPX file containing the track points. Note that for successful processing, the file must contain trackpoints (<code><trkpt></code>), not only waypoints, and the trackpoints must have a valid timestamp. Since the file is processed asynchronously, the call will complete successfully even if the file cannot be processed. The file may also be a .tar, .tar.gz or .zip containing multiple gpx files, although it will appear as a single entry in the upload log.
# |-
# |description
# |The trace description. Cannot be empty.
# |-
# |tags
# |A string containing tags for the trace. Can be empty.
# |-
# |public
# |1 if the trace is public, 0 if not. This exists for backwards compatibility only - the visibility parameter should now be used instead. This value will be ignored if visibility is also provided.
# |-
# |visibility
# |One of the following: private, public, trackable, identifiable (for explanations see [https://www.openstreetmap.org/traces/mine OSM trace upload page] or [[Visibility of GPS traces]])
# |}Response:
#
# A number representing the ID of the new gpx
#
### Error codes ----
# ; HTTP status code 400 (Bad Request)
# : When the description is empty

#' Create GPS trace
#'
#' Use this to upload a GPX file or archive of GPX files. Requires authentication.
#'
#' @param file The GPX file path containing the track points.
#' @param description The trace description. Cannot be empty.
#' @param tags A string containing tags for the trace. Can be empty.
#' @param visibility One of the following: `private`, `public`, `trackable`, `identifiable`. For explanations see
#'   [OSM trace upload page](https://www.openstreetmap.org/traces/mine) or
#'   [Visibility of GPS traces](https://wiki.openstreetmap.org/wiki/Visibility_of_GPS_traces)).
#'
#' @details
#' Note that for successful processing, the file must contain trackpoints (`<trkpt>`), not only waypoints, and the
#' trackpoints must have a valid timestamp. Since the file is processed asynchronously, the call will complete
#' successfully even if the file cannot be processed. The file may also be a .tar, .tar.gz or .zip containing multiple
#' gpx files, although it will appear as a single entry in the upload log.
#'
#' @return A number representing the ID of the new gpx
#' @family edit GPS traces' functions
#' @export
#'
#' @examples
osm_create_gpx <- function(file, description, tags, visibility = c("private", "public", "trackable", "identifiable")) {
  visibility <- match.arg(visibility)
  if (missing(tags)) {
    tags = NULL
  } else {
    tags <- paste(tags, collapse = ", ")
  }

  req <- osmapi_request(authenticate = TRUE)
  req <- httr2::req_method(req, "POST")
  req <- httr2::req_url_path_append(req, "gpx", "create")
  req <- httr2::req_body_multipart(
    req,
    file = curl::form_file(file),
    description = description,
    tags = tags,
    visibility = visibility
  )

  resp <- httr2::req_perform(req)
  out <- httr2::resp_body_string(resp)

  return(out)
}

## Update: `PUT /api/0.6/gpx/#id` ----
# Use this to update a GPX file. Only usable by the owner account. Requires authentication.<br />The response body will be empty.
## TODO: improve wiki. Poor documentation
# https://github.com/openstreetmap/openstreetmap-website/blob/master/app/controllers/api/traces_controller.rb#L51

#' Update GPS trace
#'
#' Use this to update a GPX file. Only usable by the owner account. Requires authentication.
#'
#' @param gpx_id The track id represented by a numeric or a character value.
#' @param file The GPX file path containing the track points.
#'
#' @return
#' @family edit GPS traces' functions
#' @export
#'
#' @examples
osm_update_gpx <- function(gpx_id, file) {
  req <- osmapi_request(authenticate = TRUE)
  req <- httr2::req_method(req, "PUT")
  req <- httr2::req_url_path_append(req, "gpx", gpx_id)
  req <- httr2::req_body_multipart(req, file = curl::form_file(file))

  resp <- httr2::req_perform(req)

  invisible()
}


## Delete: `DELETE /api/0.6/gpx/#id` ----
# Use this to delete a GPX file. Only usable by the owner account. Requires authentication.<br />The response body will be empty.
## TODO: improve wiki. Poor documentation
# https://github.com/openstreetmap/openstreetmap-website/blob/master/app/controllers/api/traces_controller.rb#L64

#' Delete GPS trace
#'
#' Use this to delete a GPX file. Only usable by the owner account. Requires authentication.
#'
#' @param gpx_id The track id represented by a numeric or a character value.
#'
#' @return
#' @family edit GPS traces' functions
#' @export
#'
#' @examples
osm_delete_gpx <- function(gpx_id) {
  req <- osmapi_request(authenticate = TRUE)
  req <- httr2::req_method(req, "DELETE")
  req <- httr2::req_url_path_append(req, "gpx", gpx_id)

  resp <- httr2::req_perform(req)

  invisible()
}


## Download Metadata: `GET /api/0.6/gpx/#id/details` ----
# Use this to access the metadata about a GPX file. Available without authentication if the file is marked public. Otherwise only usable by the owner account and requires authentication.
## TODO: HTTP 401 Unauthorized. (even for public or identificable tracks). FIX wiki or BUG to API ----
# Example "details" response:
# <syntaxhighlight lang="xml">
# <?xml version="1.0" encoding="UTF-8"?>
# <osm version="0.6" generator="OpenStreetMap server">
# 	<gpx_file id="836619" name="track.gpx" lat="52.0194" lon="8.51807" user="Hartmut Holzgraefe" visibility="public" pending="false" timestamp="2010-10-09T09:24:19Z">
# 		<description>PHP upload test</description>
# 		<tag>test</tag>
# 		<tag>php</tag>
# 	</gpx_file>
# </osm>
# </syntaxhighlight>

#' Download GPS Track Metadata
#'
#' Use this to access the metadata about a GPX file. Available without authentication if the file is marked public.
#' Otherwise only usable by the owner account and requires authentication.
#'
#' @param gpx_id The track id represented by a numeric or a character value.
#'
#' @return
#' @family get GPS' functions
#' @export
#'
#' @examples
#' \dontrun{
#' trk_meta <- osm_get_metadata_gpx(gpx_id = 3498170)
#' trk_meta
#' }
osm_get_metadata_gpx <- function(gpx_id) {
  req <- osmapi_request(authenticate = TRUE)
  req <- httr2::req_method(req, "GET")
  req <- httr2::req_url_path_append(req, "gpx", gpx_id, "details")

  resp <- httr2::req_perform(req)
  obj_xml <- httr2::resp_body_xml(resp)

  out <- gpx_meta_xml2DF(obj_xml)

  return(out)
}


## Download Data: `GET /api/0.6/gpx/#id/data` ----
#
# Use this to download the full GPX file. Available without authentication if the file is marked public. Otherwise only usable by the owner account and requires authentication.
## TODO: HTTP 401 Unauthorized. (even for public or identificable tracks). FIX wiki or BUG to API ----
#
# The response will always be a GPX format file if you use a '''.gpx''' URL suffix, a XML file in an undocumented format if you use a '''.xml''' URL suffix, otherwise the response will be the exact file that was uploaded.
# TODO: HTTP 400 Bad Request. without format
#
# NOTE: if you request refers to a multi-file archive the response when you force gpx or xml format will consist of a non-standard simple concatenation of the files.



#' Download GPS Track Data
#'
#' Use this to download the full GPX file. Available without authentication if the file is marked public. Otherwise only
#' usable by the owner account and requires authentication.
#'
#' @param gpx_id The track id represented by a numeric or a character value.
#' @param format Format of the output. If missing (default), the response will be the exact file that was uploaded.
#'   If `R`, a `data.frame`.
#'   If `gpx`, the response will always be a GPX format file.
#'   If `xml`, a `XML` file in an undocumented format.
#'
#' @note If you request refers to a multi-file archive the response when you force gpx or xml format will consist of a
#'   non-standard simple concatenation of the files.
#'
#' @return
#' @family get GPS' functions
#' @export
#'
#' @examples
#' \dontrun{
#' trk_data <- osm_get_data_gpx(gpx_id = 3498170, format = "R")
#' trk_data
#' }
osm_get_data_gpx <- function(gpx_id, format) {
  if (missing(format)) {
    ext <- "data"
  } else {
    stopifnot(format %in% c("R", "xml", "gpx"))
    if (format == "gpx") {
      ext <- "data.gpx"
    } else {
      ext <- "data.xml"
    }
  }

  req <- osmapi_request(authenticate = TRUE)
  req <- httr2::req_method(req, "GET")
  req <- httr2::req_url_path_append(req, "gpx", gpx_id, ext)

  resp <- httr2::req_perform(req)
  obj_xml <- httr2::resp_body_xml(resp)

  if (missing(format) || format %in% c("xml", "gpx")) {
    out <- obj_xml
  } else {
    out <- gpx_xml2list(obj_xml)

    if (length(out) > 1) {
      warning(
        "Unexpected output format at osm_get_data_gpx().",
        "Please, open and issue with with the `gpx_id` at https://github.com/jmaspons/osmapiR/issues"
      )
    } else {
      attrs <- attributes(out)
      attrs <- attrs[setdiff(names(attrs), "class")]
      names(attrs) <- paste0("gpx_", names(attrs))
      out <- out[[1]]
      attributes(out) <- c(attributes(out), attrs)
      class(out) <- c("osmapi_gps_track", "data.frame")
    }
  }

  return(out)
}


## List: `GET /api/0.6/user/gpx_files` ----
# Use this to get a list of GPX traces owned by the authenticated user: Requires authentication.
#
# Note that '''/user/''' is a literal part of the URL, not a user's display name or user id. (This call always returns GPX traces for the current authenticated user ''only''.)
#
# Example "details" response:
# <syntaxhighlight lang="xml">
# <?xml version="1.0" encoding="UTF-8"?>
# <osm version="0.6" generator="OpenStreetMap server">
# 	<gpx_file id="836619" name="track.gpx" lat="52.0194" lon="8.51807" user="Hartmut Holzgraefe" visibility="public" pending="false" timestamp="2010-10-09T09:24:19Z">
# 		<description>PHP upload test</description>
# 		<tag>test</tag>
# 		<tag>php</tag>
# 	</gpx_file>
# </osm>
# </syntaxhighlight>

#' List user's GPX traces
#'
#' Use this to get a list of GPX traces owned by the authenticated user. Requires authentication.
#'
#' @return
#' @family get GPS' functions
#' @export
#'
#' @examples
#' \dontrun{
#' traces <- osm_list_gpxs()
#' traces
#' }
osm_list_gpxs <- function() {
  req <- osmapi_request(authenticate = TRUE)
  req <- httr2::req_method(req, "GET")
  req <- httr2::req_url_path_append(req, "user", "gpx_files")

  resp <- httr2::req_perform(req)
  obj_xml <- httr2::resp_body_xml(resp)

  out <- gpx_meta_xml2DF(obj_xml)

  return(out)
}
