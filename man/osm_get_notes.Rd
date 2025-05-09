% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/osm_get_notes.R
\name{osm_get_notes}
\alias{osm_get_notes}
\title{Get notes}
\usage{
osm_get_notes(note_id, format = c("R", "sf", "xml", "rss", "json", "gpx"))
}
\arguments{
\item{note_id}{Note id represented by a numeric or a character value.}

\item{format}{Format of the output. Can be \code{"R"} (default), \code{"sf"}, \code{"xml"}, \code{"rss"}, \code{"json"} or \code{"gpx"}.}
}
\value{
If \code{format = "R"}, returns a data frame with one map note per row. If \code{format = "sf"}, returns a \code{sf} object from
\pkg{sf}.
\subsection{\code{format = "xml"}}{

Returns a \link[xml2:oldclass]{xml2::xml_document} with the following format:

\if{html}{\out{<div class="sourceCode xml">}}\preformatted{<?xml version="1.0" encoding="UTF-8"?>
<osm version="0.6" generator="OpenStreetMap server" copyright="OpenStreetMap and contributors" attribution="https://www.openstreetmap.org/copyright" license="https://opendatacommons.org/licenses/odbl/1-0/">
  <note lon="0.1000000" lat="51.0000000">
    <id>16659</id>
    <url>https://master.apis.dev.openstreetmap.org/api/0.6/notes/16659</url>
    <comment_url>https://master.apis.dev.openstreetmap.org/api/0.6/notes/16659/comment</comment_url>
    <close_url>https://master.apis.dev.openstreetmap.org/api/0.6/notes/16659/close</close_url>
    <date_created>2019-06-15 08:26:04 UTC</date_created>
    <status>open</status>
    <comments>
      <comment>
        <date>2019-06-15 08:26:04 UTC</date>
        <uid>1234</uid>
        <user>userName</user>
        <user_url>https://master.apis.dev.openstreetmap.org/user/userName</user_url>
        <action>opened</action>
        <text>ThisIsANote</text>
        <html>&lt;p&gt;ThisIsANote&lt;/p&gt;</html>
      </comment>
      ...
    </comments>
  </note>
  ...
</osm>
}\if{html}{\out{</div>}}
}

\subsection{\code{format = "json"}}{

Returns a list with the following json structure:

\if{html}{\out{<div class="sourceCode json">}}\preformatted{\{
  "type": "FeatureCollection",
  "features": [
    \{
      "type": "Feature",
      "geometry": \{"type": "Point", "coordinates": [0.1000000, 51.0000000]\},
      "properties": \{
        "id": 16659,
        "url": "https://master.apis.dev.openstreetmap.org/api/0.6/notes/16659.json",
        "comment_url": "https://master.apis.dev.openstreetmap.org/api/0.6/notes/16659/comment.json",
        "close_url": "https://master.apis.dev.openstreetmap.org/api/0.6/notes/16659/close.json",
        "date_created": "2019-06-15 08:26:04 UTC",
        "status": "open",
        "comments": [
          \{"date": "2019-06-15 08:26:04 UTC", "uid": 1234, "user": "userName", "user_url": "https://master.apis.dev.openstreetmap.org/user/userName", "action": "opened", "text": "ThisIsANote", "html": "<p>ThisIsANote</p>"\},
          ...
        ]
      \}
    \}
  ]
\}
}\if{html}{\out{</div>}}
}

\subsection{\code{format = "rss"} & \code{format = "gpx"}}{

For \code{format} in \code{"rss"}, and \code{"gpx"}, a \link[xml2:oldclass]{xml2::xml_document} with the corresponding format.
}
}
\description{
Returns the existing note with the given ID.
}
\examples{
note <- osm_get_notes(note_id = "2067786")
note
}
\seealso{
Other get notes' functions: 
\code{\link{osm_feed_notes}()},
\code{\link{osm_read_bbox_notes}()},
\code{\link{osm_search_notes}()}
}
\concept{get notes' functions}
