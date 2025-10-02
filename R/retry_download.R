#' read.abares download utilities (httr2-based, internal)
#'
#' Internal utilities to download files with `httr2`, dataset-driven timeouts,
#' auto streaming selection, resume for interrupted downloads, and safe cleanup
#' of partial files. Internet availability is checked with `curl::has_internet()`.
#' All functions here are internal; do not export.
#'
#' @section Options respected:
#' - `read.abares.verbosity`: character; if `"verbose"` a progress bar is shown.
#' - `read.abares.max_tries`: integer; maximum retry attempts (default `3`).
#' - `read.abares.dataset_timeouts`: named list mapping `dataset_id` to timeout
#'   lists with fields `connect`, `total`, `low_speed_time`, `low_speed_limit`.
#' - `read.abares.user_agent`: character; custom User-Agent string.
#' - Global timeout fallbacks:
#'   - `read.abares.timeout_connect` (default `15` seconds),
#'   - `read.abares.timeout_total` (default `7200` seconds),
#'   - `read.abares.timeout` (legacy alias for total),
#'   - `read.abares.low_speed_time` (default `0` seconds),
#'   - `read.abares.low_speed_limit` (default `0` bytes/sec).
#' - `read.abares.stream_threshold_mb`: numeric; auto-stream threshold (default 50).

#' Check internet connectivity using curl (internal)
#' @return Logical(1), `TRUE` if internet appears available.
#' @dev
.has_internet_curl <- function() {
  isTRUE(curl::has_internet())
}

#' Build a base httr2 request with polite defaults (internal)
#' @param req_url Character scalar; the request URL.
#' @return An `httr2_request` object.
#' @dev
.build_httr2_request <- function(req_url) {
  ua <- getOption("read.abares.user_agent")

  httr2::request(req_url) |>
    httr2::req_user_agent(ua) |>
    httr2::req_headers(
      "Accept" = "application/zip, application/octet-stream;q=0.9, */*;q=0.8",
      "Accept-Language" = "en-AU,en;q=0.9",
      "Connection" = "keep-alive"
    ) |>
    httr2::req_options(
      http_version = 2L,
      followlocation = TRUE,
      maxredirs = 10L,
      ssl_verifypeer = TRUE,
      ssl_verifyhost = 2L,
      accept_encoding = "", # allow gzip/deflate/br if offered
      tcp_keepalive = 1L,
      tcp_keepidle = 60L,
      tcp_keepintvl = 60L
    )
}

#' Resolve timeouts for a dataset from options (internal)
#' @param dataset_id Character scalar or `NULL`. When `NULL`, returns defaults.
#' @return A list: `connect`, `total`, `low_speed_time`, `low_speed_limit`.
#' @dev
.dataset_timeouts <- function(dataset_id = NULL) {
  defaults <- list(
    connect = getOption("read.abares.timeout_connect", 15L),
    total = getOption(
      "read.abares.timeout_total",
      getOption("read.abares.timeout", 7200L)
    ),
    low_speed_time = getOption("read.abares.low_speed_time", 0L),
    low_speed_limit = getOption("read.abares.low_speed_limit", 0L)
  )

  map <- getOption("read.abares.dataset_timeouts", NULL)
  if (!is.null(dataset_id) && is.list(map) && !is.null(map[[dataset_id]])) {
    return(utils::modifyList(defaults, map[[dataset_id]]))
  }
  defaults
}

#' Apply timeouts to an httr2 request (internal)
#' @param req An `httr2_request` object.
#' @param t_o A list like that returned by `.dataset_timeouts()`.
#' @return An `httr2_request` with timeouts applied.
#' @dev
.apply_timeouts <- function(req, t_o) {
  req |>
    httr2::req_timeout(seconds = t_o$total, connect = t_o$connect) |>
    httr2::req_options(
      low_speed_time = t_o$low_speed_time,
      low_speed_limit = t_o$low_speed_limit
    )
}

#' Probe a URL: prefer HEAD; fallback to 1-byte Range GET (internal)
#' Captures headers useful for resume: Content-Length, Content-Type,
#' Content-Disposition, ETag, Last-Modified, Accept-Ranges, and the final URL.
#'
#' @return list(ok, status, content_type, content_length, content_disp,
#'              etag, last_modified, accept_ranges, final_url)
#' @dev
.head_or_range_probe <- function(url) {
  connect_to <- 10L
  total_to <- 20L

  grab <- function(resp) {
    status <- httr2::resp_status(resp)
    list(
      ok = status < 400L,
      status = status,
      content_type = httr2::resp_header(resp, "content-type") %||% "",
      content_length = suppressWarnings(as.double(httr2::resp_header(
        resp,
        "content-length"
      ))),
      content_disp = httr2::resp_header(resp, "content-disposition") %||% "",
      etag = httr2::resp_header(resp, "etag") %||% "",
      last_modified = httr2::resp_header(resp, "last-modified") %||% "",
      accept_ranges = httr2::resp_header(resp, "accept-ranges") %||% "",
      final_url = httr2::resp_url(resp)
    )
  }

  # 1) HEAD
  req_head <- httr2::request(url) |>
    httr2::req_method("HEAD") |>
    httr2::req_options(followlocation = TRUE, maxredirs = 10L) |>
    httr2::req_timeout(seconds = total_to, connect = connect_to) |>
    httr2::req_error(is_error = function(resp) FALSE)

  resp_head <- try(httr2::req_perform(req_head), silent = TRUE)
  if (!inherits(resp_head, "try-error")) {
    out <- grab(resp_head)
    out$content_length <- if (is.finite(out$content_length)) {
      out$content_length
    } else {
      NA_real_
    }
    return(out)
  }

  # 2) Range GET fallback (bytes=0-0)
  req_get <- httr2::request(url) |>
    httr2::req_headers(Range = "bytes=0-0") |>
    httr2::req_options(followlocation = TRUE, maxredirs = 10L) |>
    httr2::req_timeout(seconds = total_to, connect = connect_to) |>
    httr2::req_error(is_error = function(resp) FALSE)

  resp_get <- try(httr2::req_perform(req_get), silent = TRUE)
  if (inherits(resp_get, "try-error")) {
    return(list(
      ok = FALSE,
      status = NA_integer_,
      content_type = "",
      content_length = NA_real_,
      content_disp = "",
      etag = "",
      last_modified = "",
      accept_ranges = "",
      final_url = url
    ))
  }

  out <- grab(resp_get)
  out$content_length <- if (is.finite(out$content_length)) {
    out$content_length
  } else {
    NA_real_
  }
  out
}

# ──────────────────────────────────────────────────────────────────────────────
# Streaming decision + timeout floors
# ──────────────────────────────────────────────────────────────────────────────

#' Extract filename from Content-Disposition (internal)
#' @dev
.extract_filename_from_cd <- function(content_disp) {
  if (!nzchar(content_disp)) {
    return(NA_character_)
  }
  m <- regmatches(
    content_disp,
    regexec('filename\\*?=("[^"]+"|[^;]+)', content_disp, ignore.case = TRUE)
  )
  if (length(m) && length(m[[1]]) >= 2) {
    val <- m[[1]][2]
    val <- gsub('^"|"$', "", trimws(val))
    if (grepl("^UTF-8''", val, ignore.case = TRUE)) {
      val <- utils::URLdecode(sub("^UTF-8''", "", val, ignore.case = TRUE))
    }
    return(val)
  }
  NA_character_
}

#' Decide streaming mode by size, extension & known patterns (internal)
#' @param url Original URL.
#' @param probe List from .head_or_range_probe().
#' @param threshold_mb numeric; default 50 MB.
#' @return list(stream = TRUE/FALSE, reason = character(1))
#' @dev
.choose_stream_mode <- function(
  url,
  probe,
  threshold_mb = getOption("read.abares.stream_threshold_mb", 50)
) {
  fin_url <- probe$final_url %||% url
  parsed <- tryCatch(httr2::url_parse(fin_url), error = function(e) {
    list(path = NA_character_, hostname = "")
  })
  path <- parsed$path
  host <- parsed$hostname %||% ""
  url_fn <- if (!is.na(path)) basename(path) else NA_character_
  cd_fn <- .extract_filename_from_cd(probe$content_disp)
  pick_fn <- if (nzchar(cd_fn)) cd_fn else url_fn
  ext <- tolower(tools::file_ext(pick_fn %||% ""))

  # NetCDF detection: by extension or content-type
  if (nzchar(ext) && ext == "nc") {
    return(list(stream = TRUE, reason = "NetCDF (.nc) file"))
  }
  if (grepl("netcdf", probe$content_type %||% "", ignore.case = TRUE)) {
    return(list(stream = TRUE, reason = "Content-Type indicates NetCDF"))
  }

  # DAFF SirsiDynix asset endpoints (very large NetCDFs): force streaming
  if (
    grepl("daff\\.ent\\.sirsidynix\\.net\\.au$", host) &&
      grepl("/asset/\\d+/(\\d+)$", path %||% "", perl = TRUE)
  ) {
    return(list(
      stream = TRUE,
      reason = "DAFF SirsiDynix 'asset' (large NetCDF)"
    ))
  }

  # Quick decisions by extension
  small_exts <- c("xlsx", "xls", "csv", "tsv", "txt", "json", "pdf", "docx")
  big_exts <- c("zip", "gz", "bz2", "7z", "rar", "gpkg", "tif", "tiff", "img")
  if (nzchar(ext) && ext %in% small_exts) {
    return(list(
      stream = FALSE,
      reason = sprintf("extension %s treated as small/text", ext)
    ))
  }
  if (nzchar(ext) && ext %in% big_exts) {
    if (is.finite(probe$content_length) && !is.na(probe$content_length)) {
      mb <- probe$content_length / (1024^2)
      return(list(
        stream = mb >= threshold_mb,
        reason = sprintf(
          "extension %s, size %.1f MB vs threshold %.0f MB",
          ext,
          mb,
          threshold_mb
        )
      ))
    }
    if (grepl("\\.s3[.-]ap-southeast-2\\.amazonaws\\.com$", host)) {
      return(list(stream = TRUE, reason = "S3 archive with unknown size"))
    }
  }

  # Known large CLUM/NLUM patterns
  path_lc <- tolower(paste0(path %||% "", " ", pick_fn %||% ""))
  if (
    grepl(
      "clum_50m|nlum_v7|alumv8|agprobabilitysurfaces|change_simp|inputs_20",
      path_lc,
      ignore.case = TRUE
    )
  ) {
    if (is.finite(probe$content_length) && !is.na(probe$content_length)) {
      mb <- probe$content_length / (1024^2)
      return(list(
        stream = mb >= threshold_mb,
        reason = sprintf("CLUM/NLUM pattern, size %.1f MB", mb)
      ))
    }
    return(list(stream = TRUE, reason = "CLUM/NLUM pattern with unknown size"))
  }

  # Fallback to size if available
  if (is.finite(probe$content_length) && !is.na(probe$content_length)) {
    mb <- probe$content_length / (1024^2)
    return(list(
      stream = mb >= threshold_mb,
      reason = sprintf(
        "size-only decision: %.1f MB vs threshold %.0f MB",
        mb,
        threshold_mb
      )
    ))
  }

  list(stream = FALSE, reason = "no size; defaulting to non-streaming")
}

#' Ensure a minimum total-timeout for large files (internal)
#' @param t_o timeouts list from `.dataset_timeouts()`
#' @param size_bytes numeric or NA
#' @return possibly adjusted list t_o
#' @dev
.ensure_timeout_floor <- function(t_o, size_bytes) {
  if (!is.finite(size_bytes) || is.na(size_bytes)) {
    return(t_o)
  }
  mb <- size_bytes / (1024^2)
  floor_hrs <-
    if (mb >= 1024) {
      12
    } else if (mb >= 200) {
      # >= 1 GB
      6
    } else {
      # >= 200 MB
      0
    }
  if (floor_hrs > 0) {
    t_o$total <- max(t_o$total, floor_hrs * 3600)
  }
  t_o
}

#' Bump timeouts by host/type context (internal)
#' @param t_o timeouts list from `.dataset_timeouts()`
#' @param url original URL
#' @param probe list from `.head_or_range_probe()`
#' @return possibly adjusted list t_o
#' @dev
.bump_timeouts_by_context <- function(t_o, url, probe) {
  fin_url <- probe$final_url %||% url
  parsed <- tryCatch(httr2::url_parse(fin_url), error = function(e) {
    list(path = NA_character_, hostname = "")
  })
  path <- parsed$path
  host <- parsed$hostname %||% ""
  url_fn <- if (!is.na(path)) basename(path) else NA_character_
  cd_fn <- .extract_filename_from_cd(probe$content_disp)
  pick_fn <- if (nzchar(cd_fn)) cd_fn else url_fn
  ext <- tolower(tools::file_ext(pick_fn %||% ""))

  is_sirsi_asset <- grepl("daff\\.ent\\.sirsidynix\\.net\\.au$", host) &&
    grepl("/asset/\\d+/(\\d+)$", path %||% "", perl = TRUE)
  is_netcdf <- (nzchar(ext) && ext == "nc") ||
    grepl("netcdf", probe$content_type %||% "", ignore.case = TRUE)

  if (is_sirsi_asset || is_netcdf) {
    t_o$total <- max(t_o$total, 12 * 3600) # ≥ 12 hours for >1 GB
    if (
      !is.numeric(t_o$low_speed_time) ||
        is.na(t_o$low_speed_time) ||
        t_o$low_speed_time <= 0
    ) {
      t_o$low_speed_time <- 300
    }
    if (
      !is.numeric(t_o$low_speed_limit) ||
        is.na(t_o$low_speed_limit) ||
        t_o$low_speed_limit <= 0
    ) {
      t_o$low_speed_limit <- 1000
    }
  }
  t_o
}

#' Try to resume a partial download if the server supports it (internal)
#'
#' @param req base `httr2` request (with retries + timeouts configured)
#' @param dest path to output file
#' @param probe header probe list (from `.head_or_range_probe`)
#' @param show_progress logical flag
#' @return `TRUE` if resume succeeded or file already complete; `FALSE` otherwise.
#' @dev
.try_resume_stream <- function(req, dest, probe, show_progress) {
  if (!fs::file_exists(dest)) {
    return(FALSE)
  }
  existed <- as.numeric(fs::file_size(dest))
  if (!is.finite(existed) || is.na(existed) || existed <= 0) {
    return(FALSE)
  }

  # Attempt resume even if Accept-Ranges isn't advertised; detect behavior.
  req2 <- req |>
    httr2::req_headers(Range = paste0("bytes=", existed, "-"))

  # If-Range with ETag or Last-Modified (only resume if same object)
  if (nzchar(probe$etag)) {
    req2 <- httr2::req_headers(req2, `If-Range` = probe$etag)
  } else if (nzchar(probe$last_modified)) {
    req2 <- httr2::req_headers(req2, `If-Range` = probe$last_modified)
  }

  # Append to the existing file
  con <- file(dest, open = "ab") # append binary
  on.exit(try(close(con), silent = TRUE), add = TRUE)

  resp <- httr2::req_perform_stream(
    req2,
    function(chunk) writeBin(chunk, con)
  )

  code <- httr2::resp_status(resp)

  if (code == 206) {
    if (show_progress) {
      cli::cli_inform(
        "Resumed and completed download for {.path {basename(dest)}}."
      )
    }
    return(TRUE)
  }

  if (code == 200) {
    # Server ignored Range; we must restart from scratch (signal FALSE)
    if (show_progress) {
      cli::cli_inform(
        "Server ignored Range; restarting full download for {.path {basename(dest)}}."
      )
    }
    return(FALSE)
  }

  if (code == 416) {
    # Range Not Satisfiable — maybe we already have the full file
    cl <- probe$content_length
    if (is.finite(cl) && !is.na(cl) && existed >= cl) {
      if (show_progress) {
        cli::cli_inform(
          "Local file size ≥ server content-length; assuming file is already complete."
        )
      }
      return(TRUE)
    }
    # else: fall back to fresh
    return(FALSE)
  }

  # Any other status: let the caller do a fresh download
  FALSE
}

#' Robust downloader for ABARES datasets (internal, auto streaming + resume)
#'
#' Downloads a remote resource to a local file using `httr2`, with:
#' - Retries via `httr2::req_retry()` and exponential backoff,
#' - Dataset-driven timeouts (see `.dataset_timeouts()`),
#' - Auto streaming decision by probe/heuristics; can be forced via `stream`,
#' - **Resume support** for partial files (Range + If-Range with ETag/Last-Modified),
#' - Atomic binary writes via `{brio}` when not streaming,
#' - A progress bar only when `options(read.abares.verbosity) == "verbose"`,
#' - Internet availability check via `curl::has_internet()`.
#'
#' This only downloads the file. To extract archives, call your own `.unzip_file()`.
#'
#' @param url Character scalar; download URL.
#' @param .f Character scalar; destination file path.
#' @param dataset_id Character scalar or `NULL`; used for timeouts lookup.
#' @param stream Logical(1) or `NULL`; if `NULL` we auto-decide; otherwise forced.
#' @param base_delay Numeric(1); base seconds for exponential backoff.
#'
#' @return Invisibly returns `NULL`. The file is written to `.f` on success.
#' @dev
.retry_download <- function(
  req_url,
  .f,
  dataset_id = NULL,
  stream = NULL,
  base_delay = 1L
) {
  if (!.has_internet_curl()) {
    cli::cli_abort("No internet connection available.")
  }

  # Progress bar only when "verbose" (legacy option supported)
  verbosity <- getOption(
    "read.abares.verbosity",
    getOption("read.abares.options")
  )
  show_progress <- isTRUE(identical(verbosity, "verbose"))

  # Probe for size/type/filename and decide streaming if not forced
  probe <- .head_or_range_probe(url)
  decision <- if (is.null(stream)) {
    .choose_stream_mode(url, probe)
  } else {
    list(stream = isTRUE(stream), reason = "forced")
  }
  use_stream <- isTRUE(decision$stream)
  if (show_progress) {
    cli::cli_inform(sprintf(
      "Auto-selected stream = %s (%s).",
      if (use_stream) "TRUE" else "FALSE",
      decision$reason
    ))
  }

  # Build request + progress
  req <- .build_httr2_request(req_url)
  if (show_progress) {
    req <- httr2::req_progress(req)
  }

  # Timeouts: dataset defaults → size floor → context floor (SirsiDynix/NetCDF)
  t_o <- .dataset_timeouts(dataset_id)
  t_o <- .ensure_timeout_floor(t_o, probe$content_length)
  t_o <- .bump_timeouts_by_context(t_o, url, probe)
  req <- .apply_timeouts(req, t_o)

  # Retries (exponential backoff)
  max_tries <- getOption("read.abares.max_tries", 3L)
  req <- req |>
    httr2::req_retry(
      max_tries = max_tries,
      backoff = function(attempt) base_delay * 2^(attempt - 1L),
      is_transient = function(result) {
        if (inherits(result, "httr2_response")) {
          code <- httr2::resp_status(result)
          code %in% c(408L, 425L, 429L) || (code >= 500L)
        } else {
          TRUE # transport-level/network errors
        }
      }
    )

  # Ensure destination directory exists
  fs::dir_create(fs::path_dir(.f), recurse = TRUE)

  # Perform + write with resume/fallback and cleanup on failure
  if (use_stream) {
    tryCatch(
      {
        # Try to resume if a partial file exists
        resumed <- .try_resume_stream(req, .f, probe, show_progress)
        if (!isTRUE(resumed)) {
          # Either no partial, or resume unsupported/failed → fresh full download (stream)
          con <- file(.f, open = "wb")
          on.exit(try(close(con), silent = TRUE), add = TRUE)
          resp <- httr2::req_perform_stream(req, function(chunk) {
            writeBin(chunk, con)
          })
          httr2::resp_check_status(resp)
          if (show_progress) {
            cli::cli_inform("Downloaded (stream) to {.path {basename(.f)}}.")
          }
        }
      },
      error = function(e) {
        try(.safe_delete(.f), silent = TRUE)
        cli::cli_abort("Download failed: {e$message}")
      }
    )
  } else {
    tryCatch(
      {
        # If a partial file exists in non-stream mode, switch to streaming resume
        if (fs::file_exists(.f) && as.numeric(fs::file_size(.f)) > 0) {
          if (show_progress) {
            cli::cli_inform(
              "Partial file detected; switching to streaming resume for {.path {basename(.f)}}."
            )
          }
          resumed <- .try_resume_stream(req, .f, probe, show_progress)
          if (!isTRUE(resumed)) {
            # fresh stream if resume not possible
            con <- file(.f, open = "wb")
            on.exit(try(close(con), silent = TRUE), add = TRUE)
            resp <- httr2::req_perform_stream(req, function(chunk) {
              writeBin(chunk, con)
            })
            httr2::resp_check_status(resp)
          }
        } else {
          # Normal non-stream path: buffer to memory, atomic write
          resp <- httr2::req_perform(req)
          httr2::resp_check_status(resp)
          brio::write_file(httr2::resp_body_raw(resp), .f)
        }
        if (show_progress) {
          cli::cli_inform("Downloaded to {.path {basename(.f)}}.")
        }
      },
      error = function(e) {
        try(.safe_delete(.f), silent = TRUE)
        cli::cli_abort("Download failed: {e$message}")
      }
    )
  }

  invisible(NULL)
}
