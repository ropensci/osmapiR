
<!-- README.md is generated from README.Rmd. Please edit that file -->

# osmapiR

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

Implements [OpenStreetMap
API](https://wiki.openstreetmap.org/wiki/API_v0.6) for R.

## Installation

You can install the development version of osmapiR from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("jmaspons/osmapiR")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(osmapiR)
#> Data (c) OpenStreetMap contributors, ODbL 1.0. https://www.openstreetmap.org/copyright

# For testing without breaking the OSM data, make calls to `https://master.apis.dev.openstreetmap.org`
set_osmapi_connection(server = "testing")
```
