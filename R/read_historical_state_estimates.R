#' Read 'Historical State Estimates' from ABARES
#'
#' Fetches and imports \acronym{ABARES} historical state estimates data.
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
#' @source <https://www.agriculture.gov.au/sites/default/files/documents/fdp-state-historical.csv>
#' @export
#' @examplesIf interactive()
#' read_historical_state_estimates()
#'
#' # or shorter
#' read_hist_sta_est()
#'
read_historical_state_estimates <- read_hist_sta_est <- function() {
  f <- fs::path(tempdir(), "fdp-beta-state-historical.csv")

  .retry_download(
    "https://www.agriculture.gov.au/sites/default/files/documents/fdp-state-historical.csv",
    .f = f
  )

  x <- data.table::fread(f)
  data.table::setcolorder(
    x,
    c("Variable", "Year", "State", "Industry", "Value", "RSE")
  )
  data.table::setkey(x, "Variable")
  return(x[])
}

#' @export
#' @rdname read_historical_state_estimates
read_hist_sta_est <- read_historical_state_estimates
