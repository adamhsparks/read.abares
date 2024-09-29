
<!-- README.md is generated from README.Rmd. Please edit that file -->

# {read.abares}: Simple downloading and importing of ABARES Data <img src="man/figures/logo.png" align="right"/>

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/read.abares)](https://CRAN.R-project.org/package=read.abares)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
<!-- badges: end -->

An R package for automated downloading and ingestion of data from the
Australian Bureau of Agricultural and Resource Economics and Sciences.
Data serviced include:

- [ABARES
  Estimates](https://www.agriculture.gov.au/read.abares/data/farm-data-portal#data-download);
  - Historical National Estimates;
  - Historical State Estimates;
  - Historical Regional Estimates;
  - Estimates by Size;
  - Estimates by Performance Category;
- the [Australian Gridded Farm Data (AGFD)
  set](https://www.agriculture.gov.au/read.abares/research-topics/surveys/farm-survey-data/australian-gridded-farm-data);
- the [Australian Agricultural and Grazing Industries Survey
  (AAGIS)](https://www.agriculture.gov.au/read.abares/research-topics/surveys/farm-survey-data)
  region mapping files and the
- a [Soil Thickness for Australian areas of intensive agriculture of
  Layer 1 (A Horizon - top-soil) (derived from soil
  mapping)](https://data.agriculture.gov.au/geonetwork/srv/eng/catalog.search#/metadata/faa9f157-8e17-4b23-b6a7-37eb7920ead6)
  map.

The files are freely available as CSV files, zip archives of NetCDF
files or a zip archives of geospatial shape files. {read.abares}
facilitates downloading, caching and importing these files in your R
session with your choice of the class of the resulting object(s).

## Get Started

### Installation

{read.abares} is not available through CRAN (yet). But you can install
it like so:

``` r
if (!require("remotes"))
  install.packages("remotes")
remotes::install_git("https://codeberg.org/adamhsparks/read.abares")
```

## Features

### Caching

{read.abares} supports caching the files using
`tools::R_user_dir(package = "read.abares", which = "cache")` to save
the files in a standardised location across platforms so you don’t have
to worry about where the files went or if they’re still there. When
requesting the files, {read.abares} will first check if they are
available locally. Caching is not mandatory, you can just work with the
downloaded files in `tempdir()`, which is cleaned up when your R session
ends. `get_agfd()` will always check first if the files are available
locally, either cached or in your current R session’s `tempdir()` to
save time by not downloading again if they are available already.

### Multiple Classes Supported

{read.abares} supports multiple classes of objects to support your
workflow. Select from spatial classes:

- [{stars}](https://CRAN.R-project.org/package=stars),
- [{terra}](https://CRAN.R-project.org/package=terra) or
- [{tidync}](https://CRAN.R-project.org/package=tidync)

or data.frame objects:

- [{data.table}](https://CRAN.R-project.org/package=data.table)

## Metadata

Please report any [issues or
bugs](https://codeberg.org/adamhsparks/read.abares/issues).

License: [MIT](LICENSE.md)

Citing the data: Please refer to the ABARES website,
<https://www.agriculture.gov.au/read.abares/products/citations>, on how
to cite these data when you use them.

## Code of Conduct

Please note that the {read.abares} project is released with a
[Contributor Code of
Conduct](https://adamhsparks.codeberg.page/read.abares/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.
