#' Find the fs::path to the users' cache directory
#'
#' @returns A `character` string value of a fs::path indicating the proper
#'  directory to use for cached files.
#' @dev
#' @autoglobal
.find_user_cache <- function() {
  tools::R_user_dir(package = "read.abares", which = "cache")
}

#' Check for read.abares.something S3 class
#'
#' @param x An object for validating.
#' @param class An S3 class to validate against.
#'
#' @returns Nothing, called for its side-effects of class validation.
#' @autoglobal
#' @dev
.check_class <- function(x, class) {
  if (missing(x) || !inherits(x, class)) {
    cli::cli_abort(
      "You must provide a {.code read.abares} class object.",
      call = rlang::caller_env()
    )
  }
}

#' Use httr2 to fetch a file with retries
#'
#' Retries to download the requested resource before stopping. Uses
#'  \CRANpkg{httr2} to cache in-session results in the `tempdir()`.
#'
#' @param url `Character` The URL being requested.
#' @param .f `Character` A filepath to be written to local storage.
#' @param .max_tries `Integer` The number of times to retry a failed download
#'   before emitting an error message.
#' @param .initial_delay `Integer` The number of seconds to delay before
#'   retrying the download.  This increases as the tries increment.
#'
#' @examples
#'
#' f <- fs::path(tempdir(), "fdp-beta-national-historical.csv")
#' retry_download(
#'   url = "https://www.agriculture.gov.au/sites/default/files/documents/fdp-beta-national-historical.csv",
#'   .f = f
#' )
#'
#' @returns Called for its side-effects, writes an object to the `tempdir()` for
#'   reading into the active \R session later.
#' @dev

.retry_download <- function(url, .f, .max_tries = 3L) {
  httr2::request(base_url = url) |>
    httr2::req_user_agent("read.abares") |>
    httr2::req_headers("Accept-Encoding" = "identity") |>
    httr2::req_headers("Connection" = "Keep-Alive") |>
    httr2::req_options(http_version = 2, timeout = 2000L) |>
    httr2::req_retry(max_tries = .max_tries) |>
    httr2::req_cache(path = tempdir()) |>
    httr2::req_progress() |>
    httr2::req_perform() |>
    httr2::resp_body_raw() |>
    brio::write_file_raw(path = .f)
}
