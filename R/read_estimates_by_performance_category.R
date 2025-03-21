#' Read 'Estimates by Size' from ABARES
#'
#' @returns A [data.table::data.table] object.
#' @export
#' @references <https://www.agriculture.gov.au/abares/data/farm-data-portal#data-download>
#' @source <https://www.agriculture.gov.au/sites/default/files/documents/fdp-BySize-ByPerformance.csv>
#' @family Estimates
#' @autoglobal
#' @examplesIf interactive()
#'
#' read_estimates_by_performance_category()
#'
#' # or shorter
#' read_est_by_perf_cat()
#'
read_estimates_by_performance_category <- function() {
  f <- file.path(tempdir(), "fdp-BySize-ByPerformance.csv")

  .retry_download(
    "https://www.agriculture.gov.au/sites/default/files/documents/fdp-BySize-ByPerformance.csv",
    .f = f
  )

  x <- data.table::fread(f)
  return(x[])
}

#' @export
#' @rdname read_estimates_by_performance_category
read_est_by_perf_cat <- read_estimates_by_performance_category
