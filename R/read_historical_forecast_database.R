#' Read ABARES' "Historical Forecast Database"
#'
#' Fetches and imports \acronym{ABARES} "Historical Forecast Database"
#'  performance data.
#'
#' @inheritParams read_aagis_regions
#'
#' # Data Dictionary
#' The resulting object will contain the following fields.
#'
#' | Field | Description |
#' |-------|-------------|
#' | Commodity | Broad description of commodity (includes the Australian dollar) |
#' | Estimate_type | Broad grouping of estimate by theme *e.g.*, animal numbers, area, production, price, export and volume measures. |
#' | Estimate_description | Detailed description of each series. |
#' | Unit | Measurement unit of series. *e.g.*, kt, $m, $/t. |
#' | Region | Relevant region for each series. "World" denotes relevant international market. |
#' | Year_Issued | Year that forecast was originally issued. |
#' | Month_issued | Month that forecast was originally issued. |
#' | Year_Issued_FY | Australian financial year (July-June) that forecast was originally issued. |
#' | Forecast_Year_FY | Australian financial year (July-June) for which the forecast was issued. Where forecast year is earlier than Year Issued (FY), value is a backcast. |
#' | Forecast_Value | Forecast as originally issued. |
#' | Actual_Value | Actual outcome observed. Note that historical time series can be revised. Latest available data at time of update, including any revisions, are included in database. |
#'
#' @note
#' Columns are renamed for consistency with other \acronym{ABARES} products
#'  serviced in this package using a snake_case format and ordered consistently.
#'
#' @note
#' The "Month_issued" column is converted from a character string to a numeric
#'  value representing the month of year, _e.g._, "March" is converted to `3`.
#'
#' @references <https://www.agriculture.gov.au/abares/research-topics/agricultural-outlook/historical-forecasts#:~:text=About%20the%20historical%20agricultural%20forecast,relevant%20to%20Australian%20agricultural%20markets>
#' @source <https://daff.ent.sirsidynix.net.au/client/en_AU/search/asset/1031941/0>
#'
#' @returns A [data.table::data.table()] object.
#'
#' @autoglobal
#' @export
#' @examplesIf interactive()
#'
#' read_historical_forecast_database()
#'
#' # or shorter
#' read_historical_forecast()
#'
read_historical_forecast_database <- function(x = NULL) {
  if (is.null(x)) {
    x <- fs::path(tempdir(), "historical_db.xlsx")

    .retry_download(
      "https://daff.ent.sirsidynix.net.au/client/en_AU/search/asset/1031941/0",
      .f = x
    )
  }

  x <- data.table::as.data.table(readxl::read_excel(
    x,
    sheet = "Database",
    na = "na"
  ))

  data.table::setnames(
    x,
    old = c(
      "Year_Issued",
      "Month_Issued",
      "Year_Issued_FY",
      "Forecast_Year_FY",
      "Forecast_Value",
      "Actual_Value",
      "Commodity",
      "Estimate_Type",
      "Estimate_description",
      "Unit",
      "Region"
    ),
    new = c(
      "Year_issued",
      "Month_issued",
      "Year_issued_FY",
      "Forecast_year_FY",
      "Forecast_value",
      "Actual_value",
      "Commodity",
      "Estimate_type",
      "Estimate_description",
      "Unit",
      "Region"
    )
  )

  x[,
    Month_issued := data.table::fcase(
      Month_issued == "January",
      1L,
      Month_issued == "February",
      2L,
      Month_issued == "March",
      3L,
      Month_issued == "April",
      4L,
      Month_issued == "May",
      5L,
      Month_issued == "June",
      6L,
      Month_issued == "July",
      7L,
      Month_issued == "August",
      8L,
      Month_issued == "September",
      9L,
      Month_issued == "October",
      10L,
      Month_issued == "November",
      11L,
      Month_issued == "December",
      12L
    )
  ]

  return(x[])
}

#' @export
#' @rdname read_historical_forecast_database
read_historical_forecast <- read_historical_forecast_database
