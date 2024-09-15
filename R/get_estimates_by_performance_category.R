
#' Get Estimates by Size From ABARES
#'
#'
#' @examplesIf interactive()
#' get_est_by_perf()
#'
#' @return a [data.table::data.table] object
#' @export
#' @aliases get_est_by_perf
#' @examples
#'
get_estimates_by_performance <- function() {
  x <- data.table::fread("https://www.agriculture.gov.au/sites/default/files/documents/fdp-BySize-ByPerformance.csv")
  return(x)
}
