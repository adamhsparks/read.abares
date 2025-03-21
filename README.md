---
output: github_document
---

<!-- README.md is generated from README.Rmd. Please edit that file -->



# {read.abares}: Simple downloading and importing of ABARES Data <img src="man/figures/logo.png" align="right"/>

<!-- badges: start -->
[![Lifecycle: stable](https://img.shields.io/badge/lifecycle-stable-green.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![R-CMD-check](https://github.com/adamhsparks/read.abares/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/adamhsparks/read.abares/actions/workflows/R-CMD-check.yaml)
[![Codecov test coverage](https://codecov.io/gh/adamhsparks/read.abares/graph/badge.svg)](https://app.codecov.io/gh/adamhsparks/read.abares)
<!-- badges: end -->

An R package for automated downloading and ingestion of data from the Australian Bureau of Agricultural and Resource Economics and Sciences.
Not all ABARES data are serviced.
The list is hand-picked to be reasonably useful and maintainable, _i.e._, frequently updated values are not included in this, _e.g._, [Australian crop reports](https://daff.ent.sirsidynix.net.au/client/en_AU/ABARES/search/results?te=ASSET&st=PD#).
However, if there is a data set that you feel would be useful to be serviced by {read.abares}, please feel free to [open an issue](https://github.com/adamhsparks/read.abares/issues/new) with details about the data set or better yet, open a pull request!

Data serviced include:

- the [ABARES Estimates](https://www.agriculture.gov.au/abares/data/farm-data-portal#data-download);
- the [Australian Gridded Farm Data (AGFD) set](https://www.agriculture.gov.au/abares/research-topics/surveys/farm-survey-data/australian-gridded-farm-data);
- the [Australian Agricultural and Grazing Industries Survey (AAGIS)](https://www.agriculture.gov.au/abares/research-topics/surveys/farm-survey-data) region mapping files;
- the [Historical Agricultural Forecast Database](https://www.agriculture.gov.au/abares/research-topics/agricultural-outlook/historical-forecasts#:~:text=About%20the%20historical%20agricultural%20forecast,relevant%20to%20Australian%20agricultural%20markets);
- the [Soil Thickness for Australian areas of intensive agriculture of Layer 1 (A Horizon - top-soil) (derived from soil mapping)](https://data.agriculture.gov.au/geonetwork/srv/eng/catalog.search#/metadata/faa9f157-8e17-4b23-b6a7-37eb7920ead6) map and;
- the [ABARES Trade Data](https://www.agriculture.gov.au/abares/research-topics/trade/dashboard) including;
  - the trade data and;
  - the trade region data.

The files are freely available as CSV files, zip archives of NetCDF files or a zip archives of geospatial shape files.
{read.abares} facilitates downloading, caching and importing these files in your R session with your choice of the class of the resulting object(s).

## Get Started

### Installation

{read.abares} is not available through CRAN (yet).
But you can install it like so:

```r
# install.packages("pak")
pak::pak("adamhsparks/read.abares")
```

## Features

### Caching

{read.abares} supports caching the files using `tools::R_user_dir(package = "read.abares", which = "cache")` to save the files in a standardised location across platforms so you don't have to worry about where the files went or if they're still there.
When requesting the files, {read.abares} will first check if they are available locally either in cached or temporary storage.
Caching is not mandatory, you can just work with the downloaded files in `tempdir()`, which is cleaned up when your R session ends.

### Multiple Classes Supported

{read.abares} supports multiple classes of objects to support your workflow.
Select from spatial classes for the AGFD NetCDF files:

- [{stars}](https://CRAN.R-project.org/package=stars),
- [{terra}](https://CRAN.R-project.org/package=terra) or
- [{tidync}](https://CRAN.R-project.org/package=tidync)

or data.frame (data.table) objects:

- [{data.table}](https://CRAN.R-project.org/package=data.table)

## Metadata

Please report any [issues or bugs](https://github.com/adamhsparks/read.abares/issues).

License: [MIT](LICENSE.md)

### Citations

Citing the data: Please refer to the ABARES website, <https://www.agriculture.gov.au/abares/products/citations>, on how to cite these data when you use them.

Citing {read.abares}: When citing the use of this package, please use,


``` r
library("read.abares")
#> 
#> Attaching package: 'read.abares'
#> The following object is masked from 'package:graphics':
#> 
#>     plot
#> The following object is masked from 'package:base':
#> 
#>     plot
citation("read.abares")
#> To cite package 'read.abares' in publications use:
#> 
#>   Sparks A (????). _read.abares: Simple downloading and importing
#>   of ABARES Data_. R package version 1.0.0,
#>   <https://adamhsparks.github.io/read.abares/>.
#> 
#> A BibTeX entry for LaTeX users is
#> 
#>   @Manual{,
#>     title = {{read.abares}: Simple downloading and importing of ABARES Data},
#>     author = {Adam H. Sparks},
#>     note = {R package version 1.0.0},
#>     url = {https://adamhsparks.github.io/read.abares/},
#>   }
```

### Contributing

#### A Note on Testing

I've aimed to make the testing for this package as complete as possible.
Some of the files downloaded are >1GB and may take several minutes or more than an hour to download and due to their size, I do not wish to include them in the package itself.
Therefore, most of these tests do rely on already downloaded and locally cached files.
If you wish to work with development of {read.abares} please be aware that it will take some time to establish your local cache before testing will be somewhat faster.

### Code of Conduct

Please note that the {read.abares} project is released with a [Contributor Code of Conduct](https://adamhsparks.github.io/read.abares/CODE_OF_CONDUCT.html). By contributing to this project, you agree to abide by its terms.
