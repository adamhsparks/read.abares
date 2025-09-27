#' Use httr2 to Fetch a File with Retries
#'
#' Retries to download the requested resource before stopping.
#'
#' @param url Character the URL being requested.
#' @param .f Character a filepath to be written to local storage.
#' @param base_delay Integer the starting value in seconds for exponential
#'  backoff when retrying failed downloads.
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

.retry_download <- function(url, .f, base_delay = 1L) {
  if (curl::has_internet()) {
    attempt <- 1L
    success <- FALSE
    quiet <- (getOption("read.abares.verbosity") %notin%
      c("quiet", "minimal", "warn"))
    retries <- getOption("read.abares.max_tries", 3L)
    h <- curl::new_handle()
    curl::handle_setopt(
      h,
      .list = list(
        followlocation = TRUE,
        timeout = getOption("read.abares.timeout", 2000L),
        useragent = getOption("read.abares.user_agent")
      )
    )

    while (attempt <= retries && !success) {
      tryCatch(
        {
          curl::curl_download(
            url = url,
            destfile = .f,
            quiet = quiet,
            handle = h
          )
          success <- TRUE
          if (isFALSE(quiet)) {
            cli::cli_inform(
              "Download succeeded on attempt {attempt}."
            )
          }
        },
        error = function(e) {
          cli::cli_inform("Attempt {attempt} failed: {e$message}")
          if (attempt < retries) {
            delay <- base_delay * 2L^(attempt - 1L)
            cli::cli_inform("Waiting {delay} seconds before retrying...")
            Sys.sleep(delay)
          }
          attempt <<- attempt + 1L
          if (attempt > retries) {
            cli::cli_abort("All download attempts failed.")
          }
        }
      )
    }
  } else {
    cli::cli_abort("No internet connection available.")
  }

  return(invisible(NULL))
}
