#' Get ABARES' National Scale "Land Use of Australia" Data
#'
#' An internal function used by [read_nlum_terra()] and [read_nlum_stars()] that
#'  downloads national level land use data GeoTIFF file.
#'
#' @param .data_set A string value indicating the GeoTIFF desired for download.
#' One of:
#' \describe{
#'  \item{Y201011}{Land use of Australia 2010–11}
#'  \item{Y201516}{Land use of Australia 2015–16}
#'  \item{Y202021}{Land use of Australia 2020–21}
#'  \item{C201121}{Land use of Australia change}
#'  \item{T201011}{Land use of Australia 2010–11 thematic layers}
#'  \item{T201516}{Land use of Australia 2015–16 thematic layers}
#'  \item{T202021}{Land use of Australia 2020–21 thematic layers}
#'  \item{P201011}{Land use of Australia 2010–11 agricultural commodities probability grids}
#'  \item{P201516}{Land use of Australia 2015–16 agricultural commodities probability grids}
#'  \item{P202021}{Land use of Australia 2020–21 agricultural commodities probability grids}
#' }.
#'
#' @references
#' ABARES 2024, Land use of Australia 2010–11 to 2020–21, Australian Bureau of
#' Agricultural and Resource Economics and Sciences, Canberra, November, CC BY
#' 4.0. \doi{10.25814/w175-xh85}.
#'
#' @examples
#' Y202021 <- .get_nlum(.data_set = "Y202021")
#'
#' Y202021
#'
#' @returns An invisible `NULL` called for its side effect of downloading the
#'  desired file.
#'
#' @autoglobal
#' @dev

.get_nlum <- function(.data_set) {
  .zip_file <- switch(
    .data_set,
    "Y202021" = "NLUM_v7_250_ALUMV8_2020_21_alb_package_20241128.zip",
    "Y201516" = "NLUM_v7_250_ALUMV8_2015_16_alb_package_20241128.zip",
    "Y201011" = "NLUM_v7_250_ALUMV8_2010_11_alb_package_20241128.zip",
    "C201121" = "NLUM_v7_250_CHANGE_SIMP_2011_to_2021_alb_package_20241128.zip",
    "T202021" = "NLUM_v7_250_INPUTS_2020_21_geo_package_20241128.zip",
    "T201516" = "NLUM_v7_250_INPUTS_2015_16_geo_package_20241128.zip",
    "T201011" = "NLUM_v7_250_INPUTS_2010_11_geo_package_20241128.zip",
    "P202021" = "NLUM_v7_250_AgProbabilitySurfaces_2020_21_geo_package_20241128.zip",
    "P201516" = "NLUM_v7_250_AgProbabilitySurfaces_2015_16_geo_package_20241128.zip",
    "P201011" = "NLUM_v7_250_AgProbabilitySurfaces_2010_11_geo_package_20241128.zip"
  )

  .x <- fs::path_temp(.zip_file)

  if (!fs::file_exists(.x)) {
    file_url <-
      sprintf(
        "https://www.agriculture.gov.au/sites/default/files/documents/%s",
        .zip_file
      )
    .retry_download(
      url = file_url,
      dest = .x
    )
  }
  return(invisible(NULL))
}
