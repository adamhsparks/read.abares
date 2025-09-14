#' Use httr2 to Fetch a File with Retries
#'
#' Retries to download the requested resource before stopping. Uses
#'  \CRANpkg{httr2} to cache in-session results in the `tempdir()`.
#'
#' @param url Character the URL being requested.
#' @param .f Character a filepath to be written to local storage.
#'
#' @examples
#'
#' f <- fs::path(tempdir(), "fdp-beta-national-historical.csv")
#' .retry_download(
#'   url = "https://www.agriculture.gov.au/sites/default/files/documents/fdp-beta-national-historical.csv",
#'   .f = f
#' )
#'
#' @returns An invisible `NULL`, called for its side-effects, writes an object
#'  to the `tempdir()` for reading into the active \R session later.
#' @dev

.retry_download <- function(url, .f) {
  .download_file(
    url = url,
    destfile = .f,
    quiet = !(getOption("read.abares.verbosity") %in%
      c("quiet", "minimal", "warn"))
  )
  return(invisible(NULL))
}

#' Wrap curl::curl_download mainly for ease of testing
#'
#' @param url Character the URL being requested.
#' @param destfile Character a filepath to be written to local storage.
#' @param quiet How verbose should the download be? Defaults to `TRUE`.
#'
#' @returns Invisibly returns `NULL`, called for its side-effects, writes an
#'  object to disk.
#'
#' @dev
.download_file <- function(url, destfile, quiet) {
  curl::curl_download(url = url, destfile = destfile, quiet = quiet)
}
