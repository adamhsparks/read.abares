#' Read "Trade Data Regions" from the ABARES Trade Dashboard
#'
#' Fetches and imports \acronym{ABARES} "Trade Data Regions".
#'
#' @inheritParams read_aagis_regions
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

read_abares_trade_regions <- function(file = NULL) {
  if (is.null(file)) {
    file <- fs::path(tempdir(), "trade_regions")
    .retry_download(
      url = "https://daff.ent.sirsidynix.net.au/client/en_AU/search/asset/1033841/2",
      .f = file
    )
  }
  abares_trade_regions <- data.table::fread(file, fill = TRUE)

  return(abares_trade_regions[])
}
