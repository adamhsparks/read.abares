#' Read ABARES 'Trade Data Regions' from the ABARES Trade Dashboard
#'
#' Fetches and imports  \acronym{ABARES} trade regions data.
#'
#' @note
#' Columns are renamed for consistency with other \acronym{ABARES} products
#'  serviced in this package using a snake_case format and ordered consistently.
#'
#' @examplesIf interactive()
#' trade_regions <- read_abares_trade_regions()
#'
#' trade_regions
#'
#' @returns A \CRANpkg{data.table} object of the \acronym{ABARES} trade data
#'  regions.
#' @family Trade
#' @references <https://daff.ent.sirsidynix.net.au/client/en_AU/search/asset/1033841/0>
#' @source <https://daff.ent.sirsidynix.net.au/client/en_AU/search/asset/1033841/2>
#' @autoglobal
#' @export

read_abares_trade_regions <- function() {
  trade_regions <- fs::path(tempdir(), "trade_regions")
  .retry_download(
    url = "https://daff.ent.sirsidynix.net.au/client/en_AU/search/asset/1033841/2",
    .f = trade_regions
  )

  abares_trade_regions <- data.table::fread(trade_regions, fill = TRUE)

  return(abares_trade_regions[])
}
