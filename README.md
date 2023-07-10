
<!-- README.md is generated from README.Rmd. Please edit that file -->

# osmapiR

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![R-CMD-check](https://github.com/jmaspons/osmapiR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/jmaspons/osmapiR/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/jmaspons/osmapiR/branch/main/graph/badge.svg)](https://codecov.io/gh/jmaspons/osmapiR)
[![pkgdown](https://github.com/jmaspons/osmapiR/actions/workflows/pkgdown.yaml/badge.svg)](https://github.com/jmaspons/osmapiR/actions/workflows/pkgdown.yaml)
<!-- badges: end -->

Implements [OpenStreetMap
API](https://wiki.openstreetmap.org/wiki/API_v0.6) for R.

## Status

All `GET` calls implemented, also the ones requiring authentication. The
server responses are parsed and transformed to `data.frame`s. The format
of the returned values still can change a bit.

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
