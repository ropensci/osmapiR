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
#' @param format Format of the output. Can be `"R"` (default), `"osc"` (`"xml"` is a synonym for `"osc"`).
#'
#' @details
#' `x` should be a `osmapi_objects` or follow the same format. Missing tags or tags with `NA` in the value will be
#' removed if `tag_keys` is not specified. See [osm_get_objects()] for examples of the format.
#'
#' @return
#' If `format = "R"`, returns a `osmapi_OsmChange` data frame with one OSM edition per row.
#' If `format = "osc"` or `format = "xml"`, returns a [xml2::xml_document-class] following the
#' [OsmChange format](https://wiki.openstreetmap.org/wiki/OsmChange) that can be saved with [xml2::write_xml()] and
#' opened in other applications such as JOSM.
#'
#' The results are  ready to send the editions to the servers with [osm_diff_upload_changeset()].
#'
#' @family OsmChange's functions
#' @export
#'
#' @examples
#' obj <- osm_get_objects(
#'   osm_type = c("node", "way", "way", "relation", "relation", "node"),
#'   osm_id = c("35308286", "13073736", "235744929", "40581", "341530", "1935675367"),
#'   version = c(1, 3, 2, 5, 7, 1) # Old versions
#' )
#' osmch <- osmchange_modify(obj)
#' osmch
osmchange_modify <- function(x, tag_keys, members = FALSE, lat_lon = FALSE, format = c("R", "osc", "xml")) {
  format <- match.arg(format)
  stopifnot(inherits(x, "osmapi_objects"))

  if (nrow(x) == 0) {
    return(osmchange_empty(format = format))
  }

  if (inherits(x, "tags_wide")) {
    x <- tags_wide2list(x)
  }
  stopifnot(c("type", "id") %in% colnames(x))

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

  mod_members <- members && "members" %in% names(x)
  mod_lat_lon <- lat_lon && "lat" %in% names(x) && "lon" %in% names(x)

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

    if (is.na(osmchange$action_type[i]) && mod_members && !identical(x$members[[i]], osmchange$members[[i]])) {
      osmchange$members[[i]] <- x$members[[i]]
      osmchange$action_type[i] <- "modify"
    }

    if (
      is.na(osmchange$action_type[i]) && mod_lat_lon &&
        !isTRUE(all.equal(x[i, c("lat", "lon")], osmchange[i, c("lat", "lon")], check.attributes = FALSE))
    ) {
      osmchange[i, c("lat", "lon")] <- x[i, c("lat", "lon")]
      osmchange$action_type[i] <- "modify"
    }
  }

  rm <- is.na(osmchange$action_type)
  if (sum(rm) > 0) {
    message(sum(rm), " objects without modifications will be discarded.")
    osmchange <- osmchange[!rm, ]
  }

  if (format == "R") {
    class(osmchange) <- c("osmapi_OsmChange", "osmapi_objects", "data.frame")
  } else {
    osmchange <- osmcha_DF2xml(osmchange)
  }

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
#' @param format Format of the output. Can be `"R"` (default), `"osc"` (`"xml"` is a synonym for `"osc"`).
#'
#' @details
#' If `if-unused` attribute is present, then the delete operation(s) in this block are conditional and will only be
#' executed if the object to be deleted is not used by another object. Without the `if-unused`, such a situation would
#' lead to an error, and the whole diff upload would fail. Setting the attribute will also cause deletions of already
#' deleted objects to not generate an error.
#'
#' @return
#' If `format = "R"`, returns a `osmapi_OsmChange` data frame with one OSM edition per row.
#' If `format = "osc"` or `format = "xml"`, returns a [xml2::xml_document-class] following the
#' [OsmChange format](https://wiki.openstreetmap.org/wiki/OsmChange) that can be saved with [xml2::write_xml()] and
#' opened in other applications such as JOSM.
#'
#' The results are  ready to send the editions to the servers with [osm_diff_upload_changeset()].
#'
#' @family OsmChange's functions
#' @export
#'
#' @examples
#' obj_id <- osmapi_objects(data.frame(
#'   type = c("way", "way", "relation", "node"),
#'   id = c("722379703", "629132242", "8387952", "4739010921")
#' ))
#' osmchange_del <- osmchange_delete(obj_id)
osmchange_delete <- function(x, delete_if_unused = FALSE, format = c("R", "osc", "xml")) {
  format <- match.arg(format)

  if (nrow(x) == 0) {
    return(osmchange_empty(format = format))
  }

  if (inherits(x, "tags_wide")) {
    x <- tags_wide2list(x)
  }
  stopifnot(c("type", "id") %in% colnames(x))

  x_type <- split(x, x$type)
  osmchange <- lapply(x_type, function(y) osm_fetch_objects(osm_type = unique(y$type), osm_ids = y$id))
  osmchange <- do.call(rbind, osmchange[c("relation", "way", "node")]) # sort to avoid deleting members of existing objs
  rownames(osmchange) <- NULL
  osmchange <- cbind(action_type = ifelse(delete_if_unused, "delete if-unused", "delete"), osmchange)

  if (format == "R") {
    class(osmchange) <- c("osmapi_OsmChange", "osmapi_objects", "data.frame")
  } else {
    osmchange <- osmcha_DF2xml(osmchange)
  }

  return(osmchange)
}


#' `osmchange` to create OSM objects
#'
#' Prepare data to create OSM objects.
#'
#' @param x A [osmapi_objects] with columns `type`, `changeset` + column `members` for ways and relations + `lat`
#'   and `lon` for nodes + tags if needed.
#' @param format Format of the output. Can be `"R"` (default), `"osc"` (`"xml"` is a synonym for `"osc"`).
#'
#' @details
#' Objects IDs are unknown and will be allocated by the server. If `id` column is missing in `x`, a negative
#' placeholders will be used. Check [OsmChange page](https://wiki.openstreetmap.org/wiki/OsmChange) for details about
#' how to refer to objects still not created to define the members of relations and nodes of ways.
#'
#' @return
#' If `format = "R"`, returns a `osmapi_OsmChange` data frame with one OSM edition per row.
#' If `format = "osc"` or `format = "xml"`, returns a [xml2::xml_document-class] following the
#' [OsmChange format](https://wiki.openstreetmap.org/wiki/OsmChange) that can be saved with [xml2::write_xml()] and
#' opened in other applications such as JOSM.
#'
#' The results are  ready to send the editions to the servers with [osm_diff_upload_changeset()].
#'
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
osmchange_create <- function(x, format = c("R", "osc", "xml")) {
  format <- match.arg(format)
  stopifnot(inherits(x, "osmapi_objects"))

  if (nrow(x) == 0) {
    return(osmchange_create_empty(format = format))
  }

  if (inherits(x, "tags_wide")) {
    x <- tags_wide2list(x)
  }

  if (!"id" %in% names(x)) {
    x$id <- -seq_len(nrow(x))
  }

  x_type <- split(x, x$type)
  osmchange <- do.call(rbind, x_type[c("node", "way", "relation")]) # sort to avoid creating objs with missing members
  rownames(osmchange) <- NULL
  osmchange <- cbind(action_type = "create", osmchange)

  if (format == "R") {
    class(osmchange) <- c("osmapi_OsmChange", "osmapi_objects", "data.frame")
  } else {
    osmchange <- osmcha_DF2xml(osmchange)
  }

  return(osmchange)
}


osmchange_create_empty <- function(format = "R") {
  out <- list2DF(list(
    action_type = character(), type = character(), id = character(),
    lat = character(), lon = character(), members = list(), tags = list()
  ))
  class(out) <- c("osmapi_OsmChange", "osmapi_objects", "data.frame")

  if (format != "R") {
    out <- osmcha_DF2xml(out)
  }

  return(out)
}


osmchange_empty <- function(format = "R") {
  out <- list2DF(list(
    action_type = character(), type = character(), id = character(), visible = logical(), version = integer(),
    changeset = character(), timestamp = as.POSIXct(character()), user = character(), uid = character(),
    lat = character(), lon = character(), members = list(), tags = list()
  ))
  class(out) <- c("osmapi_OsmChange", "osmapi_objects", "data.frame")

  if (format != "R") {
    out <- osmcha_DF2xml(out)
  }

  return(out)
}
