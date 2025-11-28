# Unzip a zip file

Unzips the provided zip file into a folder named after the zip (without
.zip). If unzipping fails, it will return an error and delete any
partially-created extract directory.

## Usage

``` r
.unzip_file(.x)
```

## Arguments

- .x:

  A zip file for unzipping.

## Value

Invisible directory path, called for side effects.
