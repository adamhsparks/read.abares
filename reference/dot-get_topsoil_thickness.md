# Get ABARES' Topsoil Thickness for "Australian Areas of Intensive Agriculture of Layer 1"

Fetches topsoil thickness data and associated metadata from ABARES.

## Usage

``` r
.get_topsoil_thickness(.x = NULL)
```

## Source

<https://anrdl-integration-web-catalog-saxfirxkxt.s3-ap-southeast-2.amazonaws.com/warehouse/staiar9cl__059/staiar9cl__05911a01eg_geo___.zip>

## Arguments

- .x:

  A character string passed that provides a file path to the local
  directory holding the unzipped files for topsoil thickness.

## Value

A `read.abares.topsoil.thickness` object, which is a named
[`list()`](https://rdrr.io/r/base/list.html) with the
[`terra::rast()`](https://rspatial.github.io/terra/reference/rast.html)
object of the data and text file of metadata.

## Note

A custom [`print()`](https://rdrr.io/r/base/print.html) method is
provided that will print the metadata associated with these data.
Examples are provided for interacting with the metadata directly.

## References

<https://data.agriculture.gov.au/geonetwork/srv/eng/catalog.search#/metadata/faa9f157-8e17-4b23-b6a7-37eb7920ead6>

## Examples

``` r
x <- .get_topsoil_thickness(.x = NULL)
#> Error in .get_topsoil_thickness(.x = NULL): could not find function ".get_topsoil_thickness"

x
#> Error: object 'x' not found

# Extract the metadata as an object in your R session and use it with
# {pander}, useful for Markdown files

library(pander)
y <- x$metadata
#> Error: object 'x' not found
pander(y)
#> Error: object 'y' not found
```
