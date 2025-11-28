# Read ABARES' "Historical National Estimates"

Fetches and imports ABARES "Historical National Estimates" data.

## Usage

``` r
read_historical_national_estimates(x = NULL)

read_hist_nat_est(x = NULL)
```

## Source

<https://www.agriculture.gov.au/sites/default/files/documents/fdp-national-historical.csv>

## Arguments

- x:

  A file path providing the file with the data to be imported. The file
  is assumed to be unarchived (*i.e.*, still zipped). This function does
  not provide any checking whether this function is the proper function
  for the provided file. Defaults to `NULL`, assuming that the file will
  be downloaded in the active R session.

## Value

A
[`data.table::data.table()`](https://rdatatable.gitlab.io/data.table/reference/data.table.html)
object with the `Variable` field as the `key`.

## Note

Columns are renamed for consistency with other ABARES products serviced
in this package using a snake_case format and ordered consistently.

## References

<https://www.agriculture.gov.au/abares/data/farm-data-portal#data-download>

## See also

Other Estimates:
[`read_estimates_by_performance_category()`](https://adamhsparks.github.io/read.abares/reference/read_estimates_by_performance_category.md),
[`read_estimates_by_size()`](https://adamhsparks.github.io/read.abares/reference/read_estimates_by_size.md),
[`read_historical_regional_estimates()`](https://adamhsparks.github.io/read.abares/reference/read_historical_regional_estimates.md),
[`read_historical_state_estimates()`](https://adamhsparks.github.io/read.abares/reference/read_historical_state_estimates.md)

## Examples

``` r
if (FALSE) { # interactive()

read_historical_national_estimates()

# or shorter
read_hist_nat_est()
}
```
