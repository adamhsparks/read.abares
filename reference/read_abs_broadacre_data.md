# Get ABS' Broadacre Crops Production and Value by Australia, State and Territory by Year

Automates downloading and importing of ABS broadacre crop production
data. Please view the comments embedded in the spreadsheets themselves
(that really should be columns of comments on the data) for important
information.

## Usage

``` r
read_abs_broadacre_data(data_set = "winter", year = "latest", x = NULL)
```

## Arguments

- data_set:

  A character vector providing the desired cropping data, one of:

  - winter (default),

  - summer or

  - sugarcane.

- year:

  A string value providing the year of interest to download. Formatted
  as `"2022-23"` or `"2023-24"` or use `"latest"` for the most recent
  release available. Defaults to `"latest"`.

- x:

  A file path providing the file with the data to be imported. The file
  is assumed to be unarchived (*i.e.*, still zipped). This function does
  not provide any checking whether this function is the proper function
  for the provided file. Defaults to `NULL`, assuming that the file will
  be downloaded in the active R session.

## Value

A
[`data.table::data.table()`](https://rdatatable.gitlab.io/data.table/reference/data.table.html)
object of the requested data.

## Details

Technically these data are from the Australian Bureau of Statistics
(ABS, not ABARES, but the data is agricultural and so it's serviced in
this package.

## References

<https://www.abs.gov.au/statistics/industry/agriculture/australian-agriculture-broadacre-crops>.

## See also

Other ABS:
[`read_abs_horticulture_data()`](https://adamhsparks.github.io/read.abares/reference/read_abs_horticulture_data.md),
[`read_abs_livestock_data()`](https://adamhsparks.github.io/read.abares/reference/read_abs_livestock_data.md)

## Examples

``` r
if (FALSE) { # interactive()
broadacre_data  <- read_abs_broadacre_data()

broadacre_data
}
```
