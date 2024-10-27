#' Get ABARES Trade Data Regions From the ABARES Trade Dashboard
#'
#' Fetches and imports  \acronym{ABARES} trade regions data. Columns are renamed
#'  for consistency in this package using lower case, snake_case format.
#'
#' @param cache `Boolean` Cache the \acronym{ABARES} trade regions data after
#'  download using `tools::R_user_dir()` to identify the proper directory for
#'  storing user data in a cache for this package. Defaults to `TRUE`, caching
#'  the files locally as a native \R object. If `FALSE`, this function uses
#'  `tempdir()` and the files are deleted upon closing of the \R session.
#'
#' @examplesIf interactive()
#' trade_regions <- get_abares_trade_regions()
#'
#' @return A \CRANpkg{data.table} object of the \acronym{ABARES} trade data
#' @family Trade
#' @references <https://daff.ent.sirsidynix.net.au/client/en_AU/search/asset/1033841/0>
#'
#' @export

get_abares_trade_regions <- function(cache = TRUE) {
  trade_regions <- .check_existing_trade_regions(cache)
  if (is.null(trade_regions)) {
    trade_regions <- .download_abares_trade_regions(cache)
  } else {
    return(trade_regions)
  }
}

#' Check for Pre-existing File Before Downloading
#'
#' Checks the user cache first, then `tempdir()` for the files before
#' returning a `NULL` value. If `cache == TRUE` and the file is not in the user
#' cache, but is in `tempdir()`, it is saved to the cache before being returned
#' in the current session.
#'
#'
#' @return A \CRANpkg{data.table} object of the \acronym{ABARES} trade data
#' @noRd
#' @keywords Internal

.check_existing_trade_regions <- function(cache) {
  abares_trade_rds <- file.path(.find_user_cache(),
                                "abares_trade/abares_trade_regions.rds")
  tmp_csv <- file.path(tempdir(), "abares_trade_regions.csv")

  if (file.exists(abares_trade_rds)) {
    return(readRDS(abares_trade_rds))
  } else if (file.exists(tmp_csv)) {
    abares_trade <- data.table::fread(tmp_csv,
                                      na.strings = c(""),
                                      fill = TRUE)
    if (cache) {
      dir.create(dirname(abares_trade_rds), recursive = TRUE)
      saveRDS(abares_trade, file = abares_trade_rds)
    }
    return(abares_trade)
  } else {
    return(NULL)
  }
}

#' Download the ABARES Trade CSV File
#'
#' Handles downloading and caching (if requested) of ABARES Trade data files.
#'
#' @param cache `Boolean` Cache the \acronym{ABARES} trade CSV file after
#'  download using `tools::R_user_dir()` to identify the proper directory for
#'  storing user data in a cache for this package. Defaults to `TRUE`, caching
#'  the files locally as a native \R object. If `FALSE`, this function uses
#'  `tempdir()` and the files are deleted upon closing of the \R session.
#'
#' @return A \CRANpkg{data.table} object of the \acronym{ABARES} trade data
#' @noRd
#' @keywords Internal
.download_abares_trade_regions <- function(cache) {
  # if you make it this far, the cached file doesn't exist, so we need to
  # download it either to `tempdir()` and dispose or cache it
  cached_csv <- file.path(.find_user_cache(),
                          "abares_trade_dir/abares_trade_regions.csv")
  tmp_csv <- file.path(file.path(tempdir(), "abares_trade_regions.csv"))
  abares_trade_regions_csv <- data.table::fifelse(cache, cached_csv, tmp_csv)
  abares_trade_dir <- dirname(abares_trade_regions_csv)
  abares_trade_regions_rds <- file.path(abares_trade_dir,
                                        "abares_trade_regions.rds")

  # the user-cache may not exist if caching is enabled for the 1st time
  if (cache && !dir.exists(abares_trade_dir)) {
    dir.create(abares_trade_dir, recursive = TRUE)
  }

  url <-
    "https://daff.ent.sirsidynix.net.au/client/en_AU/search/asset/1033841/2"

  h <- curl::new_handle()
  curl::handle_setopt(
    handle = h,
    TCP_KEEPALIVE = 200000,
    CONNECTTIMEOUT = 90,
    http_version = 2
  )
  curl::curl_download(
    url = url,
    destfile = abares_trade_regions_csv,
    quiet = FALSE,
    handle = h
  )

  abares_trade_regions <- data.table::fread(file.path(abares_trade_dir,
                                          "abares_trade_regions.csv"),
                                          na.strings = c(""),
                                          fill = TRUE)

  if (cache) {
    saveRDS(abares_trade_regions, file = abares_trade_regions_rds)
    unlink(c(
      file.path(abares_trade_dir, "abares_trade_regions.csv")
    ))
  }
  return(abares_trade_regions)
}
