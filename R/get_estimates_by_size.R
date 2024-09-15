
#' Get Estimates by Size From ABARES
#'
#'
#' @examplesIf interactive()
#' get_est_by_size()
#'
#' @return A [data.table::data.table] object
#' @export
#' @examplesIf interactive()
#' get_est_by_size()
#'
get_estimates_by_size <- get_est_by_size <- function() {
  x <- data.table::fread("https://www.agriculture.gov.au/sites/default/files/documents/fdp-beta-performance-by-size.csv")
  return(x)
}
