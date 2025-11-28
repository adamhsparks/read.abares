# Read ABARES' Catchment Scale "Land Use of Australia" Commodities Shapefile

Download (if desired) catchment level land use commodity data shapefile
and import it into your active R session after correcting invalid
geometries.

## Usage

``` r
read_clum_commodities(x = NULL)
```

## Source

[doi:10.25814/zfjz-jt75](https://doi.org/10.25814/zfjz-jt75)

## Arguments

- x:

  A file path providing the file with the data to be imported. The file
  is assumed to be unarchived (*i.e.*, still zipped). This function does
  not provide any checking whether this function is the proper function
  for the provided file. Defaults to `NULL`, assuming that the file will
  be downloaded in the active R session.

## Value

An [`sf::sf()`](https://r-spatial.github.io/sf/reference/sf.html)
object.

## References

ABARES 2024, Catchment Scale Land Use of Australia – Update December
2023 version 2, Australian Bureau of Agricultural and Resource Economics
and Sciences, Canberra, June, CC BY 4.0, DOI:
[doi:10.25814/2w2p-ph98](https://doi.org/10.25814/2w2p-ph98) .

## Examples

``` r
if (FALSE) { # interactive()
clum_commodities <- read_clum_commodities()

clum_commodities
}
```
