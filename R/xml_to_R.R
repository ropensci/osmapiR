tags_xml2DF <- function(xml_nodeset) {
  tags <- xml2::xml_find_all(xml_nodeset, xpath = ".//tag", flatten = FALSE)
  tags_u <- xml2::xml_find_all(xml_nodeset, xpath = ".//tag")
  col_names <- sort(unique(xml2::xml_attr(tags_u, attr = "k")))
  m <- matrix(nrow = length(tags), ncol = length(col_names), dimnames = list(NULL, col_names))
  has_tags <- which(vapply(tags, length, FUN.VALUE = integer(1)) > 0)
  for (i in has_tags) {
    tag <- xml2::xml_attrs(tags[[i]])
    tagV <- vapply(tag, function(x) x, FUN.VALUE = character(2))
    m[i, tagV[1, ]] <- tagV[2, ]
  }

  return(m)
}


## Changesets ----

# osm_download_changeset() in osmChange xml format. Not related

changeset_xml2DF <- function(xml) {
  changesets <- xml2::xml_children(xml)

  changeset_attrs <- do.call(rbind, xml2::xml_attrs(changesets))

  # read & query changeset calls have different order in attributes.
  ord_cols <- c(
    "id", "created_at", "closed_at", "open", "user", "uid",
    "min_lat", "min_lon", "max_lat", "max_lon", "comments_count", "changes_count"
  )
  out <- data.frame(changeset_attrs[, ord_cols, drop = FALSE])

  out$open <- ifelse(out$open == "true", TRUE, FALSE)
  out$comments_count <- as.integer(out$comments_count)
  out$changes_count <- as.integer(out$changes_count)
  out$created_at <- as.POSIXct(out$created_at)
  out$closed_at <- as.POSIXct(out$closed_at)

  discussion <- xml2::xml_child(changesets, "discussion")

  if (!all(is.na(discussion))) {
    discussionL <- lapply(xml2::xml_find_all(discussion, xpath = ".//comment", flatten = FALSE), function(x) {
      if (length(x) == 0) {
        return(NA)
      }
      comment_attrs <- do.call(rbind, xml2::xml_attrs(x))
      comment_text <- xml2::xml_text(xml2::xml_child(x, "text"))
      dis <- data.frame(comment_attrs, comment_text)
      dis$date <- as.POSIXct(dis$date)

      return(dis)
    })

    out$discussion <- discussionL
  }

  tags <- tags_xml2DF(changesets)
  out <- cbind(out, tags)

  # out$discussion ## TODO: improve print. class?

  return(out)
}


## Elements ----
## TODO: warning in  osm_bbox_objects(bbox = c(3.2164192, 42.0389667, 3.2317829, 42.0547099))

object_xml2DF <- function(xml) {
  objects <- xml2::xml_children(xml)

  if (length(objects) == 0) {
    out <- data.frame(
      type = character(), id = character(), visible = character(), version = character(), changeset = character(),
      timestamp = character(), user = character(), uid = character(), lat = character(), lon = character()
    )
    return(out)
  }

  object_type <- xml2::xml_name(objects)

  if (object_type[1] == "bounds") { # osm_bbox_objects()

    bbox <- xml2::xml_attrs(objects[[1]])
    objects <- objects[-1]
    object_type <- object_type[-1]

    if (length(objects) == 0) {
      out <- data.frame(
        type = character(), id = character(), visible = character(), version = character(), changeset = character(),
        timestamp = character(), user = character(), uid = character(), lat = character(), lon = character()
      )
      attr(out, "bbox") <- bbox

      return(out)
    }
  } else {
    bbox <- NULL
  }

  object_attrs <- do.call(rbind, xml2::xml_attrs(objects))
  tags <- tags_xml2DF(objects)

  members <- vector("list", length = length(objects))
  members[object_type == "way"] <- lapply(objects[object_type == "way"], function(x) {
    xml2::xml_attr(xml2::xml_find_all(x, ".//nd"), "ref")
  })

  members[object_type == "relation"] <- lapply(objects[object_type == "relation"], function(x) {
    do.call(rbind, xml2::xml_attrs(xml2::xml_find_all(x, ".//member")))
  })

  out <- data.frame(type = object_type, object_attrs)
  out$visible <- ifelse(out$visible == "true", TRUE, FALSE)
  out$version <- as.integer(out$version)
  out$timestamp <- as.POSIXct(out$timestamp)

  out$members <- members

  out <- cbind(out, tags)

  if (!is.null(bbox)) {
    attr(out, "bbox") <- bbox
  }

  # out$members ## TODO: improve print. class?

  return(out)
}
