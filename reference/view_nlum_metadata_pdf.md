# Displays PDF Metadata for ABARES' "National Land Use" (NLUM) Raster Files in a Native Viewer

Each National Land Use (NLUM) raster file comes with a PDF of metadata.
This function will open and display that file using the native PDF
viewer for any system with a graphical user interface and PDF viewer
configured. If the file does not exist locally, it will be fetched and
displayed.

## Usage

``` r
view_nlum_metadata_pdf()
```

## Value

An invisible `NULL`. Called for its side-effects, opens the system's
native PDF viewer to display the requested metadata PDF document.

## See also

Other nlum:
[`read_nlum_stars()`](https://adamhsparks.github.io/read.abares/reference/read_nlum_stars.md),
[`read_nlum_terra()`](https://adamhsparks.github.io/read.abares/reference/read_nlum_terra.md),
[`view_clum_metadata_pdf()`](https://adamhsparks.github.io/read.abares/reference/view_clum_metadata_pdf.md)

## Examples

``` r
if (FALSE) { # interactive()
view_nlum_metadata_pdf()
}
```
