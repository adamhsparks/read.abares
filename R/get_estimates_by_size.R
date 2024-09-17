
#' Get Estimates by Size From ABARES
#'
#' @return A [data.table::data.table] object
#' @autoglobal
#' @export
#' @examplesIf interactive()
#'
#' get_estimates_by_size()
#'
#' # or shorter
#' get_est_by_size()
#'
get_estimates_by_size <- get_est_by_size <- function() {
  x <- data.table::fread("https://www.agriculture.gov.au/sites/default/files/documents/fdp-beta-performance-by-size.csv")
  return(x)
}

#' @export
#' @rdname get_estimates_by_size
get_est_by_size <- get_estimates_by_size
