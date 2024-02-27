#' `osmchange` to modify existing OSM objects
#'
#' Prepare data to update tags, members and/or latitude and longitude.
#'
#' @param x A [osmapi_objects] with the columns `type` and `id` with unique combinations of values plus columns
#'   specifying tags, members or latitude and longitude.
#' @param tag_keys A character vector with the keys of the tags that will be modified. If missing (default),
#'   all tags will be updated, removed or created. If `FALSE`, don't modify tags.
#' @param members If `TRUE` and `x` has a `members` column, update the members of the ways and relations objects.
#' @param lat_lon If `TRUE` and `x` has a `lat` and `lon` columns, update the coordinates of the node objects.
#'
#' @details
#' `x` should be a `osmapi_objects` or follow the same format. Missing tags or tags with `NA` in the value will be
#' removed if `tag_keys` is not specified. See [osm_get_objects()] for examples of the format.
#'
#' @return Returns a `osmapi_OsmChange` data frame with one OSM object per row ready to send the editions to the servers
#'   with [osm_diff_upload_changeset()].
#' @family OsmChange's functions
#' @export
#'
#' @examples
#' \dontrun{
#' obj <- osm_get_objects(
#'   osm_type = c("node", "way", "way", "relation", "relation", "node"),
#'   osm_id = c("35308286", "13073736", "235744929", "40581", "341530", "1935675367"),
#'   version = c(1, 3, 2, 5, 7, 1) # Old versions
#' )
#' osmch <- osmchange_modify(obj)
#' osmch
#' }
osmchange_modify <- function(x, tag_keys, members = FALSE, lat_lon = FALSE) {
  stopifnot(inherits(x, "osmapi_objects"))
  if (inherits(x, "tags_wide")) {
    x <- tags_wide2list(x)
  }

  if (missing(tag_keys)) { # Update all tags
    tags_upd <- x$tags
  } else if (is.logical(tag_keys) && !tag_keys) { # Don't update tags
    tags_upd <- FALSE
  } else { # Update only tag_keys
    tags_upd <- lapply(x$tags, function(y) {
      y[y$key %in% tag_keys, ]
    })
  }

  x_type <- split(x, x$type)
  x_osm <- lapply(x_type, function(y) osm_fetch_objects(osm_type = unique(y$type), osm_ids = y$id))
  x_osm <- do.call(rbind, x_osm)

  x_uid <- do.call(paste, x[, c("type", "id")])
  osm_uid <- do.call(paste, x_osm[, c("type", "id")])
  x_osm <- x_osm[match(x_uid, osm_uid), ]

  osmchange <- x_osm
  osmchange <- cbind(action_type = NA_character_, osmchange)
  attr(osmchange, "row.names") <- attr(x, "row.names")
  class(osmchange) <- class(x_osm)

  if (members && "members" %in% names(x)) {
    osmchange$members <- x$members
  }

  if (lat_lon && "lat" %in% names(x) && "lon" %in% names(x)) {
    osmchange[, c("lat", "lon")] <- x[, c("lat", "lon")]
  }

  for (i in seq_len(nrow(x))) {
    if (!isFALSE(tags_upd)) {
      if (missing(tag_keys)) {
        tags <- tags_upd[[i]]
      } else {
        tags <- osmchange$tags[[i]]
        tags <- tags[!tags$key %in% tag_keys, ] # remove tags in tag_keys with no value or NA
        tags <- rbind(tags, stats::na.omit(tags_upd[[i]]))
      }

      tags_osm <- osmchange$tags[[i]]
      tags_osm <- tags_osm[order(tags_osm$key), ]
      chng <- !isTRUE(all.equal(tags[order(tags$key), ], tags_osm, check.attributes = FALSE))
      if (chng) {
        osmchange$tags[[i]] <- tags
        osmchange$action_type[i] <- "modify"
      }
    }

    if (is.na(osmchange$action_type[i]) && members && !identical(x$members[[i]], osmchange$members[[i]])) {
      osmchange$action_type[i] <- "modify"
    }

    if (
      is.na(osmchange$action_type[i]) && lat_lon &&
        !isTRUE(all.equal(x[i, c("lat", "lon")], osmchange[i, c("lat", "lon")], check.attributes = FALSE))
    ) {
      osmchange$action_type[i] <- "modify"
    }
  }

  rm <- is.na(osmchange$action_type)
  if (sum(rm) > 0) {
    message(sum(rm), " objects without modifications will be discarded.")
    osmchange <- osmchange[!rm, ]
  }

  class(osmchange) <- c("osmapi_OsmChange", "osmapi_objects", "data.frame")

  return(osmchange)
}


#' `osmchange` to delete existing OSM objects
#'
#' Prepare data to delete OSM objects.
#'
#' @param x A [osmapi_objects] or `data.frame` with the columns `type` and `id` for the objects to delete. Other columns
#'   will be ignored.
#' @param delete_if_unused If `TRUE`, the `if-unused` attribute will be added (see details). Can be a vector of length
#'   `nrow(x)`.
#'
#' @details
#' If `if-unused` attribute is present, then the delete operation(s) in this block are conditional and will only be
#' executed if the object to be deleted is not used by another object. Without the `if-unused`, such a situation would
#' lead to an error, and the whole diff upload would fail. Setting the attribute will also cause deletions of already
#' deleted objects to not generate an error.
#'
#' @return Returns a `osmapi_OsmChange` data frame with one OSM object per row ready to send the editions to the servers
#'   with [osm_diff_upload_changeset()].
#' @family OsmChange's functions
#' @export
#'
#' @examples
#' \dontrun{
#' obj_id <- osmapi_objects(data.frame(
#'   type = c("way", "way", "relation", "node"),
#'   id = c("722379703", "629132242", "8387952", "4739010921")
#' ))
#' osmchange_del <- osmchange_delete(obj_id)
#' }
osmchange_delete <- function(x, delete_if_unused = FALSE) {
  if (inherits(x, "tags_wide")) {
    x <- tags_wide2list(x)
  }
  x_type <- split(x, x$type)
  osmchange <- lapply(x_type, function(y) osm_fetch_objects(osm_type = unique(y$type), osm_ids = y$id))
  osmchange <- do.call(rbind, osmchange[c("relation", "way", "node")]) # sort to avoid deleting members of existing objs
  rownames(osmchange) <- NULL
  osmchange <- cbind(action_type = ifelse(delete_if_unused, "delete if-unused", "delete"), osmchange)

  class(osmchange) <- c("osmapi_OsmChange", "osmapi_objects", "data.frame")

  return(osmchange)
}


#' `osmchange` to create OSM objects
#'
#' Prepare data to create OSM objects.
#'
#' @param x A [osmapi_objects] with columns `type`, `changeset` + column `members` for ways and relations + `lat`
#'   and `lon` for nodes + tags if needed.
#'
#' @details
#' Objects IDs are unknown and will be allocated by the server. Check
#' [OsmChange page](https://wiki.openstreetmap.org/wiki/OsmChange) for details about how to refer to objects still not
#' created to define the members of relations and nodes of ways.
#'
#' @return Returns a `osmapi_OsmChange` data frame with one OSM object per row ready to send the editions to the servers
#'   with [osm_diff_upload_changeset()].
#' @family OsmChange's functions
#' @export
#'
#' @examples
#' d <- data.frame(
#'   type = c("node", "node", "way", "relation"),
#'   id = -(1:4),
#'   lat = c(0, 1, NA, NA),
#'   lon = c(0, 1, NA, NA),
#'   name = c(NA, NA, "My way", "Our relation"),
#'   type.1 = c(NA, NA, NA, "Column clash!")
#' )
#' d$members <- list(
#'   NULL, NULL, -(1:2),
#'   matrix(
#'     c("node", "-1", NA, "node", "-2", NA, "way", "-3", "outer"),
#'     nrow = 3, ncol = 3, byrow = TRUE, dimnames = list(NULL, c("type", "ref", "role"))
#'   )
#' )
#' obj <- osmapi_objects(d, tag_columns = c(name = "name", type = "type.1"))
#' osmcha <- osmchange_create(obj)
#' osmcha
osmchange_create <- function(x) {
  stopifnot(inherits(x, "osmapi_objects"))
  if (inherits(x, "tags_wide")) {
    x <- tags_wide2list(x)
  }

  x_type <- split(x, x$type)
  osmchange <- do.call(rbind, x_type[c("node", "way", "relation")]) # sort to avoid creating objs with missing members
  rownames(osmchange) <- NULL
  osmchange <- cbind(action_type = "create", osmchange)

  class(osmchange) <- c("osmapi_OsmChange", "osmapi_objects", "data.frame")

  return(osmchange)
}
