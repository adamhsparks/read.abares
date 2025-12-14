# Unified CLUM and NLUM Checks and Downloading Automation

Checks user inputs for CLUM and NLUM functions and validates inputs. If
no file is provided, downloads the data set. If `x` is provided, checks
that the file exists and has the proper files in it. Calls the
respective CLUM or NLUM download function.

## Usage

``` r
.get_lum_files(x, data_set, lum)
```

## Arguments

- data_set:

  A user provided string value.

- lum:

  A string value indicating whether to process 'clum' or 'nlum' data.

## Value

A list object containing the path to the zip file and the filename of
the GeoTIFF contained in the zip file.

## Examples

``` r
# for NLUM data download
.get_lum_files(x = NULL, data_set = "Y202021", lum = "nlum")
#> Error in .get_lum_files(x = NULL, data_set = "Y202021", lum = "nlum"): could not find function ".get_lum_files"

# for CLUM data download
.get_lum_files(x = NULL, data_set = "clum_50m_2023_v2", lum = "clum")
#> Error in .get_lum_files(x = NULL, data_set = "clum_50m_2023_v2", lum = "clum"): could not find function ".get_lum_files"
```
