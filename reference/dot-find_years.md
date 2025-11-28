# Find Which Financial Years Data are Available

Grabs the ABS website and uses a regexp to find what financial years are
available for download.

## Usage

``` r
.find_years(data_set)
```

## Arguments

- as:

  string providing the data set that is being requested. One of:

  - broadacre,

  - horticultural, or

  - livestock.

## Value

A string value of financial years that match availability from the ABS
website, *e.g.*, `2023-24`.
