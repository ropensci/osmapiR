#' Convert osmapiR objects to sf objects
#'
#' @param x an osmapiR object.
#' @param ... passed on to `st_as_sf()` from \pkg{sf}.
#'
#' @return Returns a `sf` object from \pkg{sf}.
#' @family methods
#' @seealso `st_as_sf()` from \pkg{sf}
#'
#' @name st_as_sf
NULL


#' @rdname st_as_sf
#' @export
st_as_sf.osmapi_map_notes <- function(x, ...) {
  if (nrow(x) == 0) {
    suppressWarnings(out <- sf::st_as_sf(x = as.data.frame(x), coords = c("lon", "lat"), crs = sf::st_crs(4326)))
  } else {
    out <- sf::st_as_sf(x = as.data.frame(x), coords = c("lon", "lat"), crs = sf::st_crs(4326))
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
    out <- sf::st_as_sf(x = as.data.frame(out[integer(), ]), crs = sf::st_crs(4326))
    return(out)
  }

  bbox <- apply(x[, c("min_lat", "min_lon", "max_lat", "max_lon")], 1, function(y) {
    sf::st_bbox(stats::setNames(as.numeric(y), nm = c("ymin", "xmin", "ymax", "xmax")), crs = sf::st_crs(4326))
  }, simplify = FALSE)
  geom <- do.call(sf::st_as_sfc, bbox)
  out$geometry <- geom

  out <- sf::st_as_sf(x = as.data.frame(out), crs = sf::st_crs(4326))
  class(out) <- c("sf_osmapi_changesets", "sf", "data.frame")

  return(out)
}

