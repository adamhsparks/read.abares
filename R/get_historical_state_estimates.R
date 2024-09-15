
#' Get Historical State Estimates from ABARES
#'
#' @return A [data.table::data.table] object
#' @export
#' @examplesIf interactive
#'  get_historical_state_estimates()
#'
#'  # or shorter
#'  get_hist_sta_est()
#'
get_historical_state_estimates <- get_hist_sta_est <- function() {
  x <- data.table::fread("https://www.agriculture.gov.au/sites/default/files/documents/fdp-beta-state-historical.csv")
  return(x)
}

#' @export
#' @rdname get_historical_state_estimates
get_hist_sta_est <- get_historical_state_estimates
