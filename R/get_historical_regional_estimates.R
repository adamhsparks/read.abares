
#' Get Historical Regional Estimates from ABARES
#'
#' @return A [data.table::data.table] object
#' @autoglobal
#' @export
#' @examplesIf interactive()
#'  get_historical_regional_estimates()
#'
#'  # or shorter
#'  get_hist_reg_est()
#'
get_historical_regional_estimates <- get_hist_reg_est <-  function() {
  x <- data.table::fread("https://www.agriculture.gov.au/sites/default/files/documents/fdp-beta-regional-historical.csv")
  return(x)
}

#' @export
#' @rdname get_historical_regional_estimates
get_hist_reg_est <- get_historical_regional_estimates
