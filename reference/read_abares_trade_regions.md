# Read "Trade Data Regions" from the ABARES Trade Dashboard

Fetches and imports ABARES "Trade Data Regions".

## Usage

``` r
read_abares_trade_regions(x = NULL)
```

## Source

<https://daff.ent.sirsidynix.net.au/client/en_AU/search/asset/1033841/2>

## Arguments

- x:

  A file path providing the file with the data to be imported. The file
  is assumed to be unarchived (*i.e.*, still zipped). This function does
  not provide any checking whether this function is the proper function
  for the provided file. Defaults to `NULL`, assuming that the file will
  be downloaded in the active R session.

## Value

A [data.table](https://CRAN.R-project.org/package=data.table) object of
the ABARES trade data regions.

## Note

Columns are renamed for consistency with other ABARES products serviced
in this package using a snake_case format and ordered consistently.

## References

<https://daff.ent.sirsidynix.net.au/client/en_AU/search/asset/1033841/0>

## See also

Other Trade:
[`read_abares_trade()`](https://adamhsparks.github.io/read.abares/reference/read_abares_trade.md)

## Examples

``` r
if (FALSE) { # interactive()
trade_regions <- read_abares_trade_regions()

trade_regions
}
```
