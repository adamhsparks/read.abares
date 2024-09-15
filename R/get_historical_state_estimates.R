
#' Get Historical State Estimates from ABARES
#'
#'
#' @examplesIf interactive()
#' get_hist_state_est()
#'
#' @return A [data.table::data.table] object
#' @export
#' @aliases get_hist_sta_est
#' @examplesIf interactive
#'   get_hist_sta_est()
#'
get_historical_state_estimates <- function() {
  x <- data.table::fread("https://www.agriculture.gov.au/sites/default/files/documents/fdp-beta-state-historical.csv")
  return(x)
}
