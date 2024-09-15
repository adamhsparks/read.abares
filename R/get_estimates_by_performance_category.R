
#' Get Estimates by Size From ABARES
#'
#'
#' @examplesIf interactive()
#' get_est_by_perf()
#'
#' @return A [data.table::data.table] object
#' @export
#' @examplesIf interactive
#'  get_est_by_perf_cat()
#'
get_estimates_by_performance_category <- get_est_by_perf_cat <- function() {
  x <- data.table::fread("https://www.agriculture.gov.au/sites/default/files/documents/fdp-BySize-ByPerformance.csv")
  return(x)
}
