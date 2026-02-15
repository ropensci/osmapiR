#' Convert a named matrix or a named or unnamed vector to a bbox string
#'
#' This function converts a bounding box into a string for use in web api calls
#'
#' @param bbox bounding box in degrees as character, matrix, vector, `bbox` object from \pkg{sf}, a `SpatExtent` from
#'   \pkg{terra}. Unnamed vectors and matrices will be sorted appropriately and must merely be in the order (x, y, x, y)
#'   or x in the first column and y in the second column.
#'
#' @return A character string representing the left, bottom, right, top bounds. For example:
#' "-1.241112,38.0294955,8.4203171,42.9186456" is the bounding box for the Catalan Countries.
#'
#' @note function adapted from osmdata package.
#' @noRd
#'
#' @examples
#' bb <- c(xmin = -1.241112, ymin = 38.0294955, xmax = 8.4203171, ymax = 42.9186456)
#' bbox_to_string(bb)
#' bb <- c(ymin = 38.0294955, xmin = -1.241112, ymax = 42.9186456, xmax = 8.4203171)
#' bbox_to_string(bb)
bbox_to_string <- function(bbox) {
  if (is.null(bbox)) {
    return(NULL)
  }

  if (inherits(bbox, "matrix")) {
    if (nrow(bbox) > 2) {
      bbox <- apply(bbox, 2, range)
    }

    if (all(c("x", "y") %in% tolower(rownames(bbox))) & all(c("min", "max") %in% tolower(colnames(bbox)))) {
      bbox <- c(
        bbox["x", "min"], bbox["y", "min"],
        bbox["x", "max"], bbox["y", "max"]
      )
    } else if (all(c("coords.x1", "coords.x2") %in% rownames(bbox)) & all(c("min", "max") %in% colnames(bbox))) {
      bbox <- c(
        bbox["coords.x1", "min"], bbox["coords.x2", "min"],
        bbox["coords.x1", "max"], bbox["coords.x2", "max"]
      )
    } else {
      # otherwise just presume (x,y) are columns and order the rows
      bbox <- c(
        min(bbox[, 1]), min(bbox[, 2]),
        max(bbox[, 1]), max(bbox[, 2])
      )
    }
  } else if (is.numeric(bbox)) {
    if (length(bbox) < 4) {
      stop("bbox must contain four elements")
    } else if (length(bbox) > 4) {
      message("only the first four elements of bbox used")
    }

    if (!is.null(names(bbox))) {
      if (all(names(bbox) %in% c("left", "bottom", "right", "top"))) {
        bbox <- bbox[c("left", "bottom", "right", "top")]
      } else if (all(names(bbox) %in% c("xmin", "xmax", "ymin", "ymax"))) { # sf::st_bbox()
        bbox <- bbox[c("xmin", "ymin", "xmax", "ymax")]
      }
    } else { # assume c(xmin, ymin, xmax, ymax)
      x <- sort(bbox[c(1, 3)])
      y <- sort(bbox[c(2, 4)])
      bbox <- c(x[1], y[1], x[2], y[2])
    }
  } else if (inherits(bbox, "SpatExtent")) { # terra::ext()
    bbox <- bbox@pntr$vector # equivalent to as.vector(bbox) but without depending on terra pkg
  }

  return(paste0(bbox, collapse = ","))
}
