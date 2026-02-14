#' Convert osmapiR objects to sf objects
#'
#' @param x an osmapiR object.
#' @param format Format of the output. If `"line"` (the default), return a `sf` object with one `LINESTRING` for each
#'   track. If `"points"`, return a `sf` with the `POINT`s of the track as features. See below for details.
#' @param ... passed on to `st_as_sf()` from \pkg{sf} package.
#'
#' @return Returns a `sf` object from \pkg{sf} package or a list of for `osmapi_gpx` and `format = "points"`.
#'
#'   When x is a `osmapi_gps_track` or `osmapi_gpx` object and `format = "line"`, the result will have `XYZM` dimensions
#'   for coordinates, elevation and time if available. In this format, time will loss the POSIXct type as only numeric
#'   values are allowed.
#'   For `format = "points"`, the result will have `XY` dimensions and elevation and time will be independent columns if
#'   available.
#'
#' @family methods
#' @seealso `st_as_sf()` from \pkg{sf} package.
#' @examples
#' note <- osm_get_notes(note_id = "2067786")
#' sf::st_as_sf(note)
#'
#' chaset <- osm_get_changesets(changeset_id = 137595351, include_discussion = TRUE)
#' sf::st_as_sf(chaset)
#'
#' gpx <- osm_get_points_gps(bbox = c(-0.3667545, 40.2153246, -0.3354263, 40.2364915))
#' sf::st_as_sf(gpx, format = "line")
#' sf::st_as_sf(gpx, format = "points")
#'
#' \dontrun{
#' # Requires authentication
#' trk <- osm_get_data_gpx(gpx_id = 3498170, format = "R")
#' sf::st_as_sf(trk, format = "line")
#' sf::st_as_sf(trk, format = "points")
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
  geom <- lapply(bbox, function(bb) {
    if (anyNA(bb[1:4])) {
      sf::st_sfc(sf::st_polygon(), crs = sf::st_crs(4326))
    } else {
      sf::st_as_sfc(bb)
    }
  })
  out$geometry <- do.call(c, geom)

  out <- sf::st_as_sf(x = as.data.frame(out), crs = sf::st_crs(4326), ...)
  class(out) <- c("sf_osmapi_changesets", "sf", "data.frame")

  return(out)
}


#' @rdname st_as_sf
#' @export
st_as_sf.osmapi_gps_track <- function(x, format = c("line", "points"), ...) {
  format <- match.arg(format)

  trk_attr <- attributes(x)
  trk_attr <- trk_attr[setdiff(names(trk_attr), c("names", "row.names", "class"))]

  if (nrow(x) == 0) {
    out <- x[, setdiff(names(x), c("lon", "lat"))]
    out[1, 1] <- NA
    out$geometry <- sf::st_sfc(sf::st_polygon(), crs = sf::st_crs(4326))
    out <- sf::st_as_sf(x = as.data.frame(out[integer(), ]), crs = sf::st_crs(4326), ...)

    attributes(out) <- c(attributes(out), trk_attr)

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

  attributes(out) <- c(attributes(out), trk_attr)

  return(out)
}


#' @rdname st_as_sf
#' @export
st_as_sf.osmapi_gpx <- function(x, format = c("lines", "points"), ...) {
  format <- match.arg(format)

  attr_names <- c("track_url", "track_name", "track_desc")

  if (length(x) == 0) {
    if (format == "points") {
      out <- list()
      class(out) <- c("sf_osmapi_gpx", "osmapi_gpx", "list")
    } else { # format == "lines"
      out <- list2DF(stats::setNames(rep(list(NA), 3L), nm = attr_names))
      out$geometry <- sf::st_sfc(sf::st_linestring(), crs = sf::st_crs(4326))
      out <- sf::st_as_sf(x = as.data.frame(out[integer(), ]), crs = sf::st_crs(4326), ...)
    }

    attr(out, "gpx_attributes") <- attr(x, "gpx_attributes")

    return(out)
  }


  if (format == "lines") {
    geometry <- lapply(x, function(trk) {
      x_num <- list2DF(lapply(trk, as.numeric))
      x_num <- x_num[, intersect(c("lon", "lat", "time"), names(x_num))] # sort XYM columns
      sf::st_sfc(
        sf::st_linestring(x = as.matrix(x_num), dim = if (ncol(x_num) == 3) "XYM" else "XY"),
        crs = sf::st_crs(4326)
      )
    })
    geometry <- do.call(c, geometry)

    track_attributes <- vapply(x, function(trk) {
      trk_attr <- attributes(trk)
      # attr_names <- grep("^track_", names(trk_attr), value = TRUE)
      a <- stats::setNames(rep(NA_character_, 3), nm = attr_names)
      sel <- intersect(attr_names, names(trk_attr))
      if (length(sel)) {
        a[sel] <- unlist(trk_attr[sel])
      }
      a
    }, FUN.VALUE = character(3))
    track_attributes <- as.data.frame(t(track_attributes))
    rownames(track_attributes) <- NULL

    track_attributes$geometry <- geometry
    out <- sf::st_as_sf(x = track_attributes, crs = sf::st_crs(4326), ...)
  } else if (format == "points") {
    out <- lapply(x, function(trk) {
      trk_attr <- attributes(trk)
      trk_attr <- trk_attr[setdiff(names(trk_attr), c("names", "row.names", "class"))]
      trk <- sf::st_as_sf(x = as.data.frame(trk), coords = c("lon", "lat"), crs = sf::st_crs(4326), ...)
      attributes(trk) <- c(attributes(trk), trk_attr)
      trk
    })
    class(out) <- c("sf_osmapi_gpx", "osmapi_gpx", "list")
  }

  attr(out, "gpx_attributes") <- attr(x, "gpx_attributes")

  return(out)
}
