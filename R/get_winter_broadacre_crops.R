#' Get Winter Broadacre Crops by Australia, State and Territory by Year
#'
#' Technically these are from the Australian Bureau of Statistics (\acronym{ABS}
#' data, not \acronym{ABARES}, but the data is agricultural and so it's serviced
#' here.
#'
#' @param crops A character vector providing the desired cropping data, one of:
#'  * winter,
#'  * summer or
#'  * sugarcane.
#' @param year A numeric value providing the year of interest to download.
#'  Formatted as `202223` or `202324` or just use `"latest"` for the most
#'  recent release.
#'
#' @examples
#' get_broadacre_crops_data()
#'
#' @returns A [data.table::data.table() object of the requested data.
#' @autoglobal
#'

get_broadacre_crops_data <- function(crops, year = "latest") {
  base_url <- "https://www.abs.gov.au/statistics/industry/agriculture/australian-agriculture-broadacre-crops/"



 year_url <- switch(year,
         202223 = "2022-23",
         202324 = "2023-24",
         latest = "") 

  file_url <- "AABDC_Winter_Broadacre_202324.xlsx"
  winter_crops <- fs::path(tempdir(), "winter_crops")
  .retry_download(
    url = sprintf("%s%s%s", base_url, year_url, file_url),
    .f = winter_crops
  )
  y <- abares_crop_data(winter_crops)
}


#' Create a Unified data.table Object of All Sheets in an Excel Workbook
#'
#' @param filename The name of the Excel workbook for import
#'
#' @returns A [data.table::data.table()] object.
#' @autoglobal
#' @dev
abares_crop_data <- function(filename) {
  sheet_names <- readxl::excel_sheets(filename)
  x <- lapply(sheet_names, function(X) {
    data.table::as.data.table(readxl::read_excel(
      filename,
      sheet = X,
      .name_repair = "universal_quiet"
    ))
  })

  x <- x[-1L] #drop first table with no data
  x[length(x)] <- NULL #drop last table w/ no data
  loc_region <- which(x[[2L]][, 1L] == "Region")
  x <- lapply(x, function(X) {
    X[-c(1L:3L)]
  })

  x <- lapply(x, function(x) {
    data.table::setnames(x, as.character(unlist(x[1L, ])))
    x <- x[-1L, ]
    return(x)
  })

  x <- data.table::rbindlist(x)
  x <- x[!grep("Commonwealth", x$Region, fixed = TRUE), ]

  x <- x[,
    c("crop", "units") := data.table::tstrsplit(
      `Data item`,
      " - ",
      fixed = TRUE
    )
  ]
  x[, `Data item` := NULL]
  return(x)
}

https://www.abs.gov.au/statistics/industry/agriculture/australian-agriculture-broadacre-crops

#' Find Which Financial Years Data are Available for
.find_years <- function(crops) {

  crop_url = "https://www.abs.gov.au/statistics/industry/agriculture/australian-agriculture-broadacre-crops",
 text <- htm2text::gettxt(crop_url)

matches <- regmatches(text, gregexpr("\\b\\d{4}-\\d{2}\\b", text))
}
