#' Read data from the ABARES Trade Dashboard
#'
#' Fetches and imports \acronym{ABARES} trade data. As the data file is large,
#' ~1.4GB uncompressed CSV file, caching is offered to save repeated
#' downloading.
#'
#' @note
#' Columns are renamed for consistency with other \acronym{ABARES} products
#'  serviced in this package using a snake_case format and ordered
#'  consistently.
#'
#' @param cache `Boolean` Cache the \acronym{ABARES} trade data locally after
#'  download to save download time in the future. Uses `tools::R_user_dir()` to
#'  identify the proper directory for storing user data in a cache for this
#'  package. Defaults to `TRUE`, caching the file as a gzipped CSV file. If
#'  `FALSE`, this function uses `tempdir()` and the files are deleted upon
#'  closing of the active \R session.
#'
#' @note The cached file is not the same as the raw file that is available for
#'  download. It will follow the renaming scheme and filling values that this
#'  function will perform on the raw data.
#'
#' @examplesIf interactive()
#' trade <- read_abares_trade()
#'
#' trade
#'
#' @returns A \CRANpkg{data.table} object of the \acronym{ABARES} trade data.
#' @family Trade
#' @references <https://www.agriculture.gov.au/abares/research-topics/trade/dashboard>
#' @source <https://daff.ent.sirsidynix.net.au/client/en_AU/search/asset/1033841/0>
#' @autoglobal
#' @export

read_abares_trade <- function(cache = TRUE) {
  abares_trade_gz <- file.path(
    .find_user_cache(),
    "abares_trade_dir/abares_trade.gz"
  )

  if (file.exists(abares_trade_gz)) {
    return(data.table::fread(abares_trade_gz))
  } else {
    return(.download_abares_trade(cache))
  }
}

#' Download the ABARES trade CSV file
#'
#' Handles downloading and caching (if requested) of ABARES Trade data files.
#'
#' @param cache `Boolean` Cache the \acronym{ABARES} trade CSV file after
#'  download using `tools::R_user_dir()` to identify the proper directory for
#'  storing user data in a cache for this package. Defaults to `TRUE`, caching
#'  the files locally as a gzip file. If `FALSE`, this function uses
#'  `tempdir()` and the files are deleted upon closing of the active \R session.
#'
#' @returns A \CRANpkg{data.table} object of the \acronym{ABARES} trade data.
#' @noRd
#' @autoglobal
#' @keywords Internal
.download_abares_trade <- function(cache) {
  abares_trade_dir <- file.path(.find_user_cache(), "abares_trade_dir/")
  if (cache && !dir.exists(abares_trade_dir)) {
    dir.create(abares_trade_dir, recursive = TRUE)
  }

  trade_zip <- file.path(tempdir(), "abares_trade_data.zip")

  .retry_download(
    url = "https://daff.ent.sirsidynix.net.au/client/en_AU/search/asset/1033841/1",
    .f = trade_zip
  )

  abares_trade <- data.table::fread(trade_zip)
  data.table::setnames(
    abares_trade,
    old = c(
      "Fiscal_year",
      "Month",
      "YearMonth",
      "Calendar_year",
      "TradeCode",
      "Overseas_location",
      "State",
      "Australian_port",
      "Unit",
      "TradeFlow",
      "ModeOfTransport",
      "Value",
      "Quantity",
      "confidentiality_flag"
    ),
    new = c(
      "Fiscal_year",
      "Month",
      "Year_month",
      "Calendar_year",
      "Trade_code",
      "Overseas_location",
      "State",
      "Australian_port",
      "Unit",
      "Trade_flow",
      "Mode_of_transport",
      "Value",
      "Quantity",
      "Confidentiality_flag"
    )
  )

  abares_trade[, Year_month := lubridate::ym(
    gsub(".", "-", Year_month, fixed = TRUE)
  )]

  if (cache) {
    data.table::fwrite(abares_trade,
      file = file.path(abares_trade_dir, "abares_trade.gz")
    )
  }
  return(abares_trade[])
}
