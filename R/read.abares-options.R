#' Package Options for read.abares
#'
#' This page documents the global options used by the \pkg{read.abares} package.
#'
#' The following options can be set via [options()] to control package behavior:
#'
#' \describe{
#'   \item{`read.abares.cache`}{Boolean. Globally enable or disable caching for select data sets serviced by \pkg{read.abares}. Defaults to `FALSE` not caching data locally between \R sessions.}
#'   \item{`read.abares.cache_location`}{String. Set a custom location for caching data sets serviced by \pkg{read.abares}. Defaults to `tools::R_user_dir(package = "read.abares", which = "cache")`.}
#'   \item{`read.abares.user_agent`}{String. Set a custom user agent for web requests. Default is `"read.abares"`.}
#'   \item{`read.abares.timeout`}{Numeric. Timeout in seconds for operations. Default is `2000`.}
#'   \item{`read.abares.max_tries`}{Numeric. Number of time to retry download before giving up. Default is `3`.}
#' }
#'
#' These options can be set globally using:
#' ```r
#' options(read.abares.user_agent = "myCustomUserAgent")
#' ```
#'
#' @seealso [options()], [getOption()].
#' @name read.abares-options
#' @family read.abares-options
#' @keywords internal
NULL
