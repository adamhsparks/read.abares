# {agfd}: Simple downloading and importing of the Australian Gridded Farm Data

An R package for automated downloading, parsing and formatting of [Australian Gridded Farm Data](https://www.agriculture.gov.au/abares/research-topics/surveys/farm-survey-data/australian-gridded-farm-data) from Australian Department of Agriculture, Fisheries and Forestry (DAFF).
The files are freely available as zip archives of NetCDF files.
{agdf} facilitates downloading, caching and importing these files in your R session with your choice of the class of the resulting object(s).

## Get Started

### Installation

{agdf} is not available through CRAN (yet).
But you can install it like so:

```r
if (!require("remotes"))
  install.packages("remotes")
remotes::install_git("https://codeberg.org/adamhsparks/agdf")
```

### Using {agdf}

You can download files and pipe directly into the class object that you desire.

```r
## A list of {stars} objects
star_s <- get_agfd(cache = TRUE) |>
  read_agdf_stars()

## A {terra} `rast` object
terr_a <- get_agfd(cache = TRUE) |>
  read_agdf_terra()

## A list of {tidync} objects
tnc <- get_agfd(cache = TRUE) |>
  read_agdf_tidync()
```

## Features

### Caching

{agdf} supports caching the files using `tools::R_user_dir(package = "agfd", which = "cache")` to save the files in a standardised location across platforms so you don't have to worry about where the files went or if they're still there.
When requesting the files, {agdf} will first check if they are available locally.
Caching is not mandatory, in fact the default is to not cache the files but just work with them out of `tempdir()`.
`get_agfd()` will always check first if the files are available locally, either cached or in your current R session's `tempdir()` to save time by not downloading again if they are available already.

### Multiple Classes Supported

{agdf} supports multiple classes of objects to support your workflow.
Select from:

- [{stars}](https://CRAN.R-project.org/package=stars),
- [{terra}](https://CRAN.R-project.org/package=terra),
- [{tidync}](https://CRAN.R-project.org/package=tidync) or even
- [{tibble}](https://CRAN.R-project.org/package=tibble), or
- [{data.table}](https://CRAN.R-project.org/package=data.table)

## Description of the Data

Directly from the DAFF website:

>The Australian Gridded Farm Data are a set of national scale maps containing simulated data on historical broadacre farm business outcomes including farm profitability on an 0.05-degree (approximately 5 km) grid.

>These data have been produced by ABARES as part of the ongoing Australian Agricultural Drought Indicator (AADI) project (previously known as the Drought Early Warning System Project) and were derived using ABARES farmpredict model, which in turn is based on ABARES Agricultural and Grazing Industries Survey (AAGIS) data.

>These maps provide estimates of farm business profit, revenue, costs and production by location (grid cell) and year for the period 1990-91 to 2022-23. The data do not include actual observed outcomes but rather model predicted outcomes for representative or ‘typical’ broadacre farm businesses at each location considering likely farm characteristics and prevailing weather conditions and commodity prices.

>The Australian Gridded Farm Data remain under active development, and as such should be considered experimental.

-- Australian Department of Agriculture, Fisheries and Forestry.

## Metadata

Please report any [issues or bugs](https://codeberg.org/adamhsparks/agfd/issues).

License: [MIT](LICENSE.md)
