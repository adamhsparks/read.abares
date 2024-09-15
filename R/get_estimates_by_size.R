
#' Get Estimates by Size From ABARES
#'
#'
#' @examplesIf interactive()
#' get_est_by_size()
#'
#' @return a [data.table::data.table] object
#' @export
#' @aliases get_est_by_size
#' @examples
#'
get_estimates_by_size <- function() {
  x <- data.table::fread("https://www.agriculture.gov.au/sites/default/files/documents/fdp-beta-performance-by-size.csv")
  return(x)
}
