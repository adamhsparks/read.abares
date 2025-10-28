#' Get ABS' Broadacre Crops Production and Value by Australia, State and Territory by Year
#'
#' Automates downloading and importing of \acronym{ABS} broadacre crop
#' production data. Please view the comments embedded in the spreadsheets
#' themselves (that really should be columns of comments on the data) for
#' important information.
#'
#' Technically these data are from the Australian Bureau of Statistics
#' (\acronym{ABS}, not \acronym{ABARES}, but the data is agricultural and so
#' it's serviced in this package.
#'
#' @param crops A character vector providing the desired cropping data, one of:
#'  * winter (default),
#'  * summer or
#'  * sugarcane.
#' @param year A string value providing the year of interest to download.
#'  Formatted as `"2022-23"` or `"2023-24"` or use `"latest"` for the most
#'  recent release available. Defaults to `"latest"`.
#' @inheritParams read_aagis_regions
#'
#' @examplesIf interactive()
#' broadacre_data  <- read_abs_broadacre_data()
#'
#' broadacre_data
#'
#' @references
#' <https://www.abs.gov.au/statistics/industry/agriculture/australian-agriculture-broadacre-crops>.
#' @returns A [data.table::data.table()] object of the requested data.
#' @export
#' @family ABS
#' @autoglobal

read_abs_broadacre_data <- function(
  crops = "winter",
  year = "latest",
  x = NULL
) {
  if (is.null(x)) {
    if (length(crops) != 1L || !is.character(crops) || is.na(crops)) {
      cli::cli_abort("{.var crops} must be a single character string value.")
    }
    # see parse_abs_production_data.R for .find_years()
    available <- .find_years(data_set = "broadacre")
    year <- rlang::arg_match0(year, c("latest", available))
    #TODO: replace stringr with something that's not another dep
    crops <- stringr::str_to_title(crops)
    crops <- rlang::arg_match0(crops, c("Winter", "Summer", "Sugarcane"))

    # winter broadacre has a different naming scheme than the other two crops
    if (crops == "Winter") {
      crops <- "Winter_Broadacre"
    }
    if (crops == "Summer" && year == "2022-23") {
      crops <- "Summer_Broadacre"
    }
    if (year == "latest") {
      year <- available[[1L]]
    }
    base_url <-
      "https://www.abs.gov.au/statistics/industry/agriculture/australian-agriculture-broadacre-crops/"

    x <- fs::path(tempdir(), sprintf("%s_crops_file", crops))
    .retry_download(
      url = sprintf(
        "%s%s/AABDC_%s_%s.xlsx",
        base_url,
        year,
        crops,
        gsub("-", "", year, fixed = TRUE)
      ),
      dest = x
    )
  }
  return(parse_abs_production_data(x))
}
