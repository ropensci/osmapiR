## Changesets ----

#' Create changeset's payload
#'
#' Generate the xml payload to create or update a changeset.
#'
#' @param tags a named list with tags (`list(key1 = value1, key2 = value2)`)
#'
#' @return An [xml2::xml_document-class]
#' @noRd
changeset_create_xml <- function(tags) {
  xml <- xml2::xml_new_root("osm")
  xml2::xml_add_child(xml, "changeset")

  for (i in seq_along(tags)) {
    xml2::xml_add_child(xml2::xml_child(xml), "tag", k = names(tags)[i], v = tags[[i]])
  }

  return(xml)
}


## OsmChange ----

# https://wiki.openstreetmap.org/wiki/OsmChange

#' `osmapi_OsmChange` data.frame to `xml_document`
#'
#' @param x An `osmapi_OsmChange` data.frame.
#'
#' @details
#' https://wiki.openstreetmap.org/wiki/OsmChange
#'
#' @return an OsmChange [xml2::xml_document-class]
#' @seealso [osm_download_changeset()], [osmchange_create()], [osmchange_modify()], [osmchange_delete()]
#' @noRd
osmcha_DF2xml <- function(x) {
  if (inherits(x, "tags_wide")) {
    x <- tags_wide2list(x)
  }

  xml <- xml2::xml_new_root(
    "osmChange",
    version = "0.6", generator = paste("osmapiR", getOption("osmapir.osmapir_version"))
  )

  if (all(c("visible", "version", "timestamp") %in% names(x))) {
    x$visible <- ifelse(x$visible, "true", "false")
    x$version <- as.character(x$version)
    x$timestamp <- format(x$timestamp, format = "%FT%H:%M:%SZ", tz = "GMT")
  }

  create_ids <- c(node = 0, way = 0, relation = 0)

  for (i in seq_len(nrow(x))) {
    if (x$action_type[i] == "delete if-unused") {
      xml2::xml_add_child(xml, "delete", `if-unused` = "safe delete")
    } else {
      xml2::xml_add_child(xml, x$action_type[i])
    }

    if (x$action_type[i] == "create") {
      if ("id" %in% names(x) && is.na(x$id[i])) {
        create_ids[x$type[i]] <- create_ids[x$type[i]] - 1
        x$id[i] <- create_ids[x$type[i]]
      }
      # For osmchange_create(), "visible", "version" & "timestamp" columns can be missing
      xml2::xml_add_child(
        xml2::xml_child(xml, i),
        .value = switch(x$type[i],
          node = node_create_2xml(x[i, ]),
          way = way_create_2xml(x[i, ]),
          relation = relation_create_2xml(x[i, ])
        )
      )
    } else {
      xml2::xml_add_child(
        xml2::xml_child(xml, i),
        .value = switch(x$type[i],
          node = node_2xml(x[i, ]),
          way = way_2xml(x[i, ]),
          relation = relation_2xml(x[i, ])
        )
      )
    }
  }

  return(xml)
}


node_create_2xml <- function(x) {
  x <- x[, !is.na(x)]
  if (all(c("id", "visible", "version", "changeset", "timestamp", "user", "uid", "lat", "lon") %in% names(x))) {
    xml <- xml2::xml_new_root(
      x$type,
      id = x$id, visible = x$visible, version = x$version, changeset = x$changeset,
      timestamp = x$timestamp, user = x$user, uid = x$uid, lat = x$lat, lon = x$lon
    )
  } else {
    xml <- xml2::xml_new_root(x$type)

    if ("id" %in% names(x)) {
      xml2::xml_set_attr(xml, attr = "id", value = x$id)
    }
    if ("visible" %in% names(x)) {
      xml2::xml_set_attr(xml, attr = "visible", value = x$visible)
    }
    if ("version" %in% names(x)) {
      xml2::xml_set_attr(xml, attr = "version", value = x$version)
    }
    if ("changeset" %in% names(x)) {
      xml2::xml_set_attr(xml, attr = "changeset", value = x$changeset)
    }
    if ("timestamp" %in% names(x)) {
      xml2::xml_set_attr(xml, attr = "timestamp", value = x$timestamp)
    }
    if ("user" %in% names(x)) {
      xml2::xml_set_attr(xml, attr = "user", value = x$user)
    }
    if ("uid" %in% names(x)) {
      xml2::xml_set_attr(xml, attr = "uid", value = x$uid)
    }
    if ("lat" %in% names(x)) {
      xml2::xml_set_attr(xml, attr = "lat", value = x$lat)
    }
    if ("lon" %in% names(x)) {
      xml2::xml_set_attr(xml, attr = "lon", value = x$lon)
    }
  }

  tags <- x$tags[[1]]
  for (i in seq_len(nrow(tags))) {
    xml2::xml_add_child(xml, "tag", k = tags$key[i], v = tags$value[i])
  }

  return(xml)
}


way_create_2xml <- function(x) {
  x <- x[, !is.na(x)]
  if (all(c("id", "visible", "version", "changeset", "timestamp", "user", "uid") %in% names(x))) {
    xml <- xml2::xml_new_root(
      x$type,
      id = x$id, visible = x$visible, version = x$version, changeset = x$changeset,
      timestamp = x$timestamp, user = x$user, uid = x$uid
    )
  } else {
    xml <- xml2::xml_new_root(x$type)

    if ("id" %in% names(x)) {
      xml2::xml_set_attr(xml, attr = "id", value = x$id)
    }
    if ("visible" %in% names(x)) {
      xml2::xml_set_attr(xml, attr = "visible", value = x$visible)
    }
    if ("version" %in% names(x)) {
      xml2::xml_set_attr(xml, attr = "version", value = x$version)
    }
    if ("changeset" %in% names(x)) {
      xml2::xml_set_attr(xml, attr = "changeset", value = x$changeset)
    }
    if ("timestamp" %in% names(x)) {
      xml2::xml_set_attr(xml, attr = "timestamp", value = x$timestamp)
    }
    if ("user" %in% names(x)) {
      xml2::xml_set_attr(xml, attr = "user", value = x$user)
    }
    if ("uid" %in% names(x)) {
      xml2::xml_set_attr(xml, attr = "uid", value = x$uid)
    }
  }

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


relation_create_2xml <- function(x) {
  x <- x[, !is.na(x)]
  if (all(c("id", "visible", "version", "changeset", "timestamp", "user", "uid") %in% names(x))) {
    xml <- xml2::xml_new_root(
      x$type,
      id = x$id, visible = x$visible, version = x$version, changeset = x$changeset,
      timestamp = x$timestamp, user = x$user, uid = x$uid
    )
  } else {
    xml <- xml2::xml_new_root(x$type)

    if ("id" %in% names(x)) {
      xml2::xml_set_attr(xml, attr = "id", value = x$id)
    }
    if ("visible" %in% names(x)) {
      xml2::xml_set_attr(xml, attr = "visible", value = x$visible)
    }
    if ("version" %in% names(x)) {
      xml2::xml_set_attr(xml, attr = "version", value = x$version)
    }
    if ("changeset" %in% names(x)) {
      xml2::xml_set_attr(xml, attr = "changeset", value = x$changeset)
    }
    if ("timestamp" %in% names(x)) {
      xml2::xml_set_attr(xml, attr = "timestamp", value = x$timestamp)
    }
    if ("user" %in% names(x)) {
      xml2::xml_set_attr(xml, attr = "user", value = x$user)
    }
    if ("uid" %in% names(x)) {
      xml2::xml_set_attr(xml, attr = "uid", value = x$uid)
    }
  }

  members <- x$members[[1]]
  if (!"role" %in% colnames(members)) {
    members <- cbind(members, role = character(nrow(members)))
  }

  for (i in seq_len(nrow(members))) {
    xml2::xml_add_child(xml, "member", type = members[i, "type"], ref = members[i, "ref"], role = members[i, "role"])
  }

  tags <- x$tags[[1]]
  for (i in seq_len(nrow(tags))) {
    xml2::xml_add_child(xml, "tag", k = tags$key[i], v = tags$value[i])
  }

  return(xml)
}


## Elements ----


#' Transform an `osmapi_objects` data.frame to a `xml_document`
#'
#' Function to use all tags as returned by the server (e.g. [osm_read_object()], [osm_fetch_objects()], ...).
#'
#' @param x An `osmapi_objects` data.frame.
#'
#' @return [xml2::xml_document-class]
#' @noRd
object_DF2xml <- function(x) {
  if (inherits(x, "tags_wide")) {
    x <- tags_wide2list(x)
  }

  x$visible <- ifelse(x$visible, "true", "false")
  x$version <- as.character(x$version)
  x$timestamp <- format(x$timestamp, format = "%FT%H:%M:%SZ", tz = "GMT")

  xml <- xml2::xml_new_root("osm", version = "0.6", generator = paste("osmapiR", getOption("osmapir.osmapir_version")))

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
  if (!"role" %in% colnames(members)) {
    members <- cbind(members, role = character(nrow(members)))
  }
  for (i in seq_len(nrow(members))) {
    xml2::xml_add_child(xml, "member", type = members[i, "type"], ref = members[i, "ref"], role = members[i, "role"])
  }

  tags <- x$tags[[1]]
  for (i in seq_len(nrow(tags))) {
    xml2::xml_add_child(xml, "tag", k = tags$key[i], v = tags$value[i])
  }

  return(xml)
}


# TODO: merge object_new|update|delete_DF2xml with different required columns if (colname %in% names(x))?
# TODO: split update & delete DF2xml functions? DELETE only requires `type`, `id`, `version` and `changeset` + `lat` and
# `lon` for nodes

## Create elements ----

#' Transform an `osmapi_objects` data.frame to a `xml_document`
#'
#' Function for [osm_create_object()] where only `type` and `changeset` are required (+ `lat` & `lon` for nodes).
#'
#' @param x An `osmapi_objects` data.frame where columns `id`, `visible`, `version`, `timestamp`, `user` and `uid` can
#'   be missing or will be ignored.
#'
#' @return [xml2::xml_document-class]
#' @noRd
object_new_DF2xml <- function(x) {
  if (inherits(x, "tags_wide")) {
    x <- tags_wide2list(x)
  }

  xml <- xml2::xml_new_root("osm", version = "0.6", generator = paste("osmapiR", getOption("osmapir.osmapir_version")))

  for (i in seq_len(nrow(x))) {
    xml2::xml_add_child(
      .x = xml,
      .value = switch(x$type[i],
        node = node_new_2xml(x[i, ]),
        way = way_new_2xml(x[i, ]),
        relation = relation_new_2xml(x[i, ])
      )
    )
  }

  return(xml)
}


node_new_2xml <- function(x) {
  xml <- xml2::xml_new_root(x$type, changeset = x$changeset, lat = x$lat, lon = x$lon)

  tags <- x$tags[[1]]
  for (i in seq_len(nrow(tags))) {
    xml2::xml_add_child(xml, "tag", k = tags$key[i], v = tags$value[i])
  }

  return(xml)
}


way_new_2xml <- function(x) {
  xml <- xml2::xml_new_root(x$type, changeset = x$changeset)

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


relation_new_2xml <- function(x) {
  xml <- xml2::xml_new_root(x$type, changeset = x$changeset)

  members <- x$members[[1]]
  if (!"role" %in% colnames(members)) {
    members <- cbind(members, role = character(nrow(members)))
  }

  for (i in seq_len(nrow(members))) {
    xml2::xml_add_child(xml, "member", type = members[i, "type"], ref = members[i, "ref"], role = members[i, "role"])
  }

  tags <- x$tags[[1]]
  for (i in seq_len(nrow(tags))) {
    xml2::xml_add_child(xml, "tag", k = tags$key[i], v = tags$value[i])
  }

  return(xml)
}


## Update / delete elements ----

#' Transform an `osmapi_objects` data.frame to a `xml_document`
#'
#' Function for [osm_update_object()] or [osm_delete_object()] where only `type`, `changeset`, `visible` & `version` are
#' required (+ `lat` & `lon` for nodes). `tags` and `members` can also be missing for [osm_delete_object()].
#'
#' @param x An `osmapi_objects` data.frame where columns`timestamp`, `user` and `uid` can be missing or will be ignored.
#'
#' @return [xml2::xml_document-class]
#' @noRd
object_update_DF2xml <- function(x) {
  if (inherits(x, "tags_wide")) {
    x <- tags_wide2list(x)
  }

  if ("visible" %in% names(x)) { # not needed when deleting objects
    x$visible <- ifelse(x$visible, "true", "false")
  }

  x$version <- as.character(x$version)

  xml <- xml2::xml_new_root("osm", version = "0.6", generator = paste("osmapiR", getOption("osmapir.osmapir_version")))

  for (i in seq_len(nrow(x))) {
    xml2::xml_add_child(
      .x = xml,
      .value = switch(x$type[i],
        node = node_update_2xml(x[i, ]),
        way = way_update_2xml(x[i, ]),
        relation = relation_update_2xml(x[i, ])
      )
    )
  }

  return(xml)
}


node_update_2xml <- function(x) {
  xml <- xml2::xml_new_root(
    x$type,
    id = x$id, visible = x$visible, version = x$version, changeset = x$changeset, lat = x$lat, lon = x$lon
  )

  tags <- x$tags[[1]]

  if (!is.null(tags)) {
    for (i in seq_len(nrow(tags))) {
      xml2::xml_add_child(xml, "tag", k = tags$key[i], v = tags$value[i])
    }
  }

  return(xml)
}


way_update_2xml <- function(x) {
  xml <- xml2::xml_new_root(x$type, id = x$id, visible = x$visible, version = x$version, changeset = x$changeset)

  members <- x$members[[1]]

  if (!is.null(members)) {
    for (i in seq_len(length(members))) {
      xml2::xml_add_child(xml, "nd", ref = members[i])
    }
  }

  tags <- x$tags[[1]]

  if (!is.null(tags)) {
    for (i in seq_len(nrow(tags))) {
      xml2::xml_add_child(xml, "tag", k = tags$key[i], v = tags$value[i])
    }
  }

  return(xml)
}


relation_update_2xml <- function(x) {
  xml <- xml2::xml_new_root(x$type, id = x$id, visible = x$visible, version = x$version, changeset = x$changeset)

  members <- x$members[[1]]
  if (!"role" %in% colnames(members)) {
    members <- cbind(members, role = character(nrow(members)))
  }

  if (!is.null(members)) {
    for (i in seq_len(nrow(members))) {
      xml2::xml_add_child(xml, "member", type = members[i, "type"], ref = members[i, "ref"], role = members[i, "role"])
    }
  }

  tags <- x$tags[[1]]

  if (!is.null(tags)) {
    for (i in seq_len(nrow(tags))) {
      xml2::xml_add_child(xml, "tag", k = tags$key[i], v = tags$value[i])
    }
  }

  return(xml)
}


## User preferences ----

user_preferences_DF2xml <- function(x) {
  xml <- xml2::xml_new_root("osm", version = "0.6", generator = paste("osmapiR", getOption("osmapir.osmapir_version")))
  xml2::xml_add_child(.x = xml, .value = "preferences")

  for (i in seq_len(nrow(x))) {
    xml2::xml_add_child(.x = xml2::xml_child(xml), .value = "preference", k = x$key[i], v = x$value[i])
  }

  return(xml)
}


user_preferences_json2xml <- function(x) {
  xml <- xml2::xml_new_root("osm", version = "0.6", generator = paste("osmapiR", getOption("osmapir.osmapir_version")))
  xml2::xml_add_child(.x = xml, .value = "preferences")

  for (i in seq_along(x$preferences)) {
    xml2::xml_add_child(
      .x = xml2::xml_child(xml),
      .value = "preference",
      k = names(x$preferences)[i], v = x$preferences[[i]]
    )
  }

  return(xml)
}
