
#' Get Historical State Estimates from ABARES
#'
#' @note
#' Columns are renamed and reordered for consistency.
#'
#' @return A [data.table::data.table] object with the `variable` field as the
#'  `key`.
#' @autoglobal
#' @family Estimates
#' @export
#' @examplesIf interactive()
#'  get_historical_state_estimates()
#'
#'  # or shorter
#'  get_hist_sta_est()
#'
get_historical_state_estimates <- get_hist_sta_est <- function() {
  x <- data.table::fread(
    "https://www.agriculture.gov.au/sites/default/files/documents/fdp-beta-state-historical.csv"
  )
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
