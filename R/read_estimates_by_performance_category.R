#' Read ABARES' "Estimates by Performance"
#'
#' Fetches and imports \acronym{ABARES} estimates by performance category data.
#'
#' @note
#' Columns are renamed for consistency with other \acronym{ABARES} products
#'  serviced in this package using a snake_case format and ordered consistently.
#'
#' @returns A [data.table::data.table()] object.
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
  f <- fs::path(tempdir(), "fdp-BySize-ByPerformance.csv")

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
