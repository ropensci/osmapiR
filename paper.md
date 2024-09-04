---
title: "osmapiR: An 'OpenStreetMap API' implementation for R"
tags:
    - openstreetmap
    - OSM
    - spatial
    - R
authors:
    - name: Joan Maspons
      orcid: 0000-0003-2286-8727
      affiliation: 1
#       corresponding: true
affiliations:
    - name: Independent researcher, Catalonia
      index: 1
date: 22 July 2024
bibliography: paper.bib
# nocite: |
#  @*
---

# Summary

`osmapiR` [@osmapiR] is a complete implementation of the 
[OpenStreetMap API](https://wiki.openstreetmap.org/wiki/API_v0.6) for `R` [@R].
OpenStreetMap (OSM) is a global, crowdsourced geographic database licensed under the [Open Database License](https://www.openstreetmap.org/copyright). 
The OSM project follows a peer production model similar to Wikipedia.


# Statement of need

The `osmapiR` package facilitates to retrieve all types of OSM data, including map data, map notes, GPS traces,
changelogs, and user data.
The data can be imported into R as `data.frame`, `sf` [@sf], `xml_document` [@xml2], or JSON lists.
Editing the OSM database is also supported with specific functions to send changes directly to the OSM database or to
generate and export changes in [Osmchange format](https://wiki.openstreetmap.org/wiki/OsmChange), compatible with other
editors such as JOSM.

`osmapiR` is the only R package that allows access to non-map OSM data (map notes, GPS traces, changelogs and users
data), as well as the ability to edit and upload any kind of data to the project.
It is also useful for obtaining the history of the OSM map objects.
The OpenStreetMap API is not intended to access objects from OSM map data for read-only purposes, as required by the
[API Usage Policy](https://operations.osmfoundation.org/policies/api/).
For such purposes, the use of `osmdata` or `osmextract` packages is recommended.
`osmdata` uses the Overpass API [@osmdata] and works well for moderated size datasets or to access objects filtered by
tags.
`osmextract` works with local `pbf` files [@osmextract] and is the recommended tool to work with big datasets.
For a review of options to access online geodata in R, including OSM data, see @kolb2019.


# References
