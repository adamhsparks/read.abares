# Unzip AGFD NetCDF files from ZIP

Unzip AGFD NetCDF files from ZIP

## Usage

``` r
.read_ncdf_from_zip(zip_path = fs::path_temp(), .fixed_prices = TRUE)
```

## Arguments

- zip_path:

  Path to the ZIP file containing NetCDF files.

## Value

A vector of paths to the extracted NetCDF files.
