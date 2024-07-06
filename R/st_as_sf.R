#' Convert osmapiR objects to sf objects
#'
#' @param x an osmapiR object.
#' @param format Format of the output. If `"line"` (the default), return a `sf` object with one `LINESTRING`.
#'   If `"points"`, return a `sf` with the `POINT`s of the track as features. See below for details.
#' @param ... passed on to `st_as_sf()` from \pkg{sf} package.
#'
#' @return Returns a `sf` object from \pkg{sf} package.
#'
#'   When x is a `osmapi_gps_track` object and `format = "line"`, the result will have `XYZM` dimensions for
#'   coordinates, elevation and time (will loss the POSIXct type) if available. For `format = "points"`, the result will
#'   have `XY` dimensions and elevation and time will be independent columns if available.
#'
#' @family methods
#' @seealso `st_as_sf()` from \pkg{sf} package.
#' @examples
#' \dontrun{
#' trk <- osm_get_data_gpx(gpx_id = 3498170, format = "R")
#' st_as_sf(trk, format = "line")
#' st_as_sf(trk, format = "points")
#' }
#'
#' @name st_as_sf
NULL


#' @rdname st_as_sf
#' @export
st_as_sf.osmapi_map_notes <- function(x, ...) {
  if (nrow(x) == 0) {
    suppressWarnings(out <- sf::st_as_sf(x = as.data.frame(x), coords = c("lon", "lat"), crs = sf::st_crs(4326)), ...)
  } else {
    out <- sf::st_as_sf(x = as.data.frame(x), coords = c("lon", "lat"), crs = sf::st_crs(4326), ...)
    class(out) <- c("sf_osmapi_map_notes", "sf", "data.frame")
  }
  # TODO: mapview::mapview(out) -> Error in clean_columns(as.data.frame(obj), factorsAsCharacter) :
  #   list columns are only allowed with raw vector contents

  return(out)
}


#' @rdname st_as_sf
#' @export
st_as_sf.osmapi_changesets <- function(x, ...) {
  out <- x[, setdiff(names(x), c("min_lat", "min_lon", "max_lat", "max_lon"))]

  if (nrow(x) == 0) {
    out[1, 1] <- NA
    out$geometry <- sf::st_sfc(sf::st_polygon(), crs = sf::st_crs(4326))
    out <- sf::st_as_sf(x = as.data.frame(out[integer(), ]), crs = sf::st_crs(4326), ...)
    return(out)
  }

  bbox <- apply(x[, c("min_lat", "min_lon", "max_lat", "max_lon")], 1, function(y) {
    sf::st_bbox(stats::setNames(as.numeric(y), nm = c("ymin", "xmin", "ymax", "xmax")), crs = sf::st_crs(4326))
  }, simplify = FALSE)
  geom <- do.call(sf::st_as_sfc, bbox)
  out$geometry <- geom

  out <- sf::st_as_sf(x = as.data.frame(out), crs = sf::st_crs(4326), ...)
  class(out) <- c("sf_osmapi_changesets", "sf", "data.frame")

  return(out)
}


#' @rdname st_as_sf
#'
#' @export
st_as_sf.osmapi_gps_track <- function(x, format = c("line", "points"), ...) {
  format <- match.arg(format)

  if (nrow(x) == 0) {
    out <- x[, setdiff(names(x), c("lon", "lat"))]
    out[1, 1] <- NA
    out$geometry <- sf::st_sfc(sf::st_polygon(), crs = sf::st_crs(4326))
    out <- sf::st_as_sf(x = as.data.frame(out[integer(), ]), crs = sf::st_crs(4326), ...)

    return(out)
  }

  if (format == "line") {
    x_num <- list2DF(lapply(x, as.numeric))
    x_num <- x_num[, intersect(c("lon", "lat", "ele", "time"), names(x_num))] # sort XYZM columns
    geometry <- sf::st_sfc(sf::st_linestring(x = as.matrix(x_num)), crs = sf::st_crs(4326))

    out <- sf::st_as_sf(x = data.frame(geometry), crs = sf::st_crs(4326), ...)
  } else if (format == "points") {
    out <- sf::st_as_sf(x = as.data.frame(x), coords = c("lon", "lat"), crs = sf::st_crs(4326), ...)
  }

  return(out)
}
