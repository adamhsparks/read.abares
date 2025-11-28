# Read ABARES' Catchment Scale "Land Use of Australia" Data Using Stars

Download and import catchment scale "Land Use of Australia" GeoTIFFs as
a [stars](https://CRAN.R-project.org/package=stars) object.

## Usage

``` r
read_clum_stars(data_set = "clum_50m_2023_v2", x = NULL, ...)
```

## Source

[doi:10.25814/2w2p-ph98](https://doi.org/10.25814/2w2p-ph98)

## Arguments

- data_set:

  A string value indicating the data desired for download. One of:

  clum_50m_2023_v2

  :   Catchment Scale Land Use of Australia – Update December 2023
      version 2

  scale_date_update

  :   Catchment Scale Land Use of Australia - Date and Scale of Mapping

  .

- x:

  A file path providing the file with the data to be imported. The file
  is assumed to be unarchived (*i.e.*, still zipped). This function does
  not provide any checking whether this function is the proper function
  for the provided file. Defaults to `NULL`, assuming that the file will
  be downloaded in the active R session.

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
documentation](https://www.agriculture.gov.au/sites/default/files/documents/CLUM_DescriptiveMetadata_December2023_v2.pdf)
"The Catchment Scale Land Use of Australia – Update December 2023
version 2 dataset is the national compilation of catchment scale land
use data available for Australia (CLUM), as at December 2023. It
replaces the Catchment Scale Land Use of Australia – Update December
2020. It is a seamless raster dataset that combines land use data for
all state and territory jurisdictions, compiled at a resolution of 50
metres by 50 metres. The CLUM data shows a single dominant land use for
a given area, based on the primary management objective of the land
manager (as identified by state and territory agencies). Land use is
classified according to the Australian Land Use and Management
Classification version 8. It has been compiled from vector land use
datasets collected as part of state and territory mapping programs and
other authoritative sources, through the Australian Collaborative Land
Use and Management Program. Catchment scale land use data was produced
by combining land tenure and other types of land use information
including, fine-scale satellite data, ancillary datasets, and
information collected in the field. The date of mapping (2008 to 2023)
and scale of mapping (1:5,000 to 1:250,000) vary, reflecting the source
data, capture date and scale. Date and scale of mapping are provided in
supporting datasets." – ABARES, 2024-06-27

## Note

The raster will load with the default category for each data set, but
you can specify a different category to use by passing the `RAT`
argument through the `...`. To see which categories are available,
please refer to the metadata for these data. The PDF can be accessed in
your default PDF viewer by using
[`view_nlum_metadata_pdf()`](https://adamhsparks.github.io/read.abares/reference/view_nlum_metadata_pdf.md).

## References

ABARES 2024, Catchment Scale Land Use of Australia – Update December
2023 version 2, Australian Bureau of Agricultural and Resource Economics
and Sciences, Canberra, June, CC BY 4.0, DOI:
[doi:10.25814/2w2p-ph98](https://doi.org/10.25814/2w2p-ph98)

## See also

Other clum:
[`read_clum_terra()`](https://adamhsparks.github.io/read.abares/reference/read_clum_terra.md)

## Examples

``` r
if (FALSE) { # interactive()

clum_stars <- read_clum_stars(data_set = "clum_50m_2023_v2")

clum_stars

plot(clum_stars)
}
```
