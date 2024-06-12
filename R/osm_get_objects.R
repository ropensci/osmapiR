#' Get OSM objects
#'
#' Retrieve objects by `type`, `id` and `version`.
#'
#' @param osm_type A vector with the type of the objects (`"node"`, `"way"` or `"relation"`). Recycled if it has a
#'   different length than `osm_id`.
#' @param osm_id Object ids represented by a numeric or a character vector.
#' @param version An optional vector with the version number for each object. If missing, the last version will be
#'   retrieved. Recycled if it has different length than `osm_id`.
#' @param full_objects If `TRUE`, retrieves all other objects referenced by ways or relations. Not compatible with
#'   `version`.
#' @param format Format of the output. Can be `"R"` (default), `"xml"`, or `"json"`.
#' @param tags_in_columns If `FALSE` (default), the tags of the objects are saved in a single list column `tags```
#'   containing a `data.frame` for each OSM object with the keys and values. If `TRUE`, add a column for each key.
#'   Ignored if `format != "R"`.
#'
#' @details
#' `full_objects = TRUE` does not support specifying `version`.
#' For ways, `full_objects = TRUE` implies that it will return the way specified plus all nodes referenced by the way.
#' For a relation, it will return the following:
#' * The relation itself
#' * All nodes, ways, and relations that are members of the relation
#' * Plus all nodes used by ways from the previous step
#' * The same recursive logic is not applied to relations. This means: If relation r1 contains way w1 and relation r2,
#'   and w1 contains nodes n1 and n2, and r2 contains node n3, then a "full" request for r1 will give you r1, r2, w1,
#'   n1, and n2. Not n3.
#'
#' @note
#' For downloading data for purposes other than editing or exploring the history of the objects, perhaps is better to
#' use the Overpass API. A similar function to download OSM objects by `type` and `id` using Overpass, is implemented in
#' the \pkg{osmdata} function `opq_osm_id()`.
#'
#' @return
#' If `format = "R"`, returns a data frame with one OSM object per row. If `format = "xml"`, returns a
#' [xml2::xml_document-class] following the
#' [OSM_XML format](https://wiki.openstreetmap.org/wiki/OSM_XML#OSM_XML_file_format_notes). If `format = "json"`,
#' returns a list with a json structure following the [OSM_JSON format](https://wiki.openstreetmap.org/wiki/OSM_JSON).
#'
#' Objects are sorted in the same order than `osm_id` except for `full_objects = TRUE`, where the nodes comes first,
#' then ways, and relations at the end as specified by
#' [OSM_XML format](https://wiki.openstreetmap.org/wiki/OSM_XML#OSM_XML_file_format_notes).
#'
#' @family get OSM objects' functions
#' @export
#'
#' @examples
#' \dontrun{
#' obj <- osm_get_objects(
#'   osm_type = c("node", "way", "way", "relation", "relation", "node"),
#'   osm_id = c("35308286", "13073736", "235744929", "40581", "341530", "1935675367"),
#'   version = c(1, 3, 2, 5, 7, 1)
#' )
#' obj
#' }
osm_get_objects <- function(osm_type, osm_id, version, full_objects = FALSE,
                            format = c("R", "xml", "json"), tags_in_columns = FALSE) {
  format <- match.arg(format)

  stopifnot(
    '`osm_type` must be a vector containing values "node", "way" or "relation".' =
      all(osm_type %in% c("node", "way", "relation"))
  )

  if (!missing(version) && full_objects) {
    stop("Getting full objects with specific version is not supported.")
  }
  if (length(osm_id) %% length(osm_type) != 0 || length(osm_type) > length(osm_id)) {
    stop("`osm_id` length must be a multiple of `osm_type` length.")
  }

  if (length(osm_id) == 1) {
    if (full_objects && osm_type %in% c("way", "relation")) {
      out <- osm_full_object(osm_type = osm_type, osm_id = osm_id, format = format, tags_in_columns = tags_in_columns)
    } else if (!missing(version)) {
      out <- osm_version_object(
        osm_type = osm_type, osm_id = osm_id, version = version, format = format, tags_in_columns = tags_in_columns
      )
    } else {
      out <- osm_read_object(osm_type = osm_type, osm_id = osm_id, format = format, tags_in_columns = tags_in_columns)
    }

    return(out)
  }

  type_id <- data.frame(type = osm_type, id = osm_id)
  if (!missing(version)) {
    if (length(version) %% nrow(type_id) != 0 || length(version) > nrow(type_id)) {
      stop("`osm_id` length must be a multiple of `version` length.")
    }
    type_id$version <- version
  }

  if (nrow(type_id) > nrow(type_id <- unique(type_id))) {
    warning("Duplicated elements discarded.")
  }

  type_idL <- split(type_id, type_id$type)

  if (full_objects) {
    out <- mapply(function(type, ids) {
      if (type %in% c("way", "relation")) {
        full_objL <- lapply(ids$id, function(id) {
          osm_full_object(osm_type = type, osm_id = id, format = format)
        })

        if (format == "R") {
          full_obj <- do.call(rbind, full_objL)
        } else if (format == "xml") {
          full_obj <- xml2::xml_new_root(full_objL[[1]])
          for (i in seq_len(length(full_objL) - 1)) {
            for (j in seq_len(xml2::xml_length(full_objL[[i + 1]]))) {
              xml2::xml_add_child(full_obj, xml2::xml_child(full_objL[[i + 1]], search = j))
            }
          }
        } else if (format == "json") {
          full_obj <- full_objL[[1]]
          if (length(full_objL) > 1) {
            full_obj$elements <- do.call(c, c(list(full_obj$elements), lapply(full_objL[-1], function(x) x$elements)))
          }
        }
      } else {
        full_obj <- osm_fetch_objects(osm_type = paste0(type, "s"), osm_ids = ids$id, format = format)
      }
      full_obj
    }, type = names(type_idL), ids = type_idL, SIMPLIFY = FALSE)
  } else { # no full_objects
    type_plural <- paste0(names(type_idL), "s") # type in plural for osm_fetch_objects()

    if (missing(version)) {
      out <- mapply(function(type, ids) {
        osm_fetch_objects(osm_type = type, osm_ids = ids$id, format = format)
      }, type = type_plural, ids = type_idL, SIMPLIFY = FALSE)
    } else {
      out <- mapply(function(type, ids) {
        osm_fetch_objects(osm_type = type, osm_ids = ids$id, versions = ids$version, format = format)
      }, type = type_plural, ids = type_idL, SIMPLIFY = FALSE)
    }
  }


  ## Order objects

  if (full_objects) {
    # Order by types (node, way, relation)

    if (format == "R") {
      out <- do.call(rbind, out[intersect(c("node", "way", "relation"), names(out))])
      out <- rbind(out[out$type == "node", ], out[out$type == "way", ])
      out <- rbind(out, out[out$type == "relation", ])
      rownames(out) <- NULL

      if (tags_in_columns) {
        out <- tags_list2wide(out)
      }
    } else if (format == "xml") {
      ## TODO: test. Use xml2::xml_find_all()?
      out <- out[intersect(c("node", "way", "relation"), names(out))]
      out_ordered <- xml2::xml_new_root(out[[1]])
      for (i in seq_len(length(out) - 1)) {
        for (j in seq_len(xml2::xml_length(out[[i + 1]]))) {
          xml2::xml_add_child(out_ordered, xml2::xml_child(out[[i + 1]], search = j))
        }
      }
      out <- out_ordered
    } else if (format == "json") {
      ord_out <- lapply(out, function(x) {
        vapply(x$elements, function(y) do.call(paste, y[names(type_id)]), FUN.VALUE = character(1))
      })
      ord <- unlist(ord_out[intersect(c("node", "way", "relation"), names(ord_out))])
      ord <- c(ord[grep("^node", ord)], ord[grep("^way", ord)], ord[grep("^relation", ord)])
      ord <- data.frame(type = gsub("[0-9]+$", "", names(ord)), pos = as.integer(gsub("^[a-z.]+", "", names(ord))))
      ord$pos[is.na(ord$pos)] <- 1 # for types with only 1 object

      out_ordered <- out[[1]][setdiff(names(out[[1]]), "elements")]
      out_ordered$elements <- apply(ord, 1, function(x) {
        out[[x[1]]]$elements[[as.integer(x[2])]]
      }, simplify = FALSE)
      out <- out_ordered
    }
  } else {
    ## Original order

    ord_ori <- do.call(paste, type_id)

    if (format == "R") {
      out <- do.call(rbind, out)
      ord_out <- do.call(paste, out[, intersect(names(type_id), c("type", "id", "version"))])
      out <- out[match(ord_ori, ord_out), ]
      rownames(out) <- NULL

      if (tags_in_columns) {
        out <- tags_list2wide(out)
      }
    } else if (format == "xml") {
      ord_out <- lapply(out, function(x) {
        out_type_id <- object_xml2DF(x)
        do.call(paste, out_type_id[, names(type_id)])
      })
      ordL <- lapply(ord_out, function(x) match(ord_ori, x))
      ord <- sort(unlist(ordL))
      ord <- data.frame(type = gsub("[0-9]+$", "", names(ord)), pos = as.integer(gsub("^[a-z.]+", "", names(ord))))
      ord$pos[is.na(ord$pos)] <- 1 # for types with only 1 object

      out_ordered <- xml2::xml_new_root(out[[ord$type[1]]])
      xml2::xml_remove(xml2::xml_children(out_ordered))
      for (i in seq_len(nrow(ord))) {
        xml2::xml_add_child(out_ordered, xml2::xml_child(out[[ord$type[i]]], search = ord$pos[i]))
      }
      out <- out_ordered
    } else if (format == "json") {
      ord_out <- lapply(out, function(x) {
        vapply(x$elements, function(y) do.call(paste, y[names(type_id)]), FUN.VALUE = character(1))
      })
      ordL <- lapply(ord_out, function(x) match(ord_ori, x))
      ord <- sort(unlist(ordL))
      ord <- data.frame(type = gsub("[0-9]+$", "", names(ord)), pos = as.integer(gsub("^[a-z.]+", "", names(ord))))

      out_ordered <- out[[1]][setdiff(names(out[[1]]), "elements")]
      out_ordered$elements <- apply(ord, 1, function(x) {
        out[[x[1]]]$elements[[as.integer(x[2])]]
      }, simplify = FALSE)
      out <- out_ordered
    }
  }

  return(out)
}
