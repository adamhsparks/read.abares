#' Get or Set read.abares Options
#'
#' A convenience function to get or set options used by \pkg{read.abares}.
#'
#' @param ... Named options to set, or no arguments to retrieve current values.
#' @return A list of current option values.
#' @export
#' @family read.abares-options
#'
read.abares_options <- function(...) {
  dots <- list(...)
  if (length(dots) == 0L) {
    return(options()[grep("^read.abares\\.", names(options()))])
  }
  do.call(options, dots)
}
