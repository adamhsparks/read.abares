#' Package Options for read.abares
#'
#' This page documents the global options used by the \pkg{read.abares} package.
#'
#' The following options can be set via [options()] to control package behavior:
#'
#' \describe{
#'   \item{`read.abares.user_agent`}{Character string to set a custom user agent
#'    for web requests. Default is
#'    `read.abares R package {version no.} https://github.com/ropensci/read.abares`.}
#'   \item{`read.abares.timeout`}{Integer providing the timeout in seconds for
#'    download operations. Default is `2000`.}
#'   \item{`read.abares.timeout_connect`}{Integer providing the connection
#'    timeout in seconds. Default is `20`.}
#'   \item{`read.abares.max_tries`}{Integer providing the number of times to
#'    retry download before giving up. Default is `3`.}
#'   \item{`read.abares.verbosity`}{Set the desired level of verbosity.
#'    * "quiet" - no messages at all but errors will be reported,
#'    * "minimal" - warnings and errors only reported,
#'    * "verbose" - full messages including downloading, importing files, etc.
#'      reported.}
#' }
#'
#' These options can be set globally using:
#' ```r
#' options(read.abares.user_agent = "myCustomUserAgent") or
#' read.abares_options(read.abares.user_agent = "myCustomUserAgent")
#  ```
#'
#' @seealso [options()], [getOption()].
#' @name read.abares-options
#' @family read.abares-options
#' @keywords internal
NULL
