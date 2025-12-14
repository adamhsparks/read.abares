# Use httr2 to fetch a file with retries

Retries to download the requested resource before stopping. Uses
[httr2](https://CRAN.R-project.org/package=httr2) to cache in-session
results in the [`tempdir()`](https://rdrr.io/r/base/tempfile.html).

## Usage

``` r
.retry_download(url, dest, .max_tries = 3L)
```

## Arguments

- url:

  `Character` The URL being requested.

- dest:

  `Character` A filepath to be written to local storage.

- .max_tries:

  `Integer` The number of times to retry a failed download before
  emitting an error message.

## Value

Called for its side-effects, writes an object to the specified directory
for reading into the active R session later.

## Examples

``` r
f <- fs::path_temp("fdp-beta-national-historical.csv")
.retry_download(
  url = "https://www.agriculture.gov.au/sites/default/files/documents/fdp-beta-national-historical.csv",
  dest = f
)
#> Error in .retry_download(url = "https://www.agriculture.gov.au/sites/default/files/documents/fdp-beta-national-historical.csv",     dest = f): could not find function ".retry_download"
```
