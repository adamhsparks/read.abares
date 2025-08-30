#' Read Data from the ABARES Trade Dashboard
#'
#' Fetches and imports \acronym{ABARES} trade data. As the data x is large,
#'  ~1.4GB uncompressed \acronym{CSV} x.
#'
#' @inheritParams read_aagis_regions
#' @note
#' Columns are renamed for consistency with other \acronym{ABARES} products
#'  serviced in this package using a snake_case format and ordered
#'  consistently.
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

read_abares_trade <- function(x = NULL) {
  if (is.null(x)) {
    x <- fs::path(tempdir(), "abares_trade_data.zip")

    .retry_download(
      url = "https://daff.ent.sirsidynix.net.au/client/en_AU/search/asset/1033841/1",
      .f = x
    )
  }
  abares_trade <- data.table::fread(x)
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

  abares_trade[,
    Year_month := lubridate::ym(
      gsub(".", "-", Year_month, fixed = TRUE)
    )
  ]

  return(abares_trade[])
}
