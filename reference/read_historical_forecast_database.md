# Read ABARES' "Historical Forecast Database"

Fetches and imports ABARES "Historical Forecast Database" performance
data.

## Usage

``` r
read_historical_forecast_database(x = NULL)

read_historical_forecast(x = NULL)
```

## Source

<https://daff.ent.sirsidynix.net.au/client/en_AU/search/asset/1031941/0>.

## Arguments

- x:

  A file path providing the file with the data to be imported. The file
  is assumed to be unarchived locally. This function does not provide
  any checking whether this function is the proper function for the
  provided file. Defaults to `NULL`, assuming that the file will be
  downloaded in the active R session.

## Value

A
[`data.table::data.table()`](https://rdatatable.gitlab.io/data.table/reference/data.table.html)
object.

## Note

Columns are renamed for consistency with other ABARES products serviced
in this package using a snake_case format and ordered consistently.

The "Month_issued" column is converted from a character string to a
numeric value representing the month of year, *e.g.*, "March" is
converted to `3`.

## Data Dictionary

The resulting object will contain the following fields.

|                      |                                                                                                                                                                       |
|----------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Field                | Description                                                                                                                                                           |
| Commodity            | Broad description of commodity (includes the Australian dollar)                                                                                                       |
| Estimate_type        | Broad grouping of estimate by theme *e.g.*, animal numbers, area, production, price, export and volume measures.                                                      |
| Estimate_description | Detailed description of each series.                                                                                                                                  |
| Unit                 | Measurement unit of series. *e.g.*, kt, \$m, \$/t.                                                                                                                    |
| Region               | Relevant region for each series. "World" denotes relevant international market.                                                                                       |
| Year_Issued          | Year that forecast was originally issued.                                                                                                                             |
| Month_issued         | Month that forecast was originally issued.                                                                                                                            |
| Year_Issued_FY       | Australian financial year (July-June) that forecast was originally issued.                                                                                            |
| Forecast_Year_FY     | Australian financial year (July-June) for which the forecast was issued. Where forecast year is earlier than Year Issued (FY), value is a backcast.                   |
| Forecast_Value       | Forecast as originally issued.                                                                                                                                        |
| Actual_Value         | Actual outcome observed. Note that historical time series can be revised. Latest available data at time of update, including any revisions, are included in database. |

## References

<https://www.agriculture.gov.au/abares/research-topics/agricultural-outlook/historical-forecasts#:~:text=About%20the%20historical%20agricultural%20forecast,relevant%20to%20Australian%20agricultural%20markets>.

## Examples

``` r
if (FALSE) { # interactive()

read_historical_forecast_database()

# or shorter
read_historical_forecast()
}
```
