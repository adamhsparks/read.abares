# Get ABARES' Catchment Scale "Land Use of Australia" Data

An internal function used by
[`read_clum_terra()`](https://adamhsparks.github.io/read.abares/reference/read_clum_terra.md)
and
[`read_clum_stars()`](https://adamhsparks.github.io/read.abares/reference/read_clum_stars.md)
that downloads catchment level land use data files.

## Usage

``` r
.get_clum(.data_set, .x)
```

## Source

- Land Use: [doi:10.25814/2w2p-ph98](https://doi.org/10.25814/2w2p-ph98)
  ,

- Commodities:
  [doi:10.25814/zfjz-jt75](https://doi.org/10.25814/zfjz-jt75) .

## Arguments

- .data_set:

  A string value indicating the data desired for download. One of:

  clum_50m_2023_v2

  :   Catchment Scale Land Use of Australia – Update December 2023
      version 2

  scale_date_update

  :   Catchment Scale Land Use of Australia - Date and Scale of Mapping

  .

- .x:

  A user specified path to a local zip file containing the data.

## Value

A list of files containing a spatial data file of or files related to
Australian catchment scale land use data.

## References

ABARES 2024, Catchment Scale Land Use of Australia – Update December
2023 version 2, Australian Bureau of Agricultural and Resource Economics
and Sciences, Canberra, June, CC BY 4.0, DOI:
[doi:10.25814/2w2p-ph98](https://doi.org/10.25814/2w2p-ph98) .

## Examples

``` r
clum_update <- .get_clum(.data_set = "scale_date_update", .x = NULL)
#> Error in .get_clum(.data_set = "scale_date_update", .x = NULL): could not find function ".get_clum"

clum_update
#> Error: object 'clum_update' not found
```
