
<!-- README.md is generated from README.Rmd. Please edit that file -->

# {abares}: Simple downloading and importing of ABARES Data

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/abares)](https://CRAN.R-project.org/package=abares)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
<!-- badges: end -->

An R package for automated downloading, parsing and formatting of data
from the Australian Bureau of Agricultural and Resource Economics and
Sciences including the:

- [Historical National Estimates, Historical State Estimates, Historical
  Regional Estimates, Estimates by Size, Estimates by Performance
  Category](https://www.agriculture.gov.au/abares/data/farm-data-portal#data-download);
- the [Australian Gridded Farm Data (AGFD)
  set](https://www.agriculture.gov.au/abares/research-topics/surveys/farm-survey-data/australian-gridded-farm-data);
  and the
- [Australian Agricultural and Grazing Industries Survey
  (AAGIS)](https://www.agriculture.gov.au/abares/research-topics/surveys/farm-survey-data)
  region mapping files.

The files are freely available as CSV files, zip archives of NetCDF
files or a zip archive of a geospatial shape file. {abares} facilitates
downloading, caching and importing these files in your R session with
your choice of the class of the resulting object(s).

## Get Started

### Installation

{abares} is not available through CRAN (yet). But you can install it
like so:

``` r
if (!require("remotes"))
  install.packages("remotes")
remotes::install_git("https://codeberg.org/adamhsparks/abares")
```

## Features

### Caching

{abares} supports caching the files using
`tools::R_user_dir(package = "abares", which = "cache")` to save the
files in a standardised location across platforms so you don’t have to
worry about where the files went or if they’re still there. When
requesting the files, {abares} will first check if they are available
locally. Caching is not mandatory, you can just work with the downloaded
files in `tempdir()`, which is cleaned up when your R session ends.
`get_agfd()` will always check first if the files are available locally,
either cached or in your current R session’s `tempdir()` to save time by
not downloading again if they are available already.

### Multiple Classes Supported

{abares} supports multiple classes of objects to support your workflow.
Select from spatial classes:

- [{stars}](https://CRAN.R-project.org/package=stars),
- [{terra}](https://CRAN.R-project.org/package=terra) or
- [{tidync}](https://CRAN.R-project.org/package=tidync)

or data.frame objects:

- [{data.table}](https://CRAN.R-project.org/package=data.table)

## Metadata

Please report any [issues or
bugs](https://codeberg.org/adamhsparks/abares/issues).

License: [MIT](LICENSE.md)

Citing the data: Please refer to the ABARES website,
<https://www.agriculture.gov.au/abares/products/citations>, on how to
cite these data when you use them.

## Code of Conduct

Please note that the {abares} project is released with a [Contributor
Code of
Conduct](https://adamhsparks.codeberg.page/abares/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.
