#' Read Livestock Production and Value by Australia, State and Territory by Year
#'
#' Automates downloading and importing of \acronym{ABS} livestock production
#' data. Please view the comments embedded in the spreadsheets themselves (that
#' really should be columns of comments on the data) for important information.
#' The `source` link provides a direct download for the spreadsheet to
#' download and open in Excel.
#'
#' Technically these data are from the Australian Bureau of Statistics
#' (\acronym{ABS}, not \acronym{ABARES}, but the data is agricultural and so
#' it's serviced in this package.
#'
#' @inheritParams read_broadacre_crops_data
#'
#' @reference <https://www.abs.gov.au/statistics/industry/agriculture/australian-agriculture-livestock>
#' @examplesIf interactive()
#' read_livestock_data()
#'
#' @returns A [data.table::data.table()] object of the requested data.
#' @export
#' @autoglobal

read_livestock_data <- function(year = "latest", file = NULL) {
  if (is.null(file)) {
    # see parse_abs_production_data.R for .find_years()
    available <- .find_years(data_set = "livestock")
    year <- rlang::arg_match(year, c("latest", available))

    if (year == "latest") {
      year <- available[[1L]]
    }
    base_url <- "https://www.abs.gov.au/statistics/industry/agriculture/australian-agriculture-livestock/"

    livestock_file <- fs::path(tempdir(), "livestock_file")
    .retry_download(
      url = sprintf(
        "%s%s/AALDC_Value%%20of%%20livestock%%20and%%20products%%20%s.xlsx",
        base_url,
        year,
        year
      ),
      .f = livestock_file
    )
  }
  parse_abs_production_data(file)
}
