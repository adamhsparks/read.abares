#' Get ABS' Horticulture Crops Production and Value by Australia, State and Territory by Year
#'
#' Automates downloading and importing of \acronym{ABS} horticulture crop
#' production data. Please view the comments embedded in the spreadsheets
#' themselves (that really should be columns of comments on the data) for
#' important information.
#'
#' Technically these data are from the Australian Bureau of Statistics
#' (\acronym{ABS}, not \acronym{ABARES}, but the data is agricultural and so
#' it's serviced in this package.
#'
#' @inheritParams read_abs_broadacre_data
#' @inheritParams read_aagis_regions
#'
#' @examplesIf interactive()
#' read_abs_horticultural_data()
#'
#' @references <https://www.abs.gov.au/statistics/industry/agriculture/australian-agriculture-horticulture/>.
#' @returns A [data.table::data.table()] object of the requested data.
#' @autoglobal
#' @family ABS
#' @export

read_abs_horticulture_data <- function(year = "latest", x = NULL) {
  if (is.null(x)) {
    # see parse_abs_production_data.R for .find_years()
    available <- .find_years(data_set = "horticulture")
    year <- rlang::arg_match(year, c("latest", available))

    if (year == "latest") {
      year <- available[[1L]]
    }
    base_url <- "https://www.abs.gov.au/statistics/industry/agriculture/australian-agriculture-horticulture/"

    x <- fs::path(tempdir(), "hort_crops_file")

    .retry_download(
      url = sprintf(
        "%s%s/AAHDC_Aust_Horticulture_%s.xlsx",
        base_url,
        year,
        gsub("-", "", year, fixed = TRUE)
      ),
      .f = x
    )
  }

  return(parse_abs_production_data(x))
}
