# Create a custom user-agent string

Creates the user-agent string for read.abares for default values based
on whether the use is CI/development or interactive use.

## Usage

``` r
read.abares_user_agent()
```

## Source

<https://github.com/EMODnet/emodnet.wfs/blob/69ca933e5a4154cb651b1d3158072f86d0a7ccb9/R/emodnet.wfs-package.R>.

## Value

A character string to be used by
[httr2](https://CRAN.R-project.org/package=httr2) as a user-agent.

## Author

Adam H. Sparks and Maëlle Salmon
