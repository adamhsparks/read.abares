
#' Get Estimates by Size From ABARES
#'
#' @return A [data.table::data.table] object
#' @export
#' @source <https://www.agriculture.gov.au/abares/data/farm-data-portal#data-download>
#' @family Estimates
#' @autoglobal
#' @examplesIf interactive()
#'
#'  get_estimates_by_performance_category()
#'
#'  # or shorter
#'  get_est_by_perf_cat()
#'
get_estimates_by_performance_category <- get_est_by_perf_cat <- function() {
  x <- data.table::fread("https://www.agriculture.gov.au/sites/default/files/documents/fdp-BySize-ByPerformance.csv")
  return(x)
}

#' @export
#' @rdname get_estimates_by_performance_category
get_est_by_perf_cat <- get_estimates_by_performance_category
