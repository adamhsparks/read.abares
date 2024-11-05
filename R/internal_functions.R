
#' Find the File Path to Users' Cache Directory
#'
#' @return A `character` string value of a file path indicating the proper
#'  directory to use for cached files
#' @noRd
#' @keywords Internal
#' @autoglobal
.find_user_cache <- function() {
  tools::R_user_dir(package = "read.abares", which = "cache")
}

#' Check for read.abares.something S3 Class
#'
#' @param x An object for validating
#' @param class An S3 class to validate against
#'
#' @return Nothing, called for its side-effects of class validation
#' @keywords Internal
#' @autoglobal
#' @noRd

.check_class <- function(x, class) {
  if (missing(x) || !inherits(x, class)) {
    cli::cli_abort("You must provide a {.code read.abares} class object.")
  }
}

#' Use httr2 to Fetch a File With Retries
#'
#' Retries to download the requested resource five times before stopping.  Then
#'   saves the resource in the `tempdir()` for importing.
#'
#' @param url `Character` The URL being requested
#' @param .f `Character` A filepath to be written to local storage
#' @param .max_tries `Integer` The number of times to retry a failed download
#'   before emitting an error message
#' @param .initial_delay `Integer` The number of seconds to delay before
#'   retrying the download.  This increases as the tries increment.
#'
#' @examples
#'
#' f <- file.path(tempdir(), "fdp-beta-national-historical.csv")
#' retry_download(url = "https://www.agriculture.gov.au/sites/default/files/documents/fdp-beta-national-historical.csv",
#' .f = f)
#'
#' @return Called for its side-effects, writes an object to the `tempdir()` for
#'   reading into the active \R session later.
#' @keywords Internal
#' @noRd

.retry_download <- function(url,
                            .f,
                            .max_tries = 5L,
                            .initial_delay = 30L) {
  attempt <- 1
  success <- FALSE

  while (attempt <= .max_tries && !success) {
    tryCatch({
      response <- httr2::request(base_url = url) |>
        httr2::req_options(http_version = 2, timeout = 500L) |>
        httr2::req_retry(max_tries = .max_tries) |>
        httr2::req_perform()

      writeBin(response$body, con = .f)
      success <- TRUE
    }, error = function(e) {
      if (attempt < .max_tries) {
        delay <- .initial_delay * 2 ^ (attempt - 1)
        cli::cli_alert(
          "Download failed on attempt {.code attempt}.
                Retrying in {.code delay} seconds..."
        )
        Sys.sleep(delay)
        attempt <- attempt + 1
      } else {
        cli::cli_alert_danger(
          "Download failed after {.code max_attempts} attempts.")
        stop(e)
      }
    })
  }
}
