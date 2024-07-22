#' Get GPS Points
#'
#' Use this to retrieve the GPS track points that are inside a given bounding box (formatted in a GPX format).
#'
#' @param bbox Coordinates for the area to retrieve the notes from (`left,bottom,right,top`). Floating point numbers in
#'   degrees, expressing a valid bounding box. The maximal width (`right - left`) and height (`top - bottom`) of the
#'   bounding box is 0.25 degree.
#' @param page_number Specifies which groups of 5,000 points, or page, to return. The API call does not return more
#'   than 5,000 points at a time. In order to retrieve all of the points for a bounding box, set `page_number = -1`.
#'   When this parameter is 0 (zero), the command returns the first 5,000 points; when it is 1, the command returns
#'   points 5,001–10,000, etc. A vector is also valid (e.g. `0:2` to get the first 3 pages).
#' @param format Format of the output. Can be `"R"` (default), `"sf_lines"` (`"sf"` is a synonym for `"sf_lines"`),
#'   `"sf_points"` or `"gpx"`.
#'
#' @note In violation of the [GPX standard](https://www.topografix.com/GPX/1/1/#type_trksegType) when downloading public
#'   GPX traces through the API, all waypoints of non-trackable traces are randomized (or rather sorted by lat/lon) and
#'   delivered as one trackSegment for privacy reasons. Trackable traces are delivered, sorted by descending upload
#'   time, before the waypoints of non-trackable traces.
#'
#'   Private traces without `name`, `desc` and `url` can be separated in different items in the result if they get
#'   split due to server pagination. Public traces are united using matching URL.
#'
#' @return
#' If `format = "R"`, returns a list of data frames with the points for each trace. For public and identifiable traces,
#' the data frame include the attributes `track_url`, `track_name`, and `track_desc`.
#' If `format = "sf_lines"`, returns a `sf` object from \pkg{sf}. For `format = "sf_points"`, returns a list of `sf`
#' object (see [st_as_sf()] for details).
#'
#' ## `format = "gpx"`
#' Returns a [xml2::xml_document-class] with the following format:
#' ``` xml
#' <?xml version="1.0" encoding="UTF-8"?>
#' <gpx version="1.0" creator="OpenStreetMap.org" xmlns="http://www.topografix.com/GPX/1/0">
#' 	<trk>
#' 		<name>20190626.gpx</name>
#' 		<desc>Footpaths near Blackweir Pond, Epping Forest</desc>
#' 		<url>https://api.openstreetmap.org/user/John%20Leeming/traces/3031013</url>
#' 		<trkseg>
#' 			<trkpt lat="51.6616100" lon="0.0534560">
#' 				<time>2019-06-26T14:27:58Z</time>
#' 			</trkpt>
#' 			...
#' 		</trkseg>
#' 		...
#' 	</trk>
#' 	...
#' </gpx>
#' ```
#' * This response is NOT wrapped in an OSM xml parent element.
#' * The file format is GPX Version 1.0 which is not the current version. Verify that your tools support it.
#'
#' @family get GPS' functions
#' @export
#'
#' @examples
#' pts_gps <- osm_get_points_gps(bbox = c(-0.3667545, 40.2153246, -0.3354263, 40.2364915))
#' ## bbox as a character value also works (bbox = "-0.3667545,40.2153246,-0.3354263,40.2364915").
#' pts_gps
#'
#' ## get attributes
#' lapply(pts_gps, function(x) attributes(x)[c("track_url", "track_name", "track_desc")])
#' attr(pts_gps, "gpx_attributes")
osm_get_points_gps <- function(bbox, page_number = 0, format = c("R", "sf", "sf_lines", "sf_points", "gpx")) {
  format <- match.arg(format)
  if (format == "sf") format <- "sf_lines"
  if (format %in% c("sf_lines", "sf_points")) {
    if (!requireNamespace("sf", quietly = TRUE)) {
      stop("Missing `sf` package. Install with:\n\tinstall.package(\"sf\")")
    }
    .format <- "R"
  } else {
    .format <- format
  }

  bbox <- paste(bbox, collapse = ",")

  if (page_number >= 0) { # concrete pages
    outL <- lapply(page_number, function(x) .osm_get_points_gps(bbox = bbox, page_number = x, format = .format))
  } else { # get all pages
    outL <- list()
    n <- 1
    i <- 1
    while (n > 0) {
      outL[[i]] <- .osm_get_points_gps(bbox = bbox, page_number = i - 1, format = .format)
      if (format %in% c("R", "sf_lines", "sf_points")) {
        n <- length(outL[[i]])
      } else { # format == "gpx"
        n <- length(xml2::xml_children(outL[[i]]))
      }
      i <- i + 1
    }
    if (length(outL) > 1) { # non empty result in the first page
      outL <- outL[-length(outL)]
    }
  }

  if (length(outL) == 1) {
    out <- outL[[1]]
    if (format %in% c("sf_lines", "sf_points")) {
      out <- sf::st_as_sf(out, format = if (format == "sf_lines") "lines" else "points")
    }

    return(out)
  }

  if (format %in% c("R", "sf_lines", "sf_points")) {
    # rbind the last and first trkseg of consecutive pages if they have the same url (non private traces)
    url_1n_page <- lapply(outL, function(x) names(x)[c(1, length(x))])
    # TODO: length(url_1n_page[[i]]) == 1 OR trace divided in > 2 pages
    for (i in seq_along(url_1n_page)[-1]) {
      if (url_1n_page[[i]][1] == url_1n_page[[i - 1]][2] && "" != url_1n_page[[i]][1]) {
        n <- length(outL[[i - 1]])
        if (n == 0) next
        outL[[i - 1]][[n]] <- rbind(outL[[i - 1]][[n]], outL[[i]][[1]])
        outL[[i]][[1]] <- NULL
      }
    }
    outL <- outL[vapply(outL, length, FUN.VALUE = integer(1)) > 0]

    out <- do.call(c, outL)

    attr(out, "gpx_attributes") <- attr(outL[[1]], "gpx_attributes")
    class(out) <- c("osmapi_gpx", "list")

    if (format %in% c("sf_lines", "sf_points")) {
      out <- sf::st_as_sf(out, format = if (format == "sf_lines") "lines" else "points")
    }
  } else { # format == "gpx"
    # unite the last and first trkseg of consecutive pages if they have the same url (non private traces)
    url_1n_page <- lapply(outL, function(x) {
      trkseg <- xml2::xml_children(x)
      trkseg_1n <- trkseg[c(1, length(trkseg))]
      do.call(c, lapply(trkseg_1n, function(y) {
        if ("url" %in% xml2::xml_name(xml2::xml_children(y))) {
          xml2::xml_text(xml2::xml_child(y, search = 3)) # search = "d1:url" is slower 6f0200fb7cd6da044b4cdd5462c16923fbe5caad
        } else {
          ""
        }
      }))
    })

    for (i in seq_along(url_1n_page)[-1]) {
      # TODO: length(url_1n_page[[i]]) == 1 OR trace divided in > 2 pages
      if ("" != url_1n_page[[i]][1] && url_1n_page[[i]][1] == url_1n_page[[i - 1]][2]) {
        n <- xml2::xml_length(outL[[i - 1]])
        part_0 <- xml2::xml_child(outL[[i - 1]], n)
        part_1 <- xml2::xml_child(outL[[i]], 1)
        trkseg_0 <- xml2::xml_child(part_0, search = 4) # TODO: search = "trkseg" fail
        trkseg_1 <- xml2::xml_child(part_1, search = 4) # TODO: search = "trkseg" fail

        lapply(xml2::xml_children(trkseg_1), function(point) {
          xml2::xml_add_child(trkseg_0, point)
        })

        xml2::xml_remove(part_1)
      }
    }

    out <- xml2::xml_new_root(outL[[1]])
    for (i in seq_along(outL[-1]) + 1) {
      lapply(xml2::xml_children(outL[[i]]), function(node) {
        xml2::xml_add_child(out, node)
      })
    }
  }

  return(out)
}
