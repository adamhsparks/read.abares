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

.retry_download <- function(
  url,
  .f
) {
  base_req <- httr2::request(base_url = url) |>
    httr2::req_user_agent(getOption("read.abares.user_agent")) |>
    httr2::req_headers("Accept-Encoding" = "identity") |>
    httr2::req_headers("Connection" = "Keep-Alive") |>
    httr2::req_options(
      http_version = 1L,
      timeout = getOption("read.abares.timeout")
    ) |>
    httr2::req_retry(
      max_tries = getOption("read.abares.max_tries")
    ) |>
    httr2::req_cache(path = tempdir())
  if (getOption("read.abares.verbosity") == "verbose") {
    base_req |>
      httr2::req_progress() |>
      httr2::req_perform() |>
      httr2::resp_body_raw() |>
      brio::write_file_raw(path = .f)
  } else {
    base_req |>
      httr2::req_perform() |>
      httr2::resp_body_raw() |>
      brio::write_file_raw(path = .f)
  }
  return(invisible(NULL))
}
