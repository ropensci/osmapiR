## Changesets ----

#' Create changeset's payload
#'
#' Generate the xml payload to create or update a changeset.
#'
#' @param tags a named list with tags (`list(key1 = value1, key2 = value2)`)
#'
#' @return An `xml_document`
#' @noRd
changeset_create_xml <- function(tags) {
  xml <- xml2::xml_new_root("osm")
  xml2::xml_add_child(xml, "changeset")

  for (i in seq_along(tags)) {
    xml2::xml_add_child(xml2::xml_child(xml), "tag", k = names(tags)[i], v = tags[[i]])
  }

  return(xml)
}


# https://wiki.openstreetmap.org/wiki/OsmChange

#' `osmapi_OsmChange` data.frame to `xml_document`
#'
#' @param x An `osmapi_OsmChange` data.frame.
#' @param changeset_id The changeset id to upload the diff to. TODO: not needed?
#'
#' @details
#' https://wiki.openstreetmap.org/wiki/OsmChange
#'
#' @return an OsmChange
#' @noRd
osmcha_DF2xml <- function(x) {
  if (inherits(x, "tags_wide")) {
    x <- tags_wide2list(x)
  }

  x$visible <- ifelse(x$visible, "true", "false")
  x$version <- as.character(x$version)
  x$timestamp <- format(x$timestamp, format = "%FT%H:%M:%SZ", tz = "GMT")

  xml <- xml2::xml_new_root(
    "osmChange",
    version = "0.6", generator = paste("osmapiR", utils::packageVersion("osmapiR"))
  )

  create_ids <- c(node = 0, way = 0, relation = 0)

  for (i in seq_len(nrow(x))) {
    xml2::xml_add_child(xml, x$action_type[i])

    if (x$action_type[i] == "create" && is.na(x$id[i])) {
      create_ids[x$type] <- create_ids[x$type] - 1
      x$id <- create_ids[x$type]
    }

    xml2::xml_add_child(
      xml2::xml_child(xml, i),
      .value = switch(x$type[i],
        node = node_2xml(x[i, ]),
        way = way_2xml(x[i, ]),
        relation = relation_2xml(x[i, ])
      )
    )
  }

  return(xml)
}


## Elements ----


#' Transform an `osmapi_objects` data.frame to a `xml_document`
#'
#' @param x An `osmapi_objects` data.frame.
#'
#' @return `xml_document`
#' @noRd
object_DF2xml <- function(x) {
  if (inherits(x, "tags_wide")) {
    x <- tags_wide2list(x)
  }

  x$visible <- ifelse(x$visible, "true", "false")
  x$version <- as.character(x$version)
  x$timestamp <- format(x$timestamp, format = "%FT%H:%M:%SZ", tz = "GMT")

  xml <- xml2::xml_new_root("osm", version = "0.6", generator = paste("osmapiR", utils::packageVersion("osmapiR")))

  for (i in seq_len(nrow(x))) {
    xml2::xml_add_child(
      .x = xml,
      .value = switch(x$type[i],
        node = node_2xml(x[i, ]),
        way = way_2xml(x[i, ]),
        relation = relation_2xml(x[i, ])
      )
    )
  }

  return(xml)
}


node_2xml <- function(x) {
  xml <- xml2::xml_new_root(
    x$type,
    id = x$id, visible = x$visible, version = x$version, changeset = x$changeset,
    timestamp = x$timestamp, user = x$user, uid = x$uid, lat = x$lat, lon = x$lon
  )

  tags <- x$tags[[1]]
  for (i in seq_len(nrow(tags))) {
    xml2::xml_add_child(xml, "tag", k = tags$key[i], v = tags$value[i])
  }

  return(xml)
}


way_2xml <- function(x) {
  xml <- xml2::xml_new_root(
    x$type,
    id = x$id, visible = x$visible, version = x$version, changeset = x$changeset,
    timestamp = x$timestamp, user = x$user, uid = x$uid
  )

  members <- x$members[[1]]
  for (i in seq_len(length(members))) {
    xml2::xml_add_child(xml, "nd", ref = members[i])
  }

  tags <- x$tags[[1]]
  for (i in seq_len(nrow(tags))) {
    xml2::xml_add_child(xml, "tag", k = tags$key[i], v = tags$value[i])
  }

  return(xml)
}


relation_2xml <- function(x) {
  xml <- xml2::xml_new_root(
    x$type,
    id = x$id, visible = x$visible, version = x$version, changeset = x$changeset,
    timestamp = x$timestamp, user = x$user, uid = x$uid
  )

  members <- x$members[[1]]
  for (i in seq_len(nrow(members))) {
    xml2::xml_add_child(xml, "member", type = members[i, "type"], ref = members[i, "ref"], role = members[i, "role"])
  }

  tags <- x$tags[[1]]
  for (i in seq_len(nrow(tags))) {
    xml2::xml_add_child(xml, "tag", k = tags$key[i], v = tags$value[i])
  }

  return(xml)
}
