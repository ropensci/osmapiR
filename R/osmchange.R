#' Modify existing OSM objects
#'
#' Update tags, members and/or latitude and longitude.
#'
#' @param x A `data.frame` with the columns `type` and `id`.
#' @param tag_keys A character vector with the keys of the tags that will be modified. If missing (default),
#'   all tags will be updated, removed or created (doesn't work for `x` with tags in a wide format). If `FALSE`, don't
#'   modify tags.
#' @param members If `TRUE` and `x` has a `members` column, update the members of the ways and relations objects.
#' @param lat_lon If `TRUE` and `x` has a `lat` and `lon` columns, update the coordinates of the node objects.
#'
#' @details
#' `x` should follow the format of `osmapi_objects` with tags in wide format or a `tags` column with a list of
#' data.frames with `key` and `value` columns. Missing tags or tags with `NA` in the value will be removed. See
#' [osm_read_object()] for examples of the format.
#'
#' @return
#' @family OsmChange's functions
#' @export
#'
#' @examples
osmchange_modify <- function(x, tag_keys, members = FALSE, lat_lon = FALSE) {
  if (inherits(x, "tags_wide")) {
    x <- tags_wide2list(x)
  }

  if ("tags" %in% names(x)) {
    if (missing(tag_keys)) { # Update all tags
      tags_upd <- x$tags
    } else { # Update only tag_keys
      tags_upd <- lapply(x$tags, function(y) {
        y[y$key %in% tag_keys, ]
      })
    }
  } else if (!"tags" %in% names(x) && all(tag_keys %in% names(x))) { # Tags in wide format and all tag_keys in columns
    tags_upd <- list()
    for (i in seq_len(nrow(x))) {
      tags_upd[[i]] <- data.frame(key = tag_keys, value = as.character(x[i, tag_keys]))
    }
  } else if (is.logical(tag_keys) && !tag_keys) { # Don't update tags
    tags_upd <- FALSE
  } else {
    stop(
      "Specify `tag_keys` or pass `x` with a tag column with a list of data.frames with all tags. ",
      "To omit tags, set parameter `tag_keys = FALSE`."
    )
  }

  x_type <- split(x, x$type)
  x_osm <- lapply(x_type, function(y) osm_fetch_objects(osm_type = unique(y$type), osm_ids = y$id))
  x_osm <- do.call(rbind, x_osm)

  x_uid <- do.call(paste, x[, c("type", "id")])
  osm_uid <- do.call(paste, x_osm[, c("type", "id")])
  x_osm <- x_osm[match(x_uid, osm_uid), ]
  rownames(x_osm) <- rownames(x)

  osmchange <- x_osm
  osmchange$action_type <- NA_character_

  if (members && "members" %in% names(x)) {
    osmchange$members <- x$members
  }

  if (lat_lon && "lat_lon" %in% names(x)) {
    osmchange[, c("lat", "lon")] <- x[, c("lat", "lon")]
  }

  for (i in seq_len(nrow(x))) {
    if (!isFALSE(tags_upd)) {
      tags <- osmchange$tags[[i]]
      tags <- tags[!tags$key %in% tag_keys, ]
      tags <- rbind(tags, stats::na.omit(tags_upd[[i]]))

      if (!identical(tags, osmchange$tags[[i]])) {
        osmchange$tags[[i]] <- tags
        osmchange$action_type[i] <- "modify"
      }
    }

    if (is.na(osmchange$action_type[i]) && members && !identical(x$members[[i]], osmchange$members[[i]])) {
      osmchange$action_type[i] <- "modify"
    }

    if (is.na(osmchange$action_type[i]) && lat_lon && !identical(x[, c("lat", "lon")], osmchange[, c("lat", "lon")])) {
      osmchange$action_type[i] <- "modify"
    }
  }

  class(osmchange) <- unique(c("osmapi_OsmChange", class(osmchange)))

  rm <- is.na(osmchange$action_type)

  if (sum(rm) > 0) {
    message(sum(rm), " objects without modificacions will be discarded.")
    osmchange <- osmchange[!rm, ]
  }

  return(osmchange)
}


#' Delete existing OSM objects
#'
#' @param x A `data.frame` with the columns `type` and `id`.
#' @param delete_if_unused If `TRUE` (default), the `if-unused` attribute will be added. Can be a vector of length
#'   `nrow(x)`.
#'
#' @details
#' If `if-unused` attribute is present, then the delete operation(s) in this block are conditional and will only be
#' executed if the object to be deleted is not used by another object. Without the ⁠if-unused⁠, such a situation would
#' lead to an error, and the whole diff upload would fail. Setting the attribute will also cause deletions of already
#' deleted objects to not generate an error.
#'
#' @return
#' @family OsmChange's functions
#' @export
#'
#' @examples
osmchange_delete <- function(x, delete_if_unused = TRUE) {
  x_type <- split(x, x$type)
  osmchange <- lapply(x_type, function(y) osm_fetch_objects(osm_type = unique(y$type), osm_ids = y$id))
  osmchange <- do.call(rbind, osmchange[c("relation", "way", "node")]) # sort to avoid deleting members of existing objs

  rownames(osmchange) <- NULL

  osmchange$action_type <- ifelse(delete_if_unused, "delete if-unused", "delete")

  class(osmchange) <- unique(c("osmapi_OsmChange", class(osmchange)))

  return(osmchange)
}


## TODO: osmchange_create

osmchange_create <- function(x) {

}
