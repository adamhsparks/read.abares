# Get ABARES' "Australian Gridded Farm Data" (AGFD)

Used by the `read_agfd` family of functions, downloads the "Australian
Gridded Farm Data" (AGFD) data and unzips the compressed files to NetCDF
for importing.

## Usage

``` r
.get_agfd(.fixed_prices, .yyyy, .x)
```

## Arguments

- .fixed_prices:

  Download historical climate and prices or historical climate and fixed
  prices as described in (Hughes *et al.* 2022).

- .yyyy:

  Returns only data for the specified year or years for climate data
  (fixed prices) or the years for historical climate and prices
  depending upon the setting of `.fixed_prices`. Note that this will
  still download the entire data set, that cannot be avoided, but will
  only return the requested year(s) in your R session. Valid years are
  from 1991 to 2023 inclusive.

- .x:

  A user specified path to a local zip file containing the data.

## Value

A [`list()`](https://rdrr.io/r/base/list.html) object, a list of NetCDF
files containing the "Australian Gridded Farm Data".

## Examples

``` r
# this will download the data and then return only 2020 and 2021 years' data
agfd <- .get_agfd(.fixed_prices = TRUE, .yyyy = 2020:2021, .x = NULL)
#> Error in .get_agfd(.fixed_prices = TRUE, .yyyy = 2020:2021, .x = NULL): could not find function ".get_agfd"

agfd
#> Error: object 'agfd' not found
```
