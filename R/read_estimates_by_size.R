#' Read ABARES' "Estimates by Size"
#'
#' Fetches and imports \acronym{ABARES} estimates by size data.
#'
#' @inheritParams read_aagis_regions
#'
#' @note
#' Columns are renamed for consistency with other \acronym{ABARES} products
#'  serviced in this package using a snake_case format and ordered consistently.
#'
#' @returns A [data.table::data.table()] object with the `Variable` field as the
#'  `key`.
#' @references
#' <https://www.agriculture.gov.au/abares/data/farm-data-portal#data-download>.
#' @source
#' <https://www.agriculture.gov.au/sites/default/files/documents/fdp-national-historical.csv>.
#' @autoglobal
#' @family Estimates
#' @export
#' @examplesIf interactive()
#'
#' read_estimates_by_size()
#'
#' # or shorter
#' read_est_by_size()
#'
read_estimates_by_size <- read_est_by_size <- function(x = NULL) {
  if (is.null(x)) {
    x <- fs::path(tempdir(), "fdp-beta-performance-by-size.csv")

    .retry_download(
      "https://www.agriculture.gov.au/sites/default/files/documents/fdp-performance-by-size.csv",
      dest = x
    )
  }
  x <- data.table::fread(x)
  data.table::setcolorder(
    x,
    neworder = c("Variable", "Year", "Size", "Industry", "Value", "RSE")
  )
  data.table::setkey(x, "Variable")

  return(x[])
}

#' @export
#' @rdname read_estimates_by_size
read_est_by_size <- read_estimates_by_size
