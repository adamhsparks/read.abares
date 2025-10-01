#' Use curl to Fetch a File with Retries
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

    while (attempt <= retries && !success) {
      tryCatch(
        {
          curl::curl_download(
            url = url,
            destfile = .f,
            quiet = quiet,
            handle = set_curl_handle()
          )
          success <- TRUE
          if (isFALSE(quiet)) {
            cli::cli_inform(
              "Download succeeded on attempt {attempt}."
            )
          }
        },
        error = function(e) {
          cli::cli_inform("Attempt {attempt} failed: {e$message}.")
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

#' Create a curl Handle for read.abares to use
#'
#' @returns A [curl::handle] object with polite headers and options set.
#' @dev
set_curl_handle <- function() {
  h <- curl::new_handle()
  curl::handle_setheaders(
    h,
    "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0 Safari/537.36",
    "Accept" = "application/zip, application/octet-stream;q=0.9, */*;q=0.8",
    "Accept-Language" = "en-AU,en;q=0.9",
    "Connection" = "keep-alive"
  )

  curl::handle_setopt(
    h,
    followlocation = TRUE,
    maxredirs = 10L,
    http_version = 2L,
    ssl_verifypeer = TRUE,
    ssl_verifyhost = 2L,
    connecttimeout_ms = 15000L,
    low_speed_time = 0L,
    low_speed_limit = 0L,
    tcp_keepalive = 1L,
    tcp_keepidle = 60L,
    tcp_keepintvl = 60L,
    failonerror = TRUE,
    timeout = getOption("read.abares.timeout", 7200L),
    accept_encoding = "" # allow gzip/deflate/br for headers
  )
  return(h)
}
