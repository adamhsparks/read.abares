#' Read ABS' Livestock Production and Value by Australia, State and Territory by Year
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
#' @param data_set A string value providing the desired livestock data, one of:
#' \describe{
#'  \item{livestock_and_products}{(default) value of livestock disposals and products by Australia, state and territory,}
#'  \item{cattle_herd}{Cattle herd experimental estimates by Australia, state and territory,}
#'  \item{cattle_herd_series}{Cattle herd experimental and historical estimates by Australia, state and territory – 2005 to 2024.}
#' }
#' @inheritParams read_aagis_regions
#'
#' @examplesIf interactive()
#' read_abs_livestock_data()
#'
#' @references <https://www.abs.gov.au/statistics/industry/agriculture/australian-agriculture-livestock>.
#' @returns A [data.table::data.table()] object of the requested data.
#' @export
#' @family ABS
#' @autoglobal

read_abs_livestock_data <- function(
  data_set = "herd_estimates",
  x = NULL
) {
  # NOTE: year is not an argument here as the data sets are not annual releases
  # yet. This should be updated as new releases are made available.
  #
  if (is.null(x)) {
    # see parse_abs_production_data.R for .find_years()
    data_set <- rlang::arg_match0(
      data_set,
      c("livestock_and_products", "cattle_herd", "cattle_herd_series")
    )
    data_set <- switch(
      data_set,
      "livestock_and_products" = "Value%20of%20livestock%20and%20products%202023-24.xlsx",
      "cattle_herd" = "Cattle%20herd_2023_24.xlsx",
      "cattle_herd_series" = "Cattle%20herd%20series_2005%20to%202024.xlsx"
    )
    base_url <- "https://www.abs.gov.au/statistics/industry/agriculture/australian-agriculture-livestock/AALDC_"

    x <- fs::path(tempdir(), "livestock_file")
    .retry_download(
      url = sprintf(
        "%s%s",
        base_url,
        data_set
      ),
      dest = .x,
      dataset_id = "livestock",
      show_progress = TRUE
    )
  }
  parse_abs_production_data(x)
}
