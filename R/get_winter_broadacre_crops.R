#' Get Winter Broadacre Crops by Australia, State and Territory by Year
#'
#'
#' @examples
#' get_winter_crops()
#'
#' @returns A [data.table::data.table() object of the requested data.
#' @autoglobal
#'

get_winter_crops <- function() {
  base_url <- "https://www.abs.gov.au/statistics/industry/agriculture/australian-agriculture-broadacre-crops/"
  year_url <- "2023-24/"
  file_url <- "AABDC_Winter_Broadacre_202324.xlsx"
  winter_crops <- fs::path(tempdir(), "winter_crops")
  .retry_download(
    url = sprintf("%s%s%s", base_url, year_url, file_url),
    .f = winter_crops
  )
  y <- abares_crop_data(winter_crops)
}


#' Create a unified data.table object of all sheets in Excel Workbook
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
