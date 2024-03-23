
<!-- README.md is generated from README.Rmd. Please edit that file -->

# osmapiR <a href="https://jmaspons.github.io/osmapiR"><img src="man/figures/logo.svg" align="right" height="139" alt="osmapiR website" /></a>

<!-- badges: start -->

[![R-CMD-check](https://github.com/jmaspons/osmapiR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/jmaspons/osmapiR/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/jmaspons/osmapiR/branch/main/graph/badge.svg)](https://codecov.io/gh/jmaspons/osmapiR)
[![pkgdown](https://github.com/jmaspons/osmapiR/actions/workflows/pkgdown.yaml/badge.svg)](https://github.com/jmaspons/osmapiR/actions/workflows/pkgdown.yaml)
[![Project Status:
Active](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![CRAN_Status_Badge](https://www.r-pkg.org/badges/version/osmapiR)](https://cran.r-project.org/package=osmapiR)
<!-- badges: end -->

Implements [OpenStreetMap
API](https://wiki.openstreetmap.org/wiki/API_v0.6) for R.

You are responsible for following the [API Usage
Policy](https://operations.osmfoundation.org/policies/api/). You can
modify the user agent of the requests by setting the option
`osmapir.user_agent`:

``` r
options(osmapir.user_agent = "my new user agent")
```

## Installation

You can install the development version of osmapiR from
[GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("jmaspons/osmapiR")
```

## Examples

This is a basic example which shows how to get map data:

``` r
library(osmapiR)
#> Data (c) OpenStreetMap contributors, ODbL 1.0. https://www.openstreetmap.org/copyright

# For testing edition without breaking the OSM data,
# make calls to `https://master.apis.dev.openstreetmap.org`

# set_osmapi_connection(server = "testing") # lacks data

bbox <- c(2.4166059, 42.5945594, 2.4176574, 42.5962101)

## Download objects by bounding box
osm_objs <- osm_bbox_objects(bbox = bbox, tags_in_columns = TRUE)

## View history of an object
sel <- osm_objs$`name:ca` %in% "Abadia de Sant Miquel de Cuixà"
obj <- osm_objs[sel, ]

obj_history <- osm_history_object(osm_type = obj$osm_type, osm_id = obj$osm_id) # tags in a list column
obj_history
#>   type       id visible version changeset           timestamp     user    uid
#> 1  way 50343004    TRUE       1   3882565 2010-02-15 12:14:11  Skywave  10927
#> 2  way 50343004    TRUE       2  13314595 2012-09-30 19:52:28 petrovsk  90394
#> 3  way 50343004    TRUE       3  53623614 2017-11-08 22:08:33    JFK73 662440
#> 4  way 50343004    TRUE       4 103004865 2021-04-15 15:41:02 petrovsk  90394
#>    lat  lon                                                         members
#> 1 <NA> <NA> 44 nodes: 639618609, 639618608, 639618720, 639618717, 639618...
#> 2 <NA> <NA> 44 nodes: 639618609, 639618608, 639618720, 639618717, 639618...
#> 3 <NA> <NA> 44 nodes: 639618609, 639618608, 639618720, 639618717, 639618...
#> 4 <NA> <NA> 48 nodes: 639618609, 639618608, 8632687795, 8632687796, 8632...
#>                                                                                  tags
#> 1 8 tags: amenity=place_of_worship | building=yes | denomination=catholic | histor...
#> 2 8 tags: amenity=place_of_worship | building=yes | denomination=catholic | histor...
#> 3 15 tags: amenity=place_of_worship | building=yes | denomination=catholic | herit...
#> 4 15 tags: amenity=place_of_worship | building=yes | denomination=catholic | herit...

# obj_history$tags
```

Get notes:

``` r
notes <- osm_read_bbox_notes(bbox = bbox, closed = -1)
notes
#>         lon        lat      id
#> 1 2.4170566 42.5948042 1730475
#> 2 2.4170552 42.5949259  628602
#>                                                       url comment_url close_url
#> 1 https://api.openstreetmap.org/api/0.6/notes/1730475.xml        <NA>      <NA>
#> 2  https://api.openstreetmap.org/api/0.6/notes/628602.xml        <NA>      <NA>
#>          date_created status
#> 1 2019-03-31 14:10:04 closed
#> 2 2016-07-15 07:09:19 closed
#>                                                          comments
#> 1                     2 comments from 2019-03-31 by Sherpa66, Syl
#> 2 5 comments from 2016-07-15 to 2018-05-25 by Dolfo54, rainerU...

# notes$comments
```

Get GPX data:

``` r
## Requires authentication
usr_traces <-  osm_list_gpxs()
osm_get_gpx_metadata(gpx_id = 3790367)
osm_get_data_gpx(gpx_id = 3790367, format = "R")
```

``` r
gpx <- osm_get_points_gps(bbox = bbox)
gpx
#> [[1]]
#>          lat       lon
#> 1 42.5945734 2.4166662
#> 2 42.5945770 2.4166060
#> 3 42.5945770 2.4166640
#> 4 42.5945770 2.4166880
#> 5 42.5945890 2.4167120
#> 6 42.5945999 2.4166340
#> 7 42.5946030 2.4166390
#> 8 42.5946100 2.4166260
#> 
#> attr(,"class")
#> [1] "osmapi_gpx" "list"
```

## Related packages

- [osmdata](https://cran.r-project.org/package=osmdata) implements the
  Overpass API to query data from OSM.
- [osmexctract](https://cran.r-project.org/package=osmextract) matches,
  downloads, converts and imports bulk OSM data (`.pbf` files)
- [OpenStreetMap](https://cran.r-project.org/package=OpenStreetMap)
  Accesses high resolution raster maps using the OpenStreetMap protocol.

`osmapiR` is the only package to access other OSM data than the maps
data (map notes, GPS traces, changelogs and users). It can be also
useful to get the history of the OSM objects and is the only package
that allows editing and upload any kind of data.

To access the OSM map data for purposes other than editing or exploring
the history of the objects, perhaps is better to use the other packages
that implements the Overpass API (`osmdata`) or that works with `.pbf`
files (`osmexcract`).

## Code of Conduct

Please note that the osmapiR project is released with a [Contributor
Code of
Conduct](https://jmaspons.github.io/osmapiR/CODE_OF_CONDUCT.html). By
contributing to this project, you agree to abide by its terms.
