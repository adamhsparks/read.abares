#' Find the file path to your local R cache directory
#'
#' @returns A character string value of a file path indicating the proper
#'  directory to use for cached files.
#' @autoglobal
#' @dev
.find_user_cache <- function() {
  getOption(
    "read.abares.cache_location",
    default = tools::R_user_dir(package = "read.abares", which = "cache")
  )
}

#' Check for read.abares.something S3 class
#'
#' @param x An object for validating.
#' @param class An S3 class to validate against.
#'
#' @returns An invisible `NULL`, called for its side-effects of class
#'  validation.
#' @autoglobal
#' @dev
.check_class <- function(x, class) {
  if (missing(x) || !inherits(x, class)) {
    cli::cli_abort(
      "You must provide a {class} class object for this function.",
      call = rlang::caller_env()
    )
  }
  return(invisible(NULL))
}


#' Use httr2 to fetch a file with retries
#'
#' Retries to download the requested resource before stopping. Uses
#'  \CRANpkg{httr2} to cache in-session results in the `tempdir()`.
#'
#' @param url Character the URL being requested.
#' @param .f Character` a filepath to be written to local storage.
#' @param .max_tries Integer the number of times to retry downloading the file
#'  before failing.
#' @param .user_agent Character a string value with a custom user-defined
#'  user-agent.
#' @param .timout Integer maximum number of seconds to wait before timing out
#'  the request.
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
      http_version = 2L,
      timeout = getOption("read.abares.timeout")
    ) |>
    httr2::req_retry(
      max_tries = getOption("read.abares.max_tries")
    ) |>
    httr2::req_cache(path = tempdir())
  if (getOption("read.abares.verbosity") == 3L) {
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
