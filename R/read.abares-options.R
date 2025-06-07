#' Package Options for read.abares
#'
#' This page documents the global options used by the \pkg{read.abares} package.
#'
#' The following options can be set via [options()] to control package behavior:
#'
#' \describe{
#'   \item{`read.abares.user_agent`}{String. Set a custom user agent for web requests. Default is `"read.abares"`.}
#'   \item{`read.abares.timeout`}{Numeric. Timeout in seconds for operations. Default is `2000`.}
#'   \item{`read.abares.max_tries`}{Numeric. Number of time to retry download before giving up. Default is `3`.}
#' }
#'
#' These options can be set globally using:
#' ```r
#' options(myPackage.user_agent = "myCustomUserAgent")
#' ```
#'
#' @seealso [options()], [getOption()]
#' @name read.abares-options
#' @family read.abares-options
#' @keywords internal
NULL
