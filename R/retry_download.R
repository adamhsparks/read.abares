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

# Robust curl download with retries (handles slow servers *and* bad URLs)
.retry_download <- function(url, .f, base_delay = 1L) {
  if (!curl::has_internet()) {
    cli::cli_abort("No internet connection available.")
  }

  dir.create(dirname(.f), recursive = TRUE, showWarnings = FALSE)

  attempt <- 1L
  success <- FALSE
  retries <- getOption("read.abares.max_tries", 5L)
  verbosity <- getOption("read.abares.verbosity", "warn")
  quiet <- isTRUE(verbosity %in% c("quiet", "minimal", "warn"))

  h <- curl::new_handle()

  curl::handle_setheaders(
    h,
    "User-Agent" = getOption("read.abares.user_agent")
  )

  curl::handle_setopt(
    h,
    followlocation = TRUE,
    http_version = 0L, # let libcurl choose (avoid HTTP/2-only issues)
    accept_encoding = "", # enable gzip/br/deflate
    connecttimeout = 60L,
    timeout = getOption("read.abares.timeout", 7200L),
    low_speed_time = 0L, # you've chosen to disable the low-speed watchdog
    low_speed_limit = 0L,
    tcp_keepalive = 1L,
    tcp_keepidle = 60L,
    tcp_keepintvl = 60L,
    failonerror = TRUE # <-- fail fast on 4xx/5xx instead of writing HTML
  )

  while (attempt <= retries && !success) {
    tryCatch(
      {
        curl::curl_download(
          url = url,
          destfile = .f,
          quiet = quiet,
          handle = h,
          resume = TRUE,
          mode = "wb"
        )

        # Sanity check: first 4 bytes of a ZIP should be PK\003\004
        sig <- readBin(.f, what = "raw", n = 4L)
        if (!identical(as.integer(sig), c(0x50, 0x4B, 0x03, 0x04))) {
          unlink(.f)
          cli::cli_abort(
            "Server did not return a ZIP (likely an HTML error page)."
          )
        }

        success <- TRUE
        if (!quiet) cli::cli_inform("Download succeeded on attempt {attempt}.")
      },
      error = function(e) {
        if (!quiet) {
          cli::cli_warn("Attempt {attempt} failed: {conditionMessage(e)}")
        }
        if (attempt < retries) {
          delay <- base_delay * 2L^(attempt - 1L)
          if (!quiet) {
            cli::cli_inform("Waiting {delay} seconds before retrying...")
          }
          Sys.sleep(delay)
        }
        attempt <<- attempt + 1L
        if (attempt > retries) {
          cli::cli_abort("All download attempts failed: {conditionMessage(e)}")
        }
      }
    )
  }

  invisible(NULL)
}
