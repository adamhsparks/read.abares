#' Get or Set read.abares Options
#'
#' A convenience function to get or set options used by \pkg{read.abares}.
#'
#' @param ... Named options to set, or no arguments to retrieve current values.
#' @returns A list of current option values.
#'
#' @examples
#' # See currently set options for {read.abares}
#' read.abares_options()
#'
#' # Set caching to `TRUE`
#' read.abares_options(read.abares.cache = TRUE)
#' read.abares_options()
#'
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
