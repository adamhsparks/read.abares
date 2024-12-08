#' Read Historical National Estimates from ABARES
#'
#' @note
#' Columns are renamed for consistency with other \acronym{ABARES} products
#'  serviced in this package using a snake_case format and ordered consistently.
#'
#' @return A [data.table::data.table] object with the `Variable` field as the
#'  `key`.
#' @autoglobal
#' @family Estimates
#' @references <https://www.agriculture.gov.au/abares/data/farm-data-portal#data-download>
#' @source <https://www.agriculture.gov.au/sites/default/files/documents/fdp-national-historical.csv>
#' @export
#' @examplesIf interactive()
#'
#' read_historical_national_estimates()
#'
#' # or shorter
#' read_hist_nat_est()
#'
read_historical_national_estimates <- function() {
  f <- file.path(tempdir(), "fdp-beta-national-historical.csv")

  .retry_download(
    "https://www.agriculture.gov.au/sites/default/files/documents/fdp-national-historical.csv",
    .f = f
  )

  x <- data.table::fread(f)
  data.table::setcolorder(x, neworder = c("Variable", "Year", "Industry", "Value", "RSE"))
  data.table::setkey(x, "Variable")
  return(x[])
}

#' @export
#' @rdname read_historical_national_estimates
read_hist_nat_est <- read_historical_national_estimates
