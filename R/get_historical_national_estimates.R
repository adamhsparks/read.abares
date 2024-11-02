
#' Get Historical National Estimates from ABARES
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
#'
#'  get_historical_national_estimates()
#'
#'  # or shorter
#'  get_hist_nat_est()
#'
get_historical_national_estimates <- function() {

  f <- file.path(tempdir(), "fdp-beta-national-historical.csv")
  curl::curl_download(
    url = "https://www.agriculture.gov.au/sites/default/files/documents/fdp-beta-national-historical.csv",
    destfile = f,
    handle = create_handle())
  x <- data.table::fread(f)
  data.table::setcolorder(x,
                          neworder = c("Variable",
                                       "Year",
                                       "Industry",
                                       "Value",
                                       "RSE"))
  data.table::setkey(x, "Variable")
  return(x[])
}

#' @export
#' @rdname get_historical_national_estimates
get_hist_nat_est <- get_historical_national_estimates
