<!-- README.md is generated from README.Rmd. Please edit that file -->



# {read.abares}: Download and Import Agricultural Data from the Australian Bureau of Agricultural and Resource Economics and Sciences (ABARES) and Australian Bureau of Statistics (ABS) <img src="man/figures/logo.png" align="right"/>

<!-- badges: start -->
[![Lifecycle: stable](https://img.shields.io/badge/lifecycle-stable-green.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
[![Project Status: Active – The project has reached a stable, usable state and is being actively developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![R-CMD-check](https://github.com/adamhsparks/read.abares/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/adamhsparks/read.abares/actions/workflows/R-CMD-check.yaml)
[![Codecov test coverage](https://codecov.io/gh/adamhsparks/read.abares/graph/badge.svg)](https://app.codecov.io/gh/adamhsparks/read.abares)
<!-- badges: end -->

An R package for automated downloading and ingestion of data from the Australian Bureau of Agricultural and Resource Economics and Sciences (ABARES).

## About ABARES

ABARES is the research arm of the Australian federal Government Department of Agriculture, Fisheries and Forestry (DAFF).
ABARES' main role is "to provide professionally independent data, research, analysis and advice that informs public and private decisions affecting Australian agriculture, fisheries and forestry"[^1].

The data provided by ABARES is extensive and varied, and includes data on agricultural production, trade, and forecasts, as well as spatial data on farm locations and top-soil thickness.
ABARES data are not available from other sources but are mostly available under Creative Commons Licences for reuse.

## About {read.abares}: why this package?

ABARES makes several data sets freely available as spreadsheets in Microsoft Excel or CSV file formats and zip archives of geospatial data as NetCDF, GeoTIFF or shape files.
{read.abares} facilitates downloading and importing these files in your R session.

Data serviced includes but is not limited to:

- the [ABARES Estimates](https://www.agriculture.gov.au/abares/data/farm-data-portal#data-download);
- the [Australian Gridded Farm Data (AGFD) set](https://www.agriculture.gov.au/abares/research-topics/surveys/farm-survey-data/australian-gridded-farm-data);
- the [Australian Agricultural and Grazing Industries Survey (AAGIS)](https://www.agriculture.gov.au/abares/research-topics/surveys/farm-survey-data) region mapping files;
- the [Historical Agricultural Forecast Database](https://www.agriculture.gov.au/abares/research-topics/agricultural-outlook/historical-forecasts#:~:text=About%20the%20historical%20agricultural%20forecast,relevant%20to%20Australian%20agricultural%20markets);
- the [Soil Thickness for Australian areas of intensive agriculture of Layer 1 (A Horizon - top-soil) (derived from soil mapping)](https://data.agriculture.gov.au/geonetwork/srv/eng/catalog.search#/metadata/faa9f157-8e17-4b23-b6a7-37eb7920ead6) map;
- the [ABARES Trade Data](https://www.agriculture.gov.au/abares/research-topics/trade/dashboard) including:
  - the trade data;
  - the trade region data; and
- the [Land Use Data](https://www.agriculture.gov.au/abares/aclump/land-use/data-download) including:
  - National scale land use data;
  - Catchment scale land use data.

## Quick Start

{read.abares} is not available through CRAN (yet).
The preferred method is to use [{remotes}](https://remotes.r-lib.org) like so.
Note that for Linux users, you will need to install system libraries to support geospatial packages in R, _e.g._, {sf} and {terra} as well as some packages for downloading data via [curl](https://curl.se/download.html), please see [Note for Linux Installers](#Note-for-Linux-Installers).

```r
if (!require("remotes")) {
  install.packages("remotes")
}

remotes::install_github("adamhsparks/read.abares",
  dependencies = TRUE,
  build_vignettes = TRUE
)
```

Or, if you prefer using [{pak}](https://pak.r-lib.org/index.html), it does have some advantages.
If you are using Linux and will need to install system libraries to support geospatial packages in R, _e.g._, {sf} and {terra}, you can install {read.abares} like so using [{pak}](https://pak.r-lib.org/index.html), this method will try to handle system dependencies for you.
It may also be a faster installation method as well for any operating system.

```r
o <- options() # save default options
options(pkg.build_vignettes = TRUE)

if (!require("pak")) {
  install.packages("pak",
    repos = sprintf(
      "https://r-lib.github.io/p/pak/stable/%s/%s/%s",
      .Platform$pkgType, R.Version()$os, R.Version()$arch
    )
  )
}

pak::pak("adamhsparks/read.abares", dependencies = TRUE)
options(o) # restore default options
```

## Features

### Standardised Column Names and Orders

ABARES spreadsheet data are not always consistent in their column names or orders.
{read.abares} standardises the column names and orders and uses snake_case for all colnames with the first letter capitalised of every column to help you do your work more efficiently.
Columns are formatted correctly for the data type, _e.g._, dates are converted to `Date` class, and numbers are converted to `numeric` class where necessary, etc.

### Automated Repairing of Geospatial Data

The Australian Agricultural and Grazing Industries Survey (AAGIS) region mapping files report geometry errors that can be repaired using the `sf::st_make_valid()` function.
{read.abares} automatically repairs these geometries for you when you import the data.

### Multiple Geospatial Data Classes Supported

{read.abares} supports multiple classes of objects to support your workflow with the NetCDF data.
Select from spatial classes for the Australian Gridded Farm Data (AGFD) NetCDF files:

- [{stars}](https://CRAN.R-project.org/package=stars),
- [{terra}](https://CRAN.R-project.org/package=terra),
- [{tidync}](https://CRAN.R-project.org/package=tidync), or if you prefer,
- a [{data.table}](https://CRAN.R-project.org/package=data.table) data.frame object of the whole data set.

Or for the Soil Thickness for Australian areas of intensive agriculture of Layer 1 (A Horizon - top-soil) (derived from soil mapping) and land use change data sets, select from:

- [{stars}](https://CRAN.R-project.org/package=stars), or
- [{terra}](https://CRAN.R-project.org/package=terra).

### Just Shutup and do Your Work!

{read.abares} offers users a way to opt out of verbosity at the package level.
There are three levels that are offered.

  - `quiet` - no feedback except for on failure,
  - `minimal` - feedback on failure and warnings is provided, and
  - `verbose` - verbose feedback is provided on failure, warning and for processes like download time or data import.

## About Data Serviced

You might note that not all ABARES data are serviced by this package.
The list is hand-picked to be reasonably useful and maintainable, _i.e._, frequently updated values are not included in this, _e.g._, [Australian crop reports](https://daff.ent.sirsidynix.net.au/client/en_AU/ABARES/search/results?te=ASSET&st=PD#).
However, if there is a data set that you feel would be useful to be serviced by {read.abares}, please feel free to [open an issue](https://github.com/adamhsparks/read.abares/issues/new) with details about the data set or better yet, open a pull request!

## Note for Linux Installers

If you are using Linux, you will likely need to install several system-level libraries, {pak} will do it's best to install most of them but some may not be installable this way.
For [Nectar](https://ardc.edu.au/services/ardc-nectar-research-cloud/) with a fresh Ubuntu image, you can use the following command to install system libraries to install {pak} and then {read.abares}.
In your Linux terminal (not your R console, the "terminal" tab in RStudio should do here in most cases) type:

```bash
sudo apt update && sudo apt install libcurl4-openssl-dev libgdal-dev gdal-bin libgeos-dev libproj-dev libsqlite3-dev libudunits2-dev libxml2-dev
```

## Metadata

Please report any [issues or bugs](https://github.com/adamhsparks/read.abares/issues).

License: [MIT](https://adamhsparks.github.io/read.abares/LICENSE.md)

### Citations

Citing the data: Please refer to the ABARES website, <https://www.agriculture.gov.au/abares/products/citations>, on how to cite these data when you use them.

Citing {read.abares}: When citing the use of this package, please use,


``` r
library(read.abares)
citation("read.abares")
#> To cite package 'read.abares' in publications use:
#> 
#>   Sparks A (????). _read.abares: Download and Import Agricultural Data
#>   from the Australian Bureau of Agricultural and Resource Economics and
#>   Sciences (ABARES) and Australian Bureau of Statistics (ABS)_. R
#>   package version 2.0.0, <https://adamhsparks.github.io/read.abares/>.
#> 
#> A BibTeX entry for LaTeX users is
#> 
#>   @Manual{,
#>     title = {{read.abares}: Download and Import Agricultural Data from the
#>     Australian Bureau of Agricultural and Resource Economics and Sciences
#>     (ABARES) and Australian Bureau of Statistics (ABS)},
#>     author = {Adam H. Sparks},
#>     note = {R package version 2.0.0},
#>     url = {https://adamhsparks.github.io/read.abares/},
#>   }
```

### Contributing

#### Code of Conduct

Please note that the {read.abares} project is released with a [Contributor Code of Conduct](https://adamhsparks.github.io/read.abares/CODE_OF_CONDUCT.html). By contributing to this project, you agree to abide by its terms.

[^1]: <https://www.agriculture.gov.au/abares/about>
