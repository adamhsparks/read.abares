
#' Get Historical Regional Estimates from ABARES
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
#' @source <https://www.agriculture.gov.au/sites/default/files/documents/fdp-regional-historical.csv>
#' @export
#' @examplesIf interactive()
#'  get_historical_regional_estimates()
#'
#'  # or shorter
#'  get_hist_reg_est()
#'
get_historical_regional_estimates <- get_hist_reg_est <-  function() {

  f <- file.path(tempdir(), "fdp-beta-regional-historical.csv")

  .retry_download(
    "https://www.agriculture.gov.au/sites/default/files/documents/fdp-regional-historical.csv",
    .f = f)

  x <- data.table::fread(f)
  data.table::setnames(
    x,
    old = c("Variable", "Year", "ABARES region", "Value", "RSE"),
    new = c("Variable", "Year", "ABARES_region", "Value", "RSE")
  )
  data.table::setcolorder(x,
                          neworder = c("Variable", "Year", "ABARES_region", "Value", "RSE"))
  data.table::setkey(x, "Variable")
  return(x[])
}

#' @export
#' @rdname get_historical_regional_estimates
get_hist_reg_est <- get_historical_regional_estimates
