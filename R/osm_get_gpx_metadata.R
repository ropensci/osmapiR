# Vectorized version of .osm_get_metadata_gpx()

#' Download GPS Track Metadata
#'
#' Use this to access the metadata about GPX files. Available without authentication if the file is marked public.
#' Otherwise only usable by the owner account and requires authentication.
#'
#' @param gpx_id A vector of track ids represented by a numeric or a character value.
#' @param format Format of the output. Can be `"R"` (default), `"sf"`, `"xml"`, or `"json"`.
#'
#' @return
#' If `format = "R"`, returns a data frame with one trace per row. If `format = "sf"`, returns a `sf` object from
#' \pkg{sf}. If `format = "xml"`, returns a [xml2::xml_document-class] with the following format:
#' ```xml
#' <?xml version="1.0" encoding="UTF-8"?>
#' <osm version="0.6" generator="OpenStreetMap server">
#'   <gpx_file id="836619" name="track.gpx" lat="52.0194" lon="8.51807" uid="1234" user="Hartmut Holzgraefe" visibility="public" pending="false" timestamp="2010-10-09T09:24:19Z">
#'     <description>PHP upload test</description>
#'     <tag>test</tag>
#'     <tag>php</tag>
#'   </gpx_file>
#'   <gpx_file>
#'     ...
#'   </gpx_file>
#' </osm>
#' ```
#' If `format = "json"`, returns a list with the json structure.
#' @family get GPS' functions
#' @export
#'
#' @examples
#' \dontrun{
#' trk_meta <- osm_get_gpx_metadata(gpx_id = 3498170)
#' trk_meta
#' }
osm_get_gpx_metadata <- function(gpx_id, format = c("R", "sf", "xml", "json")) {
  format <- match.arg(format)
  .format <- if (format == "sf") "R" else format
  if (format == "sf" && !requireNamespace("sf", quietly = TRUE)) {
    stop("Missing `sf` package. Install with:\n\tinstall.package(\"sf\")")
  }

  if (length(gpx_id) == 1) {
    out <- .osm_get_metadata_gpx(gpx_id = gpx_id, format = .format)
  } else {
    outL <- lapply(gpx_id, function(id) {
      .osm_get_metadata_gpx(gpx_id = id, format = .format)
    })

    if (.format == "R") {
      out <- do.call(rbind, outL)
    } else if (.format == "xml") {
      out <- xml2::xml_new_root(outL[[1]])
      for (i in seq_along(outL[-1]) + 1) {
        lapply(xml2::xml_children(outL[[i]]), function(node) {
          xml2::xml_add_child(out, node)
        })
      }
    } else if (.format == "json") {
      out <- outL[[1]]
      out$traces <- lapply(outL, function(x) x$trace)
      out$trace <- NULL
    }
  }

  if (format == "sf") {
    out <- sf::st_as_sf(out, coords = c("lon", "lat"), crs = sf::st_crs(4326))
  }

  return(out)
}
