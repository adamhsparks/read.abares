#' Read data from the ABARES Trade Dashboard
#'
#' Fetches and imports  \acronym{ABARES} trade data.
#'
#' @note
#' Columns are renamed for consistency with other \acronym{ABARES} products
#'  serviced in this package using a snake_case format and ordered consistently.
#'
#' @param cache `Boolean` Cache the \acronym{ABARES} trade data after download
#'  using `tools::R_user_dir()` to identify the proper directory for storing
#'  user data in a cache for this package. Defaults to `TRUE`, caching the files
#'  locally as a native \R object. If `FALSE`, this function uses `tempdir()`
#'  and the files are deleted upon closing of the active \R session.
#'
#' @examplesIf interactive()
#' trade <- read_abares_trade()
#'
#' trade
#'
#' @return A \CRANpkg{data.table} object of the \acronym{ABARES} trade data.
#' @family Trade
#' @references <https://www.agriculture.gov.au/abares/research-topics/trade/dashboard>
#' @source <https://daff.ent.sirsidynix.net.au/client/en_AU/search/asset/1033841/0>
#' @autoglobal
#' @export

read_abares_trade <- function(cache = TRUE) {
  abares_trade_rds <- file.path(
    .find_user_cache(),
    "abares_trade_dir/abares_trade.rds"
  )

  if (file.exists(abares_trade_rds)) {
    return(readRDS(abares_trade_rds))
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
#'  the files locally as a native \R object. If `FALSE`, this function uses
#'  `tempdir()` and the files are deleted upon closing of the active \R session.
#'
#' @return A \CRANpkg{data.table} object of the \acronym{ABARES} trade data.
#' @noRd
#' @autoglobal
#' @keywords Internal
.download_abares_trade <- function(cache) {
  # if you make it this far, the cached file doesn't exist, so we need to
  # download it either to `tempdir()` and dispose or cache it for later.
  cached_zip <- file.path(.find_user_cache(), "abares_trade_dir/trade.csv")
  tmp_zip <- file.path(file.path(tempdir(), "abares_trade.zip"))
  trade_zip <- data.table::fifelse(cache, cached_zip, tmp_zip)
  abares_trade_dir <- dirname(trade_zip)
  abares_trade_rds <- file.path(abares_trade_dir, "abares_trade.rds")

  # the user-cache may not exist if caching is enabled for the 1st time
  if (cache && !dir.exists(abares_trade_dir)) {
    dir.create(abares_trade_dir, recursive = TRUE)
  }

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
    saveRDS(abares_trade, file = abares_trade_rds)
    unlink(c(
      trade_zip
    ))
  }
  return(abares_trade)
}
