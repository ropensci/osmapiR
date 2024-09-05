
<!-- README.md is generated from README.Rmd. Please edit that file -->

# osmapiR <a href="https://docs.ropensci.org/osmapiR/"><img src="man/figures/logo.svg" align="right" height="200" alt="osmapiR website" /></a>

<!-- badges: start -->

[![R-CMD-check](https://github.com/ropensci/osmapiR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ropensci/osmapiR/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/ropensci/osmapiR/graph/badge.svg)](https://app.codecov.io/gh/ropensci/osmapiR)
[![CRAN
checks](https://badges.cranchecks.info/worst/osmapiR.svg)](https://cran.r-project.org/web/checks/check_results_osmapiR.html)
[![Project Status:
Active](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![CRAN_Status_Badge](https://www.r-pkg.org/badges/version/osmapiR)](https://cran.r-project.org/package=osmapiR)
[![CRAN
Downloads](https://cranlogs.r-pkg.org/badges/grand-total/osmapiR)](https://cran.r-project.org/package=osmapiR)
[![](https://badges.ropensci.org/633_status.svg)](https://github.com/ropensci/software-review/issues/633)
[![DOI](https://joss.theoj.org/papers/10.21105/joss.07151/status.svg)](https://doi.org/10.21105/joss.07151)
<!-- badges: end -->

An R interface to the [OpenStreetMap API
v0.6](https://wiki.openstreetmap.org/wiki/API_v0.6) for fetching and
saving raw geodata from/to the OpenStreetMap database. This package
allows access to OSM maps data as well as map notes, GPS traces,
changelogs, and users data. `osmapiR` enables editing or exploring the
history of OSM objects, and is not intended to access OSM map data for
other purposes. See [Related packages](#related-packages) for other
packages to access OSM map data.

<!-- escaped \[ \] fix resulting README.md by removing \ -->

> [!IMPORTANT]  
> You are responsible for following the [API Usage
> Policy](https://operations.osmfoundation.org/policies/api/). You can
> modify the user agent of the requests by setting the option
> `osmapir.user_agent`:
>
> ``` r
> options(osmapir.user_agent = "my new user agent")
> ```
>
> Respect and follow the [standards and
> conventions](https://wiki.openstreetmap.org/wiki/Editing_Standards_and_Conventions)
> of the OpenStreetMap community. If you plan to do automated edits,
> check the [Automated Edits code of
> conduct](https://wiki.openstreetmap.org/wiki/Automated_Edits_code_of_conduct).

## Installation

To install latest CRAN version:

``` r
install.packages("osmapiR")
```

You can install the development version of osmapiR from
[GitHub](https://github.com) with:

``` r
# install.packages("remotes")
remotes::install_github("ropensci/osmapiR") # Without vignettes

## With vignettes (also accessible at https://docs.ropensci.org/osmapiR/ > Articles)
# install.packages("rmarkdown") # Needed to build vignettes.
remotes::install_github("ropensci/osmapiR", build_vignettes = TRUE)
```

## Get started

For an overview of the functions, check `?osmapiR-package` or the
[web](https://docs.ropensci.org/osmapiR/reference/index.html).

For basic examples, check
[`vignette("osmapiR", package="osmapiR")`](https://docs.ropensci.org/osmapiR/articles/osmapiR.html).

## Related packages

- [osmdata](https://cran.r-project.org/package=osmdata) implements the
  Overpass API to query data from OSM.
- [osmextract](https://cran.r-project.org/package=osmextract) matches,
  downloads, converts, and imports bulk OSM data (`.pbf` files).
- [OpenStreetMap](https://cran.r-project.org/package=OpenStreetMap)
  accesses high resolution raster maps using the OpenStreetMap protocol.

`osmapiR` is the only package to access other OSM data than the maps
data (map notes, GPS traces, changelogs and users). It is also useful to
get the history of the OSM objects and is the only package that allows
editing and upload any kind of data.

To access OSM map data for purposes other than editing or exploring the
history of objects, it may be better to use other packages that
implement the Overpass API
([osmdata](https://cran.r-project.org/package=osmdata)) or that works
with `.pbf` files
([osmextract](https://cran.r-project.org/package=osmextract)).

## Code of Conduct

Please note that this package is released with a [Contributor Code of
Conduct](https://ropensci.org/code-of-conduct/). By contributing to this
project, you agree to abide by its terms.
