
<!-- README.md is generated from README.Rmd. Please edit that file -->

# osmapiR <a href="https://jmaspons.github.io/osmapiR/"><img src="man/figures/logo.svg" align="right" height="200" alt="osmapiR website" /></a>

<!-- badges: start -->

[![R-CMD-check](https://github.com/jmaspons/osmapiR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/jmaspons/osmapiR/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/jmaspons/osmapiR/branch/main/graph/badge.svg)](https://app.codecov.io/gh/jmaspons/osmapiR)
[![pkgdown](https://github.com/jmaspons/osmapiR/actions/workflows/pkgdown.yaml/badge.svg)](https://github.com/jmaspons/osmapiR/actions/workflows/pkgdown.yaml)
[![Project Status:
Active](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![CRAN_Status_Badge](https://www.r-pkg.org/badges/version/osmapiR)](https://cran.r-project.org/package=osmapiR)
[![CRAN
Downloads](https://cranlogs.r-pkg.org/badges/grand-total/osmapiR)](https://cran.r-project.org/package=osmapiR)
[![](https://badges.ropensci.org/633_status.svg)](https://github.com/ropensci/software-review/issues/633)
<!-- badges: end -->

An R interface to [OpenStreetMap API
v0.6](https://wiki.openstreetmap.org/wiki/API_v0.6) for fetching and
saving raw geodata from/to the OpenStreetMap database. This package
allows to access OSM maps data as well as map notes, GPS traces,
changelogs and users data. To access the OSM map data for purposes other
than editing or exploring the history of the objects see [Related
packages](README.md#related-packages).

You are responsible for following the [API Usage
Policy](https://operations.osmfoundation.org/policies/api/). You can
modify the user agent of the requests by setting the option
`osmapir.user_agent`:

``` r
options(osmapir.user_agent = "my new user agent")
```

Respect and follow the [standards and
conventions](https://wiki.openstreetmap.org/wiki/Editing_Standards_and_Conventions)
of the OpenStreetMap community. If you plan to do automated edits, check
the [Automated Edits code of
conduct](https://wiki.openstreetmap.org/wiki/Automated_Edits_code_of_conduct).

## Installation

To install latest CRAN version:

``` r
install.packages("osmapiR")
```

You can install the development version of osmapiR from
[GitHub](https://github.com) with:

``` r
# install.packages("remotes")
remotes::install_github("jmaspons/osmapiR") # Without vignettes

## With vignettes (also accessible at https://jmaspons.github.io/osmapiR/ > Articles)
# install.packages("rmarkdown") # Needed to build vignettes.
remotes::install_github("jmaspons/osmapiR", build_vignettes = TRUE)
```

## Get started

For an overview of the functions, check `?osmapiR-package` or the
[web](https://jmaspons.github.io/osmapiR/reference/index.html).

For basic examples, check
[`vignette("osmapiR", package="osmapiR")`](https://jmaspons.github.io/osmapiR/articles/osmapiR.html).

## Related packages

- [osmdata](https://cran.r-project.org/package=osmdata) implements the
  Overpass API to query data from OSM.
- [osmextract](https://cran.r-project.org/package=osmextract) matches,
  downloads, converts and imports bulk OSM data (`.pbf` files)
- [OpenStreetMap](https://cran.r-project.org/package=OpenStreetMap)
  Accesses high resolution raster maps using the OpenStreetMap protocol.

`osmapiR` is the only package to access other OSM data than the maps
data (map notes, GPS traces, changelogs and users). It can be also
useful to get the history of the OSM objects and is the only package
that allows editing and upload any kind of data.

To access the OSM map data for purposes other than editing or exploring
the history of the objects, perhaps is better to use the other packages
that implements the Overpass API
([osmdata](https://cran.r-project.org/package=osmdata)) or that works
with `.pbf` files
([osmextract](https://cran.r-project.org/package=osmextract)).

## Code of Conduct

Please note that the osmapiR project is released with a [Contributor
Code of
Conduct](https://jmaspons.github.io/osmapiR/CODE_OF_CONDUCT.html). By
contributing to this project, you agree to abide by its terms.
