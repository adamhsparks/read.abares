#' Get Broadacre Crops Production and Value by Australia, State and Territory by Year
#'
#' Automates downloading and importing of \acronym{ABS} broadacre crop
#' production data. Please view the comments embedded in the spreadsheets
#' themselves (that really should be columns of comments on the data) for
#' important information. The `source` link provides a direct download for the
#' latest available spreadsheet to download and open in Excel.
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
#' @param file A string value providing a file path to an \acronym{ABS}
#'   Australian production data set that you have downloaded and saved locally.
#'   No checks are performed, it will attempt to parse any file you pass to it
#'   here. If this is used, other arguments will be ignored.
#'
#' @examplesIf interactive()
#' get_broadacre_crops_data()
#'
#' @references <https://www.abs.gov.au/statistics/industry/agriculture/australian-agriculture-broadacre-crops>.
#' @returns A [data.table::data.table()] object of the requested data.
#' @export
#' @autoglobal

read_abs_broadacre_crops_data <- function(
  crops = "winter",
  year = "latest",
  file = NULL
) {
  if (is.null(file)) {
    available <- .find_years(data_set = "broadacre")
    year <- rlang::arg_match(year, c("latest", available))
    crops <- rlang::arg_match(crops, c("winter", "summer", "sugarcane"))

    if (year == "latest") {
      year <- available[[1L]]
    }
    base_url <- "https://www.abs.gov.au/statistics/industry/agriculture/australian-agriculture-broadacre-crops/"

    file <- fs::path(tempdir(), "crops_file")
    .retry_download(
      url = sprintf(
        "%s%s/AABDC_%s_%s.xlsx",
        base_url,
        year,
        crops,
        gsub("-", "", year, fixed = TRUE)
      ),
      .f = file
    )
  }
  return(parse_abs_production_data(file))
}
