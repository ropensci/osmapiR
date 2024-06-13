#' Get GPS Points
#'
#' Use this to retrieve the GPS track points that are inside a given bounding box (formatted in a GPX format).
#'
#' @param bbox Coordinates for the area to retrieve the notes from (`left,bottom,right,top`). Floating point numbers in
#'   degrees, expressing a valid bounding box. The maximal width (`right - left`) and height (`top - bottom`) of the
#'   bounding box is 0.25 degree.
#' @param page_number Specifies which groups of 5,000 points, or page, to return. The API call does not return more
#'   than 5,000 points at a time. In order to retrieve all of the points for a bounding box, set `page_number = -1`.
#'   When this parameter is 0 (zero), the command returns the first 5,000 points; when it is 1, the command returns points
#'   5,001–10,000, etc. A vector is also valid (e.g. `0:2` to get the first 3 pages).
#' @param format Format of the output. Can be `"R"` (default) or `"gpx"`.
#'
#' @note In violation of the [GPX standard](https://www.topografix.com/GPX/1/1/#type_trksegType) when downloading public
#'   GPX traces through the API, all waypoints of non-trackable traces are randomized (or rather sorted by lat/lon) and
#'   delivered as one trackSegment for privacy reasons. Trackable traces are delivered, sorted by descending upload
#'   time, before the waypoints of non-trackable traces.
#'
#' @return
#' If `format = "R"`, returns a list of data frames with the points for each trace. For public traces, the data frame
#' include the attributes `name`, `desc` and `url`
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
#' ## bbox as a character value also works. Equivalent call:
#' # pts_gps <- osm_get_points_gps(bbox = "-0.3667545,40.2153246,-0.3354263,40.2364915")
#' pts_gps
#'
#' ## get attributes
#' lapply(pts_gps, function(x) attributes(x)[c("name", "desc", "url")])
osm_get_points_gps <- function(bbox, page_number = 0, format = c("R", "gpx")) {
  format <- match.arg(format)
  bbox <- paste(bbox, collapse = ",")

  if (page_number >= 0) { # concrete pages
    outL <- lapply(page_number, function(x) .osm_get_points_gps(bbox = bbox, page_number = x, format = format))
  } else { # get all pages
    outL <- list()
    n <- 1
    i <- 1
    while (n > 0) {
      outL[[i]] <- .osm_get_points_gps(bbox = bbox, page_number = i - 1, format = format)
      if (format == "R") {
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

  if (format == "R") {
    # TODO: rbind only the last and first trkseg of consecutive pages
    names_1n_page <- lapply(outL, function(x) names(x)[c(1, length(x))])

    ## END TODO

    out <- do.call(c, outL)
    part_trkseg <- which(names(out)[-1] == names(out)[-length(out)]) + 1

    for (i in part_trkseg) {
      out[[i - 1]] <- rbind(out[[i - 1]], out[[i]])
      out[[i]] <- NA # Not NULL to avoid breaking part_trkseg
    }
    out <- out[!vapply(out, function(x) is.atomic(x) && is.na(x), FUN.VALUE = logical(1))]
    class(out) <- c("osmapi_gpx", "list")
  } else { # format == "gpx"
    out <- xml2::xml_new_root(outL[[1]])
    for (i in seq_along(outL[-1]) + 1) {
      lapply(xml2::xml_children(outL[[i]]), function(node) {
        xml2::xml_add_child(out, node)
      })
    }
    ## TODO: unite trkseg parted due to pagination
    # xml2::xml_find_all(xml2::xml_children(out), "//name", flatten = FALSE)
    # lapply(xml2::xml_children(out), function(x) xml2::xml_name(xml2::xml_child(x)))
    # part_trkseg <- which(names(out)[-1] == names(out)[-length(out)]) + 1
  }

  return(out)
}
