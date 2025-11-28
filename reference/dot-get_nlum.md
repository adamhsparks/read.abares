# Get ABARES' National Scale "Land Use of Australia" Data

An internal function used by
[`read_nlum_terra()`](https://adamhsparks.github.io/read.abares/reference/read_nlum_terra.md)
and
[`read_nlum_stars()`](https://adamhsparks.github.io/read.abares/reference/read_nlum_stars.md)
that downloads national level land use data GeoTIFF file, unzips the
download file and deletes unnecessary files that are included in the
download.

## Usage

``` r
.get_nlum(.data_set, .x)
```

## Arguments

- .data_set:

  A string value indicating the GeoTIFF desired for download. One of:

  Y201011

  :   Land use of Australia 2010–11

  Y201516

  :   Land use of Australia 2015–16

  Y202021

  :   Land use of Australia 2020–21

  C201121

  :   Land use of Australia change

  T201011

  :   Land use of Australia 2010–11 thematic layers

  T201516

  :   Land use of Australia 2015–16 thematic layers

  T202021

  :   Land use of Australia 2020–21 thematic layers

  P201011

  :   Land use of Australia 2010–11 agricultural commodities probability
      grids

  P201516

  :   Land use of Australia 2015–16 agricultural commodities probability
      grids

  P202021

  :   Land use of Australia 2020–21 agricultural commodities probability
      grids

  .

- .x:

  A user specified path to a local zip file containing the data.

## Value

A list object of NLUM files.

## References

ABARES 2024, Land use of Australia 2010–11 to 2020–21, Australian Bureau
of Agricultural and Resource Economics and Sciences, Canberra, November,
CC BY 4.0. [doi:10.25814/w175-xh85](https://doi.org/10.25814/w175-xh85)
.

## Examples

``` r
Y202021 <- .get_nlum(.data_set = "Y202021", .x = NULL)
#> Error in .get_nlum(.data_set = "Y202021", .x = NULL): could not find function ".get_nlum"

Y202021
#> Error: object 'Y202021' not found
```
