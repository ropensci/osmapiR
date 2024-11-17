# Vectorized version of osm_read_note

#' Get notes
#'
#' Returns the existing note with the given ID.
#'
#' @param note_id Note id represented by a numeric or a character value.
#' @param format Format of the output. Can be `"R"` (default), `"sf"`, `"xml"`, `"rss"`, `"json"` or `"gpx"`.
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
#'  "type": "FeatureCollection",
#'  "features": [
#'   {
#'    "type": "Feature",
#'    "geometry": {"type": "Point", "coordinates": [0.1000000, 51.0000000]},
#'    "properties": {
#'     "id": 16659,
#'     "url": "https://master.apis.dev.openstreetmap.org/api/0.6/notes/16659.json",
#'     "comment_url": "https://master.apis.dev.openstreetmap.org/api/0.6/notes/16659/comment.json",
#'     "close_url": "https://master.apis.dev.openstreetmap.org/api/0.6/notes/16659/close.json",
#'     "date_created": "2019-06-15 08:26:04 UTC",
#'     "status": "open",
#'     "comments": [
#'      {"date": "2019-06-15 08:26:04 UTC", "uid": 1234, "user": "userName", "user_url": "https://master.apis.dev.openstreetmap.org/user/userName", "action": "opened", "text": "ThisIsANote", "html": "<p>ThisIsANote</p>"},
#'      ...
#'     ]
#'    }
#'   }
#'  ]
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
#' note <- osm_get_notes(note_id = "2067786")
#' note
osm_get_notes <- function(note_id, format = c("R", "sf", "xml", "rss", "json", "gpx")) {
  format <- match.arg(format)
  .format <- if (format == "sf") "R" else format
  if (format == "sf" && !requireNamespace("sf", quietly = TRUE)) {
    stop("Missing `sf` package. Install with:\n\tinstall.package(\"sf\")")
  }

  if (length(note_id) == 1) {
    out <- osm_read_note(note_id = note_id, format = .format)
  } else {
    outL <- lapply(note_id, function(id) {
      osm_read_note(note_id = id, format = .format)
    })

    if (.format == "R") {
      out <- do.call(rbind, outL)
    } else if (.format %in% c("xml", "rss", "gpx")) {
      out <- xml2::xml_new_root(outL[[1]])
      for (i in seq_along(outL[-1]) + 1) {
        lapply(xml2::xml_children(outL[[i]]), function(node) {
          xml2::xml_add_child(out, node)
        })
      }
      # TODO: remove namespaces for format %in% c("rss", "gpx"). xml2::xml_structure(out) [<wpt [lon, lat]> VS <wpt [lon, lat, xmlns]>]
      # xml namespace https://community.rstudio.com/t/adding-nodes-in-xml2-how-to-avoid-duplicate-default-namespaces/84870/
    } else if (format == "json") {
      out <- outL
    }
  }

  if (format == "sf") {
    out <- sf::st_as_sf(out)
  }

  return(out)
}
