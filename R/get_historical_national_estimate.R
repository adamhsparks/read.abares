
#' Get Historical National Estimates from ABARES
#'
#'
#' @examplesIf interactive()
#' get_hist_nat_est()
#'
#' @return a [data.table::data.table] object
#' @export
#' @aliases get_hist_nat_est
#' @examples
#'
get_historical_national_est <- function() {
  x <- data.table::fread("https://www.agriculture.gov.au/sites/default/files/documents/fdp-beta-national-historical.csv")
  return(x)
}
