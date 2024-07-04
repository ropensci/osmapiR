#' Convert osmapiR objects to sf objects
#'
#' @param x an osmapiR object.
#' @param ... passed on to `st_sf` form \pkg{sf}.
#'
#' @return Returns a \code{sf} object from \pkg{sf}.
#' @family methods
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
