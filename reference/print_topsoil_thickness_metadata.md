# Displays the text file Metadata for ABARES' Topsoil Thickness for "Australian Areas of Intensive Agriculture of Layer 1"

Displays the complete set of metadata associated with the soil thickness
data in your R console. For including the metadata in documents or other
methods outside of R, see
[`.get_topsoil_thickness()`](https://adamhsparks.github.io/read.abares/reference/dot-get_topsoil_thickness.md)
for an example using
[`pander::pander()`](https://rdrr.io/pkg/pander/man/pander.html) to
print the metadata.

## Usage

``` r
print_topsoil_thickness_metadata(x = NULL)
```

## Source

<https://anrdl-integration-web-catalog-saxfirxkxt.s3-ap-southeast-2.amazonaws.com/warehouse/staiar9cl__059/staiar9cl__05911a01eg_geo___.zip>

## Arguments

- x:

  A `read.abares.topsoil.thickness` object.

## Value

Nothing, called for its side effects, it prints the complete metadata
file to the R console.

## Note

The original metadata use a title of "Soil Thickness", in the context of
this package, we refer to it as "Topsoil Thickness" to be consistent
with the actual values in the data.

## References

<https://data.agriculture.gov.au/geonetwork/srv/eng/catalog.search#/metadata/faa9f157-8e17-4b23-b6a7-37eb7920ead6>

## See also

Other topsoil thickness:
[`read_topsoil_thickness_stars()`](https://adamhsparks.github.io/read.abares/reference/read_topsoil_thickness_stars.md),
[`read_topsoil_thickness_terra()`](https://adamhsparks.github.io/read.abares/reference/read_topsoil_thickness_terra.md)

## Examples

``` r
if (FALSE) { # interactive()
print_topsoil_thickness_metadata()
}
```
