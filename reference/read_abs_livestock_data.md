# Read ABS' Livestock Production and Value by Australia, State and Territory by Year

Automates downloading and importing of ABS livestock production data.
Please view the comments embedded in the spreadsheets themselves (that
really should be columns of comments on the data) for important
information.

## Usage

``` r
read_abs_livestock_data(data_set = "livestock_and_products", x = NULL)
```

## Arguments

- data_set:

  A string value providing the desired livestock data, one of:

  livestock_and_products

  :   (default) value of livestock disposals and products by Australia,
      state and territory,

  cattle_herd

  :   Cattle herd experimental estimates by Australia, state and
      territory,

  cattle_herd_series

  :   Cattle herd experimental and historical estimates by Australia,
      state and territory – 2005 to 2024.

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

<https://www.abs.gov.au/statistics/industry/agriculture/australian-agriculture-livestock>.

## See also

Other ABS:
[`read_abs_broadacre_data()`](https://adamhsparks.github.io/read.abares/reference/read_abs_broadacre_data.md),
[`read_abs_horticulture_data()`](https://adamhsparks.github.io/read.abares/reference/read_abs_horticulture_data.md)

## Examples

``` r
if (FALSE) { # interactive()
livestock_data <- read_abs_livestock_data()

livestock_data
}
```
