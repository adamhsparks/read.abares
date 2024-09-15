
<!-- README.md is generated from README.Rmd. Please edit that file -->

# {abares}: Simple downloading and importing of ABARES Data

An R package for automated downloading, parsing and formatting of data
from the Australian Bureau of Agricultural and Resource Economics and
Sciences including the:

- [Historical National Estimates, Historical State Estimates, Historical
  Regional Estimates, Estimates by Size, Estimates by Performance
  Category](https://www.agriculture.gov.au/abares/data/farm-data-portal#data-download);
- the [Australian Gridded Farm Data (AGFD)
  set](https://www.agriculture.gov.au/abares/research-topics/surveys/farm-survey-data/australian-gridded-farm-data);
  and the - [Australian Agricultural and Grazing Industries Survey
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

### Using {abares}

#### Estimates

You can download the CSV files directly in your R session as illustrated
below.

\`\`\`{ estimages} library(abares)

nat \<- get_hist_nat_est()

sta \<- get_hist_sta_est()

reg \<- get_hist_reg_est()


    #### AGFD Data

    You can download files and pipe directly into the class object that you desire for the AGFD data.


    ``` r
    library(abares)

    ## A list of {stars} objects
    sta <- get_agfd(cache = TRUE) |>
      read_agfd_stars()

    ## A {terra} `rast` object
    ter <- get_agfd(cache = TRUE) |>
      read_agfd_terra()

    ## A list of {tidync} objects
    tnc <- get_agfd(cache = TRUE) |>
      read_agfd_tidync()

    ## A {data.table} object
    dtb <- get_agfd(cache = TRUE) |>
      read_agfd_dt()

## Features

### Caching

{abares} supports caching the files using
`tools::R_user_dir(package = "agfd", which = "cache")` to save the files
in a standardised location across platforms so you don’t have to worry
about where the files went or if they’re still there. When requesting
the files, {abares} will first check if they are available locally.
Caching is not mandatory, you can just work with the downloaded files in
`tempdir()`, which is cleaned up when your R session ends. `get_agfd()`
will always check first if the files are available locally, either
cached or in your current R session’s `tempdir()` to save time by not
downloading again if they are available already.

### Multiple Classes Supported

{abares} supports multiple classes of objects to support your workflow.
Select from spatial classes:

- [{stars}](https://CRAN.R-project.org/package=stars),
- [{terra}](https://CRAN.R-project.org/package=terra) or
- [{tidync}](https://CRAN.R-project.org/package=tidync)

or data.frame objects:

- [{tibble}](https://CRAN.R-project.org/package=tibble), or
- [{data.table}](https://CRAN.R-project.org/package=data.table)

## Description of the Australian Farm Gridded Data

Directly from the DAFF website:

> The Australian Gridded Farm Data are a set of national scale maps
> containing simulated data on historical broadacre farm business
> outcomes including farm profitability on an 0.05-degree (approximately
> 5 km) grid.

> These data have been produced by ABARES as part of the ongoing
> Australian Agricultural Drought Indicator (AADI) project (previously
> known as the Drought Early Warning System Project) and were derived
> using ABARES farmpredict model, which in turn is based on ABARES
> Agricultural and Grazing Industries Survey (AAGIS) data.

> These maps provide estimates of farm business profit, revenue, costs
> and production by location (grid cell) and year for the period 1990-91
> to 2022-23. The data do not include actual observed outcomes but
> rather model predicted outcomes for representative or ‘typical’
> broadacre farm businesses at each location considering likely farm
> characteristics and prevailing weather conditions and commodity
> prices.

> The Australian Gridded Farm Data remain under active development, and
> as such should be considered experimental.

– Australian Department of Agriculture, Fisheries and Forestry.

## Metadata

Please report any [issues or
bugs](https://codeberg.org/adamhsparks/agfd/issues).

License: [MIT](LICENSE)

Citing the data: Please refer to the ABARES website,
<https://www.agriculture.gov.au/abares/products/citations> on how to
cite this data when you use it.
