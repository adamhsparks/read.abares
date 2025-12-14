# Read ABARES' National Scale "Land Use of Australia" Data Using stars

Download and import national scale "Land Use of Australia v7" GeoTIFFs
as a [stars](https://CRAN.R-project.org/package=stars) object.

## Usage

``` r
read_nlum_stars(data_set = NULL, x = NULL, ...)
```

## Source

- Y201011:

  <https://www.agriculture.gov.au/sites/default/files/documents/NLUM_v7_250_ALUMV8_2010_11_alb_package_20241128.zip>

- Y201516:

  <https://www.agriculture.gov.au/sites/default/files/documents/NLUM_v7_250_ALUMV8_2015_16_alb_package_20241128.zip>

- Y202021:

  <https://www.agriculture.gov.au/sites/default/files/documents/NLUM_v7_250_ALUMV8_2020_21_alb_package_20241128.zip>

- C201021:

  <https://www.agriculture.gov.au/sites/default/files/documents/NLUM_v7_250_CHANGE_SIMP_2011_to_2021_alb_package_20241128.zip>

- T201011:

  <https://www.agriculture.gov.au/sites/default/files/documents/NLUM_v7_250_INPUTS_2010_11_geo_package_20241128.zip>

- T201516:

  <https://www.agriculture.gov.au/sites/default/files/documents/NLUM_v7_250_INPUTS_2015_16_geo_package_20241128.zip>

- T202021:

  <https://www.agriculture.gov.au/sites/default/files/documents/NLUM_v7_250_INPUTS_2020_21_geo_package_20241128.zip>

- P201011:

  <https://www.agriculture.gov.au/sites/default/files/documents/NLUM_v7_250_AgProbabilitySurfaces_2010_11_geo_package_20241128.zip>

- P201516:

  <https://www.agriculture.gov.au/sites/default/files/documents/NLUM_v7_250_AgProbabilitySurfaces_2015_16_geo_package_20241128.zip>

- P202021:

  <https://www.agriculture.gov.au/sites/default/files/documents/NLUM_v7_250_AgProbabilitySurfaces_2020_21_geo_package_20241128.zip>

.

## Arguments

- data_set:

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

  . This argument is ignored if `x` is provided.

- x:

  A character string of a file path to a local zip file that has been
  downloaded outside of R that contains the NLUM data. This argument is
  ignored if `data_set` is provided.

- ...:

  Additional arguments passed to
  [`stars::read_stars()`](https://r-spatial.github.io/stars/reference/read_stars.html),
  for *e.g.*, `RAT` if you wish to set the active category when loading
  any of the available GeoTIFF files that are encoded with a raster
  attribute table.

## Value

a [stars](https://CRAN.R-project.org/package=stars) object that may be
one or many layers depending upon the requested data set.

## Details

From the [ABARES
website](https://www.agriculture.gov.au/abares/aclump/land-use/land-use-of-australia-2010-11-to-2020-21):
"The *Land use of Australia 2010–11 to 2020–21* data package consists of
seamless continental rasters that present land use at national scale for
2010–11, 2015–16 and 2020–21 and the associated change between each
target period. Non-agricultural land uses are mapped using 7 thematic
layers, derived from existing datasets provided by state and territory
jurisdictions and external agencies. These 7 layers are: protected
areas, topographic features, land tenure, forest type, catchment scale
land use, urban boundaries, and stock routes. The agricultural land uses
are based on the Australian Bureau of Statistics’ 2010–11, 2015–16 and
2020–21 agricultural census data; with spatial distributions modelled
using Terra Moderate Resolution Imaging Spectroradiometer (MODIS)
satellite imagery and training data, assisted by spatial constraint
layers for cultivation, horticulture, and irrigation. Land use is
specified according to the Australian Land Use and Management (ALUM)
Classification version 8. The same method is applied to all target
periods using representative national datasets for each period, where
available. All rasters are in GeoTIFF format with geographic coordinates
in Geocentric Datum of Australian 1994 (GDA94) and a 0.002197 degree
(~250 metre) cell size. The *Land use of Australia 2010–11 to 2020–21*
data package is a product of the Australian Collaborative Land Use and
Management Program. This data package replaces the Land use of Australia
2010–11 to 2015–16 data package, with updates to these time periods." –
ABARES, 2024-11-28

## Note

The raster will load with the default category for each data set, but
you can specify a different category to use by passing the `RAT`
argument through the `...`. To see which categories are available,
please refer to the metadata for these data. The PDF can be accessed in
your default PDF viewer by using
[`view_nlum_metadata_pdf()`](https://adamhsparks.github.io/read.abares/reference/view_nlum_metadata_pdf.md).

## proj

Which should you choose? If you need accurate area calculations (*e.g.*,
hectares of land use), use Albers. If you just need global compatibility
or want to overlay with other lat/long datasets, use Geographic.

## References

ABARES 2024, Land use of Australia 2010–11 to 2020–21, Australian Bureau
of Agricultural and Resource Economics and Sciences, Canberra, November,
CC BY 4.0. [doi:10.25814/w175-xh85](https://doi.org/10.25814/w175-xh85)

## See also

Other nlum:
[`read_nlum_terra()`](https://adamhsparks.github.io/read.abares/reference/read_nlum_terra.md),
[`view_clum_metadata_pdf()`](https://adamhsparks.github.io/read.abares/reference/view_clum_metadata_pdf.md),
[`view_nlum_metadata_pdf()`](https://adamhsparks.github.io/read.abares/reference/view_nlum_metadata_pdf.md)

## Examples

``` r
if (FALSE) { # interactive()

nlum_stars <- read_nlum_stars("Y202021")

nlum_stars

plot(nlum_stars)
}
```
