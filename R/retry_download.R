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

  curl::handle_setheaders(h, "User-Agent" = getOption("read.abares.user_agent"))

  curl::handle_setopt(
    h,
    followlocation = TRUE,
    http_version = 0L, # auto
    accept_encoding = "", # allow gzip/br
    connecttimeout = 60L,
    timeout = getOption("read.abares.timeout", 7200L),
    low_speed_time = 0L,
    low_speed_limit = 0L,
    tcp_keepalive = 1L,
    tcp_keepidle = 60L,
    tcp_keepintvl = 60L,
    failonerror = TRUE
  )

  while (attempt <= retries && !success) {
    # Decide whether to resume
    ofs <- if (file.exists(.f)) file.size(.f) else 0L
    curl_mode <- if (!is.na(ofs) && ofs > 0L) "ab" else "wb"
    if (!is.na(ofs) && ofs > 0L) {
      curl::handle_setopt(h, resume_from_large = ofs)
    } else {
      curl::handle_setopt(h, resume_from_large = 0L)
    }

    res <- tryCatch(
      curl::curl_fetch_disk(url, path = .f, handle = h, curl_mode = curl_mode),
      error = function(e) {
        # Handle "416 Range Not Satisfiable": treat as success if file looks complete
        if (grepl("\\b416\\b", conditionMessage(e)) && file.exists(.f)) {
          sig <- readBin(.f, "raw", 4L)
          if (identical(as.integer(sig), c(0x50, 0x4B, 0x03, 0x04))) {
            return(structure(list(status_code = 206L), class = "curl_response"))
          }
        }
        if (!quiet) {
          cli::cli_warn("Attempt {attempt} failed: {conditionMessage(e)}")
        }
        NULL
      }
    )

    if (!is.null(res)) {
      # If we attempted resume but got 200 OK, the server ignored our Range.
      # Restart clean to avoid appending a full file after a partial (corruption).
      if (ofs > 0L && identical(res$status_code, 200L)) {
        if (!quiet) {
          cli::cli_inform("Server ignored resume (HTTP 200). Restarting clean…")
        }
        unlink(.f)
        curl::handle_setopt(h, resume_from_large = 0L)
        res <- curl::curl_fetch_disk(
          url,
          path = .f,
          handle = h,
          curl_mode = "wb"
        )
      }

      # Final ZIP sanity check
      sig <- readBin(.f, "raw", 4L)
      if (!identical(as.integer(sig), c(0x50, 0x4B, 0x03, 0x04))) {
        unlink(.f)
        res <- NULL
        if (!quiet) {
          cli::cli_warn("Downloaded content is not a ZIP; will retry.")
        }
      }
    }

    if (!is.null(res)) {
      success <- TRUE
      if (!quiet) cli::cli_inform("Download succeeded on attempt {attempt}.")
    } else {
      if (attempt < retries) {
        delay <- base_delay * 2L^(attempt - 1L)
        if (!quiet) {
          cli::cli_inform("Waiting {delay} seconds before retrying…")
        }
        Sys.sleep(delay)
      }
      attempt <- attempt + 1L
      if (attempt > retries) cli::cli_abort("All download attempts failed.")
    }
  }

  invisible(NULL)
}
