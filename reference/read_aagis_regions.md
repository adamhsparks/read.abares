# Read ABARES' "Australian Agricultural and Grazing Industries Survey" (AAGIS) Region Mapping Files

Download import the "Australian Agricultural and Grazing Industries
Survey" (AAGIS) regions geospatial shapefile.

## Usage

``` r
read_aagis_regions(x = NULL)
```

## Source

<https://www.agriculture.gov.au/sites/default/files/documents/aagis_asgs16v1_g5a.shp_.zip>.

## Arguments

- x:

  A file path providing the file with the data to be imported. The file
  is assumed to be unarchived (*i.e.*, still zipped). This function does
  not provide any checking whether this function is the proper function
  for the provided file. Defaults to `NULL`, assuming that the file will
  be downloaded in the active R session.

## Value

An [sf](https://CRAN.R-project.org/package=sf) object of the AAGIS
regions.

## Note

Upon import a few operations are carried out,

- the geometries are automatically corrected to fix invalid geometries
  that are present in the original shapefile,

- column names are set to start with a upper-case letter,

- the original column named, "name", is set to "AAGIS_region" to align
  with column names that the
  [`data.table::data.table()`](https://rdatatable.gitlab.io/data.table/reference/data.table.html)
  provided by
  [`read_historical_regional_estimates()`](https://adamhsparks.github.io/read.abares/reference/read_historical_regional_estimates.md)
  to allow for easier merging of data for mapping, and,

- a new column, "State" is added to be used for mapping state estimates
  with data for mapping state historical estimate values found in the
  [`data.table::data.table()`](https://rdatatable.gitlab.io/data.table/reference/data.table.html)
  from
  [`read_historical_state_estimates()`](https://adamhsparks.github.io/read.abares/reference/read_historical_state_estimates.md).

## References

<https://www.agriculture.gov.au/abares/research-topics/surveys/farm-definitions-methods#regions>.

## Examples

``` r
if (FALSE) { # interactive()
aagis <- read_aagis_regions()

plot(aagis)
}
```
