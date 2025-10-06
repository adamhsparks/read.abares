#' Read ABARES' "Historical Regional Estimates"
#'
#' Fetches and imports \acronym{ABARES} "Historical Regional Estimates" data.
#'
#' @inheritParams read_aagis_regions
#'
#' @note
#' Columns are renamed for consistency with other \acronym{ABARES} products
#'  serviced in this package using a snake_case format and ordered consistently.
#'
#' @returns A [data.table::data.table()] object with the `Variable` field as the
#'  `key`.
#' @autoglobal
#' @family Estimates
#' @references <https://www.agriculture.gov.au/abares/data/farm-data-portal#data-download>
#' @source <https://www.agriculture.gov.au/sites/default/files/documents/fdp-regional-historical.csv>
#' @export
#' @examplesIf interactive()
#' read_historical_regional_estimates()
#'
#' # or shorter
#' read_hist_reg_est()
#'
read_historical_regional_estimates <- read_hist_reg_est <- function(
  x = NULL
) {
  if (is.null(x)) {
    x <- fs::path(tempdir(), "fdp-beta-regional-historical.csv")

    .retry_download(
      "https://www.agriculture.gov.au/sites/default/files/documents/fdp-regional-historical.csv",
      dest = x,
      dataset_id = "historical_regional_estimates",
      show_progress = TRUE
    )
  }

  x <- data.table::fread(x)
  data.table::setnames(
    x,
    old = c("Variable", "Year", "ABARES region", "Value", "RSE"),
    new = c("Variable", "Year", "ABARES_region", "Value", "RSE")
  )
  data.table::setcolorder(
    x,
    neworder = c("Variable", "Year", "ABARES_region", "Value", "RSE")
  )
  data.table::setkey(x, "Variable")
  return(x[])
}

#' @export
#' @rdname read_historical_regional_estimates
read_hist_reg_est <- read_historical_regional_estimates
