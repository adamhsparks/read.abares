
#' Get Historical State Estimates from ABARES
#'
#' @note
#' Columns are renamed and reordered for consistency.
#'
#' @return A [data.table::data.table] object with the `Variable` field as the
#'  `key`.
#' @autoglobal
#' @family Estimates
#' @source <https://www.agriculture.gov.au/abares/data/farm-data-portal#data-download>
#' @export
#' @examplesIf interactive()
#'  get_historical_state_estimates()
#'
#'  # or shorter
#'  get_hist_sta_est()
#'
get_historical_state_estimates <- get_hist_sta_est <- function() {
  f <- file.path(tempdir(), "fdp-beta-state-historical.csv")
  curl::curl_download(
    url = "https://www.agriculture.gov.au/sites/default/files/documents/fdp-beta-state-historical.csv",
    destfile = f,
    handle = create_handle())
  x <- data.table::fread(f)
  data.table::setcolorder(
    x,
    c("Variable", "Year", "State", "Industry", "Value", "RSE")
  )
  data.table::setkey(x, "Variable")
  return(x[])
}

#' @export
#' @rdname get_historical_state_estimates
get_hist_sta_est <- get_historical_state_estimates
