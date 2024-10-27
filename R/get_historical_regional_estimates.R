
#' Get Historical Regional Estimates from ABARES
#'
#' @note
#' Columns are renamed and reordered for consistency.
#'
#' @return A [data.table::data.table] object with the `Variable` field as the
#'  `key`.
#' @autoglobal
#' @family Estimates\
#' @source <https://www.agriculture.gov.au/abares/data/farm-data-portal#data-download>
#' @export
#' @examplesIf interactive()
#'  get_historical_regional_estimates()
#'
#'  # or shorter
#'  get_hist_reg_est()
#'
get_historical_regional_estimates <- get_hist_reg_est <-  function() {
  x <- data.table::fread("https://www.agriculture.gov.au/sites/default/files/documents/fdp-beta-regional-historical.csv")
  data.table::setnames(
    x,
    old = c("Variable", "Year", "ABARES region", "Value", "RSE"),
    new = c("Variable", "Year", "ABARES_region", "Value", "RSE")
  )
  data.table::setcolorder(x,
                          neworder = c("Variable",
                                       "Year",
                                       "ABARES_region",
                                       "Value",
                                       "RSE"))
  data.table::setkey(x, "Variable")
  return(x[])
}

#' @export
#' @rdname get_historical_regional_estimates
get_hist_reg_est <- get_historical_regional_estimates
