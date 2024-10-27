
#' Get Estimates by Size From ABARES
#'
#' @note
#' Columns are renamed and reordered for consistency.
#'
#' @return A [data.table::data.table] object with the `Variable` field as the
#'  `key`.
#' @source <https://www.agriculture.gov.au/abares/data/farm-data-portal#data-download>
#' @autoglobal
#' @family Estimates
#' @export
#' @examplesIf interactive()
#'
#' get_estimates_by_size()
#'
#' # or shorter
#' get_est_by_size()
#'
get_estimates_by_size <- get_est_by_size <- function() {
  x <- data.table::fread(
    "https://www.agriculture.gov.au/sites/default/files/documents/fdp-beta-performance-by-size.csv"
  )

  data.table::setcolorder(x,
                          neworder = c("Variable",
                                       "Year",
                                       "Size",
                                       "Industry",
                                       "Value",
                                       "RSE"))
  data.table::setkey(x, "Variable")

  return(x)
}

#' @export
#' @rdname get_estimates_by_size
get_est_by_size <- get_estimates_by_size
