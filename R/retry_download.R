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
#' .retry_download(
#'   url = "https://www.agriculture.gov.au/sites/default/files/documents/fdp-beta-national-historical.csv",
#'   dest = f
#' )
#'
#' @returns Called for its side-effects, writes an object to the specified
#'   director for reading into the active \R session later.
#' @dev

.retry_download <- function(url, dest, .max_tries = 3L) {
  req <- httr2::request(base_url = url) |>
    httr2::req_user_agent("read.abares") |>
    httr2::req_headers("Accept-Encoding" = "identity") |>
    httr2::req_headers("Connection" = "Keep-Alive") |>
    httr2::req_options(http_version = 2, timeout = 2000L) |>
    httr2::req_retry(max_tries = .max_tries) |>
    httr2::req_cache(path = tempdir())
  if (getOption("read.abares.verbosity") == "verbose") {
    req <- httr2::req_progress() |>
      httr2::req_perform() |>
      httr2::resp_body_raw() |>
      brio::write_file_raw(path = dest)
  } else {
    req |>
      httr2::req_perform() |>
      httr2::resp_body_raw() |>
      brio::write_file_raw(path = dest)
  }
}
