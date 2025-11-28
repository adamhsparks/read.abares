# Read ABARES' "Soil Thickness for Australian Areas of Intensive Agriculture of Layer 1" with stars

Read "Soil Thickness for Australian Areas of Intensive Agriculture of
Layer 1" data as a [stars](https://CRAN.R-project.org/package=stars)
object.

## Usage

``` r
read_topsoil_thickness_stars(x = NULL, ...)
```

## Source

<https://anrdl-integration-web-catalog-saxfirxkxt.s3-ap-southeast-2.amazonaws.com/warehouse/staiar9cl__059/staiar9cl__05911a01eg_geo___.zip>

## Arguments

- x:

  A file path providing the file with the data to be imported. The file
  is assumed to be unarchived (*i.e.*, still zipped). This function does
  not provide any checking whether this function is the proper function
  for the provided file. Defaults to `NULL`, assuming that the file will
  be downloaded in the active R session.

- ...:

  Additional arguments passed to
  [`stars::st_as_stars()`](https://r-spatial.github.io/stars/reference/st_as_stars.html),
  for *e.g.*, `att` if you wished to set the active category.

## Value

A [stars](https://rdrr.io/r/graphics/stars.html) object of the "Soil
Thickness for Australian Areas of Intensive Agriculture of Layer 1".

## Note

This function converts a
[`terra::rast()`](https://rspatial.github.io/terra/reference/rast.html)
object internally rather than reading directly from a file.

## References

<https://data.agriculture.gov.au/geonetwork/srv/eng/catalog.search#/metadata/faa9f157-8e17-4b23-b6a7-37eb7920ead6>

## See also

Other topsoil thickness:
[`print_topsoil_thickness_metadata()`](https://adamhsparks.github.io/read.abares/reference/print_topsoil_thickness_metadata.md),
[`read_topsoil_thickness_terra()`](https://adamhsparks.github.io/read.abares/reference/read_topsoil_thickness_terra.md)

## Examples

``` r
if (FALSE) { # interactive()
st_stars <- read_topsoil_thickness_stars()

plot(st_stars)
}
```
