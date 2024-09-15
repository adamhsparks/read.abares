
#' Get Historical Regional Estimates from ABARES
#'
#'
#' @examplesIf interactive()
#' get_hist_regional_est()
#'
#' @return a [data.table::data.table] object
#' @export
#' @aliases get_hist_regional_est
#' @examples
#'
get_historical_regional_estimates <- function() {
  x <- data.table::fread("https://www.agriculture.gov.au/sites/default/files/documents/fdp-beta-regional-historical.csv")
  return(x)
}
