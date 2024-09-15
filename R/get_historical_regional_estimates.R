
#' Get Historical Regional Estimates from ABARES
#'
#'
#' @examplesIf interactive()
#' get_hist_regional_est()
#'
#' @return A [data.table::data.table] object
#' @export
#' @examplesIf interactive()
#'  get_hist_reg_est()
#'
get_historical_regional_estimates <- get_hist_reg_est <-  function() {
  x <- data.table::fread("https://www.agriculture.gov.au/sites/default/files/documents/fdp-beta-regional-historical.csv")
  return(x)
}

#' @export
#' @rdname get_historical_regional_estimates
get_hist_reg_est <- get_historical_regional_estimates
