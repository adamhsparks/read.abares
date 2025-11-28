# Displays the PDF Metadata for ABARES' "Catchment Land Use" (CLUM) Raster Files in a Native Viewer

Each "Catchment Land Use" (CLUM) raster file comes with a PDF of
metadata. This function will open and display that file using the native
PDF viewer for any system with a graphical user interface and PDF viewer
configured. If the file does not exist locally, it will be fetched and
displayed.

## Usage

``` r
view_clum_metadata_pdf(commodities = FALSE)
```

## Source

- CLUM Metadata:

  https://www.agriculture.gov.au/sites/default/files/documents/CLUM_DescriptiveMetadata_December2023_v2.pdf

- CLUM Commodities Metadata:

  https://www.agriculture.gov.au/sites/default/files/documents/CLUMC_DescriptiveMetadata_December2023.pdf

## Arguments

- commodities:

  A `Boolean` value that indicates whether to download the catchment
  land scale use metadata for commodities. Defaults to `FALSE`,
  downloading the "Catchment Land Scale Use Metadata".

## Value

An invisible `NULL`. Called for its side-effects, opens the system's
native PDF viewer to display the requested metadata PDF document.

## See also

Other nlum:
[`read_nlum_stars()`](https://adamhsparks.github.io/read.abares/reference/read_nlum_stars.md),
[`read_nlum_terra()`](https://adamhsparks.github.io/read.abares/reference/read_nlum_terra.md),
[`view_nlum_metadata_pdf()`](https://adamhsparks.github.io/read.abares/reference/view_nlum_metadata_pdf.md)

## Examples

``` r
if (FALSE) { # interactive()
view_clum_metadata_pdf()
}
```
