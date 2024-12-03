
#' Get Historical State Estimates from ABARES
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
#' @source <https://www.agriculture.gov.au/sites/default/files/documents/fdp-state-historical.csv>
#' @export
#' @examplesIf interactive()
#'  get_historical_state_estimates()
#'
#'  # or shorter
#'  get_hist_sta_est()
#'
get_historical_state_estimates <- get_hist_sta_est <- function() {
  f <- file.path(tempdir(), "fdp-beta-state-historical.csv")

  .retry_download(
    "https://www.agriculture.gov.au/sites/default/files/documents/fdp-state-historical.csv",
    .f = f)

  x <- data.table::fread(f)
  data.table::setcolorder(
    x,
    c("Variable", "Year", "State", "Industry", "Value", "RSE")
  )
  data.table::setkey(x, "Variable")
  return(x[])
}

#' @export
#' @rdname get_historical_state_estimates
get_hist_sta_est <- get_historical_state_estimates
