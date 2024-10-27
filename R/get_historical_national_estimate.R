
#' Get Historical National Estimates from ABARES
#'
#' @note
#' Columns are renamed and reordered for consistency.
#'
#' @return A [data.table::data.table] object with the `variable` field as the
#'  `key`.
#' @autoglobal
#' @export
#' @examplesIf interactive()
#'
#'  get_historical_national_estimates()
#'
#'  # or shorter
#'  get_hist_nat_est()
#'
get_historical_national_estimates <- function() {
  x <- data.table::fread(
    "https://www.agriculture.gov.au/sites/default/files/documents/fdp-beta-national-historical.csv"
  )

  data.table::setkey(x, "Variable")
  return(x[])
}

#' @export
#' @rdname get_historical_national_estimates
get_hist_nat_est <- get_historical_national_estimates
