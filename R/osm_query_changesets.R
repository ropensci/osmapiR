#' Query changesets
#'
#' This is an API method for querying changesets. It supports querying by different criteria.
#'
#' @param bbox Find changesets within the given bounding box coordinates (`left,bottom,right,top`).
#' @param user Find changesets by the user with the given user id (numeric) or display name (character).
#' @param time Find changesets **closed** after this date and time. See details for the valid formats.
#' @param time_2 find changesets that were **closed** after `time` and **created** before `time_2`. In other words, any
#'   changesets that were open **at some time** during the given time range `time` to `time_2`.  See details for the
#'   valid formats.
#' @param from Find changesets **created** at or after this value. See details for the valid formats.
#' @param to Find changesets **created** before this value. `to` requires `from`, but not vice-versa. If `to` is
#'   provided alone, it has no effect. See details for the valid formats.
#' @param open If `TRUE`, only finds changesets that are still **open** but excludes changesets that are closed or have
#'   reached the element limit for a changeset (10,000 at the moment `osm_capabilities()$api$changesets`).
#' @param closed If `TRUE`, only finds changesets that are **closed** or have reached the element limit.
#' @param changeset_ids Finds changesets with the specified ids.
#' @param order If `"newest"` (default), sort newest changesets first. If `"oldest"`, reverse order.
#' @param limit Specifies the maximum number of changesets returned. 100 as the default value.
#' @param format Format of the output. Can be `"R"` (default), `"sf"`, `"xml"`, or `"json"`.
#' @param tags_in_columns If `FALSE` (default), the tags of the changesets are saved in a single list column `tags`
#'   containing a `data.frame` for each changeset with the keys and values. If `TRUE`, add a column for each key.
#'   Ignored if `format != "R"`.
#'
#' @details
#' Where multiple queries are given the result will be those which match all of the requirements. The contents of the
#' returned document are the changesets and their tags. To get the full set of changes associated with a changeset, use
#' [osm_download_changeset()] on each changeset ID individually.
#'
#' Modification and extension of the basic queries above may be required to support rollback and other uses we find for
#' changesets.
#'
#' This call returns latest changesets matching criteria. The default ordering is newest first, but you can specify
#' `order = "oldest"` to reverse the sort order (see
#' [ordered by `created_at`](https://github.com/openstreetmap/openstreetmap-website/blob/f1c6a87aa137c11d0aff5a4b0e563ac2c2a8f82d/app/controllers/api/changesets_controller.rb#L174)
#' – see the [current state](https://github.com/openstreetmap/openstreetmap-website/blob/master/app/controllers/api/changesets_controller.rb#L174)).
#' Reverse ordering cannot be combined with `time`.
#'
#' Te valid formats for `time`, `time_2`, `from` and `to` parameters are [POSIXt] values or characters with anything
#' that [`Time.parse` Ruby function](https://ruby-doc.org/stdlib-2.7.0/libdoc/time/rdoc/Time.html#method-c-parse) will
#' parse.
#'
#' @return
#' If `format = "R"`, returns a data frame with one OSM changeset per row. If `format = "sf"`, returns a `sf` object
#' from \pkg{sf}.
#'
#' ## `format = "xml"`
#' Returns a [xml2::xml_document-class] with the following format:
#' ``` xml
#' <osm version="0.6" generator="OpenStreetMap server" copyright="OpenStreetMap and contributors" attribution="http://www.openstreetmap.org/copyright" license="http://opendatacommons.org/licenses/odbl/1-0/">
#'   <changeset id="10" created_at="2005-05-01T16:09:37Z" open="false" comments_count="1" changes_count="10" closed_at="2005-05-01T17:16:44Z" min_lat="59.9513092" min_lon="10.7719727" max_lat="59.9561501" max_lon="10.7994537" uid="24" user="Petter Reinholdtsen">
#'     <tag k="created_by" v="JOSM 1.61"/>
#'     <tag k="comment" v="Just adding some streetnames"/>
#'     ...
#'   </changeset>
#'   <changeset ...>
#'     ...
#'   </changeset>
#' </osm>
#' ```
#'
#' ## `format = "json"`
#' *Please note that the JSON format has changed on August 25, 2024 with the release of openstreetmap-cgimap 2.0.0, to*
#' *align it with the existing Rails format.*
#'
#' Returns a list with the following json structure:
#' ``` json
#' {
#'   "version": "0.6",
#'   "generator": "openstreetmap-cgimap 2.0.0 (4003517 spike-08.openstreetmap.org)",
#'   "copyright": "OpenStreetMap and contributors",
#'   "attribution": "http://www.openstreetmap.org/copyright",
#'   "license": "http://opendatacommons.org/licenses/odbl/1-0/",
#'   "changesets": [
#'     {
#'       "id": 10,
#'       "created_at": "2005-05-01T16:09:37Z",
#'       "open": false,
#'       "comments_count": 1,
#'       "changes_count": 10,
#'       "closed_at": "2005-05-01T17:16:44Z",
#'       "min_lat": 59.9513092,
#'       "min_lon": 10.7719727,
#'       "max_lat": 59.9561501,
#'       "max_lon": 10.7994537,
#'       "uid": 24,
#'       "user": "Petter Reinholdtsen",
#'       "tags": {
#'           "comment": "Just adding some streetnames",
#'           "created_by": "JOSM 1.61"
#'       }
#'     },
#'     ...
#'   ]
#' }
#' ```
#'
#' @family get changesets' functions
#' @export
#'
#' @examples
#' chst_ids <- osm_query_changesets(changeset_ids = c(137627129, 137625624))
#' chst_ids
#'
#' chsts <- osm_query_changesets(
#'   bbox = c(-1.241112, 38.0294955, 8.4203171, 42.9186456),
#'   user = "Mementomoristultus",
#'   time = "2023-06-22T02:23:23Z",
#'   time_2 = "2023-06-22T00:38:20Z"
#' )
#' chsts
#'
#' chsts2 <- osm_query_changesets(
#'   bbox = c("-9.3015367,41.8073642,-6.7339533,43.790422"),
#'   user = "Mementomoristultus",
#'   closed = TRUE
#' )
#' chsts2
osm_query_changesets <- function(bbox, user, time, time_2, from, to, open, closed, changeset_ids,
                                 order = c("newest", "oldest"),
                                 limit = getOption("osmapir.api_capabilities")$api$changesets["default_query_limit"],
                                 format = c("R", "sf", "xml", "json"), tags_in_columns = FALSE) {
  format <- match.arg(format)
  order <- match.arg(order)

  .format <- if (format == "sf") "R" else format
  if (format == "sf" && !requireNamespace("sf", quietly = TRUE)) {
    stop("Missing `sf` package. Install with:\n\tinstall.package(\"sf\")")
  }

  if (missing(bbox)) {
    bbox <- NULL
  } else {
    bbox <- paste(bbox, collapse = ",")
  }

  if (missing(user)) {
    user <- NULL
  }

  if (missing(time)) {
    time <- NULL
  }
  if (missing(time_2)) {
    time_2 <- NULL
  }
  stopifnot(is.null(time) && is.null(time_2) || !is.null(time))

  if (missing(from)) {
    from <- NULL
  }
  if (missing(to)) {
    to <- NULL
  }

  if (missing(open)) {
    open <- NULL
  } else {
    if (open) {
      open <- "true"
    } else {
      open <- "false"
    }
  }

  if (missing(closed)) {
    closed <- NULL
  } else {
    if (closed) {
      closed <- "true"
    } else {
      closed <- "false"
    }
  }

  if (missing(changeset_ids)) {
    changeset_ids <- NULL
  } else {
    changeset_ids <- paste(changeset_ids, collapse = ",")
  }

  if (order == "newest") {
    order <- NULL
  }

  if (!is.null(order) && !is.null(time)) {
    stop("Cannot use `order = \"oldest\"` with `time` parameter.")
    # Avoid API error:
    # ! HTTP 400 Bad Request.
    # • cannot use order=oldest with time
  }

  if (limit <= getOption("osmapir.api_capabilities")$api$changesets["maximum_query_limit"]) { # no batch needed
    out <- .osm_query_changesets(
      bbox = bbox, user = user, time = time, time_2 = time_2, from = from, to = to, open = open, closed = closed,
      changeset_ids = changeset_ids, order = order, limit = limit, format = .format, tags_in_columns = tags_in_columns
    )

    if (format == "sf") {
      out <- sf::st_as_sf(out)
    }

    return(out)
  } else if (!is.null(order)) {
    stop(
      "Cannot use `order = \"oldest\"` with `limit` > ",
      getOption("osmapir.api_capabilities")$api$changesets["maximum_query_limit"], "."
    )
    # Avoid API error:
    # ! HTTP 400 Bad Request.
    # • cannot use order=oldest with time
  }

  outL <- list()
  n_out <- 0
  n <- 1
  i <- 1
  if (is.null(time) && is.null(order)) { # order == "newest"
    time <- "2005-04-09T20:54:39Z" # osm_get_changesets(changeset_id = 1)$closed_at
  }

  ## TODO: simplify and split in different functions ----
  while (n_out < limit && n > 0) {
    outL[[i]] <- .osm_query_changesets(
      bbox = bbox, user = user, time = time, time_2 = time_2, from = from, to = to, open = open, closed = closed,
      changeset_ids = changeset_ids, order = order,
      limit = min(limit - n_out, getOption("osmapir.api_capabilities")$api$changesets["maximum_query_limit"]),
      format = .format, tags_in_columns = FALSE
    )

    if (.format == "R") {
      n <- nrow(outL[[i]])
      time_2 <- outL[[i]]$created_at[n]
    } else if (.format == "xml") {
      n <- length(xml2::xml_children(outL[[i]]))
      time_2 <- xml2::xml_attr(xml2::xml_child(outL[[i]], n), attr = "created_at")
      time_2 <- as.POSIXct(time_2, format = "%Y-%m-%dT%H:%M:%OS", tz = "GMT") ## TODO: needed?
    } else if (.format == "json") {
      n <- length(outL[[i]]$changesets)
      time_2 <- outL[[i]]$changesets[[n]]$created_at
      time_2 <- as.POSIXct(time_2, format = "%Y-%m-%dT%H:%M:%OS", tz = "GMT") ## TODO: needed?
    }

    n_out <- n_out + n
    i <- i + 1
  }

  if (.format == "R") {
    out <- do.call(rbind, outL)
    if (tags_in_columns) {
      out <- tags_list2wide(out)
    }
    if (format == "sf") {
      out <- sf::st_as_sf(out)
    }
  } else if (.format == "xml") {
    out <- xml2::xml_new_root(outL[[1]])
    for (i in seq_along(outL[-1])) {
      for (j in seq_len(length(xml2::xml_children(outL[[i + 1]])))) {
        xml2::xml_add_child(out, xml2::xml_child(outL[[i + 1]], search = j))
      }
    }
  } else if (.format == "json") {
    out <- outL[[1]]
    for (i in seq_along(outL[-1])) {
      out$changesets <- c(out$changesets, outL[[i + 1]]$changesets)
    }
  }

  return(out)
}
