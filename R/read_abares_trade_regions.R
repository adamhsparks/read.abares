#' Read ABARES 'Trade Data Regions' from the ABARES Trade Dashboard
#'
#' Fetches and imports  \acronym{ABARES} trade regions data.
#'
#' @note
#' Columns are renamed for consistency with other \acronym{ABARES} products
#'  serviced in this package using a snake_case format and ordered consistently.
#'
#' @param cache `Boolean` Cache the \acronym{ABARES} trade regions data after
#'  download using `tools::R_user_dir()` to identify the proper directory for
#'  storing user data in a cache for this package. Defaults to `TRUE`, caching
#'  the files locally as a native \R object. If `FALSE`, this function uses
#'  `tempdir()` and the files are deleted upon closing of the active \R session.
#'
#' @examplesIf interactive()
#' trade_regions <- read_abares_trade_regions()
#'
#' trade_regions
#'
#' @return A \CRANpkg{data.table} object of the \acronym{ABARES} trade data
#'  regions.
#' @family Trade
#' @references <https://daff.ent.sirsidynix.net.au/client/en_AU/search/asset/1033841/0>
#' @source <https://daff.ent.sirsidynix.net.au/client/en_AU/search/asset/1033841/2>
#' @autoglobal
#' @export

read_abares_trade_regions <- function(cache = TRUE) {
  abares_trade_gz <- file.path(
    .find_user_cache(),
    "abares_trade_dir/abares_trade_regions.gz"
  )

  if (file.exists(abares_trade_gz)) {
    return(data.table::fread(abares_trade_gz))
  } else {
    return(.download_abares_trade_regions(cache))
  }
}

#' Download the ABARES Trade CSV file
#'
#' Handles downloading and caching (if requested) of ABARES Trade data files.
#'
#' @param cache `Boolean` Cache the \acronym{ABARES} trade CSV file after
#'  download using `tools::R_user_dir()` to identify the proper directory for
#'  storing user data in a cache for this package. Defaults to `TRUE`, caching
#'  the files locally as a native \R object. If `FALSE`, this function uses
#'  `tempdir()` and the files are deleted upon closing of the active \R session.
#'
#' @return A \CRANpkg{data.table} object of the \acronym{ABARES} trade data.
#' @noRd
#' @autoglobal
#' @keywords Internal
.download_abares_trade_regions <- function(cache) {
  abares_trade_regions_dir <- file.path(
    .find_user_cache(),
    "abares_trade_regions_dir/"
  )
  if (cache && !dir.exists(abares_trade_regions_dir)) {
    dir.create(abares_trade_regions_dir, recursive = TRUE)
  }
  trade_zip <- file.path(tempdir(), "abares_trade_regions_data.zip")

  .retry_download(
    url = "https://daff.ent.sirsidynix.net.au/client/en_AU/search/asset/1033841/1",
    .f = trade_zip
  )

  abares_trade_regions <- data.table::fread(file.path(trade_zip),
    na.strings = c(""),
    fill = TRUE
  )

  if (cache) {
    data.table::fwrite(abares_trade_regions,
      file = file.path(abares_trade_regions_dir, "abares_trade_regions.gz")
    )
  }

  return(abares_trade_regions[])
}
