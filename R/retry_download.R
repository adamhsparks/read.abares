#' Download utilities for read.abares package
#'
#' Simplified httr2-based download functions with streaming, resume support,
#' and configurable timeouts using brio for file operations.

# Helper operators and utilities ----

#' Check internet connectivity.
#' @return Logical indicating if internet is available.
#' @dev
.has_internet <- function() {
  tryCatch(
    {
      curl::has_internet()
    },
    error = function(e) {
      FALSE
    }
  )
}

#' Parse URL information.
#' @param url Character string URL to parse.
#' @return List with parsed URL components.
#' @dev
.parse_url_info <- function(url) {
  if (is.null(url) || !is.character(url) || length(url) != 1L || !nzchar(url)) {
    return(list(
      valid = FALSE,
      hostname = "",
      path = "",
      filename = ""
    ))
  }

  tryCatch(
    {
      parsed <- httr2::url_parse(url)
      list(
        valid = TRUE,
        hostname = parsed$hostname %||% "",
        path = parsed$path %||% "",
        filename = if (!is.na(parsed$path)) basename(parsed$path) else ""
      )
    },
    error = function(e) {
      list(
        valid = FALSE,
        hostname = "",
        path = "",
        filename = ""
      )
    }
  )
}

#' Get timeout configuration.
#' @param dataset_id Optional dataset identifier for custom timeouts.
#' @return List of timeout values.
#' @dev
.get_timeouts <- function(dataset_id = NULL) {
  defaults <- list(
    connect = 15L,
    total = 7200L,
    low_speed_time = 0L,
    low_speed_limit = 0L
  )

  # Apply global option overrides
  defaults$connect <- getOption("read.abares.timeout_connect", defaults$connect)
  defaults$total <- getOption(
    "read.abares.timeout_total",
    getOption("read.abares.timeout", defaults$total)
  )
  defaults$low_speed_time <- getOption(
    "read.abares.low_speed_time",
    defaults$low_speed_time
  )
  defaults$low_speed_limit <- getOption(
    "read.abares.low_speed_limit",
    defaults$low_speed_limit
  )

  # Apply dataset-specific overrides if available
  dataset_timeouts <- getOption("read.abares.dataset_timeouts", list())
  if (!is.null(dataset_id) && !is.null(dataset_timeouts[[dataset_id]])) {
    defaults <- utils::modifyList(defaults, dataset_timeouts[[dataset_id]])
  }

  defaults
}

#' Determine if streaming should be used.
#' @param url Original URL.
#' @param probe Probe result from `.probe_url()`.
#' @return List with stream decision and reason.
#' @dev
.should_stream <- function(url, probe) {
  threshold_mb <- getOption("read.abares.stream_threshold_mb", 50L)

  url_info <- .parse_url_info(url)
  extension <- if (nzchar(url_info$filename)) {
    tolower(tools::file_ext(url_info$filename))
  } else {
    ""
  }

  # Handle missing or invalid extension
  if (is.na(extension)) {
    extension <- ""
  }

  # zip files always stream
  if (
    extension == "zip" ||
      grepl("zip", probe$content_type %||% "", ignore.case = TRUE)
  ) {
    return(list(stream = TRUE, reason = "zip file detected"))
  }

  # DAFF SirsiDynix endpoints
  if (
    grepl("daff\\.ent\\.sirsidynix\\.net\\.au", url_info$hostname) &&
      grepl("/asset/\\d+/\\d+$", url_info$path)
  ) {
    return(list(stream = TRUE, reason = "DAFF SirsiDynix asset endpoint"))
  }

  # Small file extensions
  small_extensions <- c(
    "xlsx",
    "xls",
    "csv",
    "pdf"
  )
  if (extension %in% small_extensions) {
    return(list(
      stream = FALSE,
      reason = paste("Small file extension:", extension)
    ))
  }

  # Use content length for decision
  if (!is.null(probe$content_length) && is.finite(probe$content_length)) {
    size_mb <- probe$content_length / 1048576L
    stream_decision <- size_mb >= threshold_mb
    reason <- sprintf(
      "File size %.1f MB %s threshold %.0f MB",
      size_mb,
      if (stream_decision) "exceeds" else "below",
      threshold_mb
    )
    return(list(stream = stream_decision, reason = reason))
  }

  # Default to no streaming
  list(stream = FALSE, reason = "No size information available")
}

#' Build httr2 request with standard headers.
#' @param url Request URL.
#' @return httr2_request object.
#' @dev
.build_request <- function(url) {
  user_agent <- getOption("read.abares.user_agent", "read.abares R package")

  httr2::request(url) |>
    httr2::req_user_agent(user_agent) |>
    httr2::req_headers(
      "Accept" = "application/octet-stream, */*",
      "Connection" = "keep-alive"
    )
}

#' Apply timeouts to httr2 request.
#' @param req httr2_request object.
#' @param timeouts List of timeout values from `.get_timeouts()`.
#' @return Modified httr2_request object.
#' @dev
.apply_timeouts <- function(req, timeouts) {
  req |>
    httr2::req_timeout(seconds = timeouts$total) |>
    httr2::req_options(
      connecttimeout = timeouts$connect,
      low_speed_time = timeouts$low_speed_time,
      low_speed_limit = timeouts$low_speed_limit
    )
}


#' Core download functionality
#'
#' Main download functions with probing, streaming, and resume capabilities.

#' Probe URL for headers and metadata.
#' @param url URL to probe.
#' @return List with response metadata.
#' @dev
.probe_url <- function(url) {
  req <- httr2::request(url) |>
    httr2::req_method("HEAD") |>
    httr2::req_timeout(seconds = 30L) |>
    httr2::req_error(is_error = function(resp) FALSE)

  tryCatch(
    {
      resp <- httr2::req_perform(req)
      status <- httr2::resp_status(resp)

      if (status >= 400L) {
        return(list(
          ok = FALSE,
          status = status,
          content_type = "",
          content_length = NA_real_,
          accept_ranges = ""
        ))
      }

      content_length <- httr2::resp_header(resp, "content-length")
      content_length <- if (!is.null(content_length)) {
        as.numeric(content_length)
      } else {
        NA_real_
      }

      list(
        ok = TRUE,
        status = status,
        content_type = httr2::resp_header(resp, "content-type") %||% "",
        content_length = content_length,
        accept_ranges = httr2::resp_header(resp, "accept-ranges") %||% ""
      )
    },
    error = function(e) {
      list(
        ok = FALSE,
        status = NA_integer_,
        content_type = "",
        content_length = NA_real_,
        accept_ranges = ""
      )
    }
  )
}

#' Try to resume a partial download using brio.
#' @param req httr2_request object.
#' @param dest Destination file path.
#' @param existing_size Size of existing partial file.
#' @return Logical indicating if resume was successful.
#' @dev
.try_resume <- function(req, dest, existing_size) {
  if (existing_size <= 0L) {
    return(FALSE)
  }

  resume_req <- req |>
    httr2::req_headers(Range = paste0("bytes=", existing_size, "-"))

  tryCatch(
    {
      resp <- httr2::req_perform_stream(resume_req, function(chunk) {
        brio::write_file_raw(chunk, dest, append = TRUE)
      })

      httr2::resp_status(resp) == 206L # Partial Content
    },
    error = function(e) {
      FALSE
    }
  )
}

#' Main download function with retry logic using brio.
#' @param url URL to download.
#' @param dest Destination file path.
#' @param dataset_id Optional dataset ID for timeout configuration.
#' @param force_stream Force streaming mode (optional).
#' @param show_progress Show progress bar.
#' @return `NULL` (downloads file to dest).
#' @dev
.retry_download <- function(
  url,
  dest,
  dataset_id = NULL,
  force_stream = NULL,
  show_progress = TRUE
) {
  if (!.has_internet()) {
    cli::cli_abort("No internet connection available")
  }

  # Probe the URL
  probe <- .probe_url(url)
  if (!probe$ok) {
    cli::cli_abort("Failed to access URL: HTTP {probe$status}")
  }

  # Decide on streaming
  stream_info <- if (!is.null(force_stream)) {
    list(stream = force_stream, reason = "forced by user")
  } else {
    .should_stream(url, probe)
  }

  if (show_progress) {
    cli::cli_inform(
      "Using {if(stream_info$stream) 'streaming' else 'buffered'} download:
        {stream_info$reason}"
    )
  }

  # Get timeouts and build request
  timeouts <- .get_timeouts(dataset_id)
  req <- .build_request(url) |>
    .apply_timeouts(timeouts) |>
    httr2::req_retry(max_tries = getOption("read.abares.max_tries", 3L))

  if (show_progress) {
    req <- httr2::req_progress(req)
  }

  # Ensure destination directory exists
  dest_dir <- dirname(dest)
  if (!dir.exists(dest_dir)) {
    dir.create(dest_dir, recursive = TRUE)
  }

  # Handle existing partial files
  existing_size <- if (file.exists(dest)) file.size(dest) else 0L

  tryCatch(
    {
      if (stream_info$stream) {
        # Try resume first if partial file exists
        if (existing_size > 0L && .try_resume(req, dest, existing_size)) {
          if (show_progress) {
            cli::cli_inform("Resumed download successfully")
          }
          return(invisible(NULL))
        }

        # Full streaming download - initialize empty file first
        brio::write_file_raw(raw(0), dest)

        resp <- httr2::req_perform_stream(req, function(chunk) {
          brio::write_file_raw(chunk, dest, append = TRUE)
        })
        httr2::resp_check_status(resp)
      } else {
        # Buffered download
        resp <- httr2::req_perform(req)
        httr2::resp_check_status(resp)
        brio::write_file_raw(httr2::resp_body_raw(resp), dest)
      }

      if (show_progress) {
        cli::cli_inform("Download completed: {basename(dest)}")
      }
    },
    error = function(e) {
      .safe_delete(dest)
      cli::cli_abort("Download failed: {conditionMessage(e)}")
    }
  )

  invisible(NULL)
}
