#' Get ABARES' National Scale "Land Use of Australia" Data
#'
#' An internal function used by [read_nlum_terra()] and [read_nlum_stars()] that
#'  downloads national level land use data GeoTIFF file, unzips the download
#'  file and deletes unnecessary files that are included in the download.
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
#' @param .x A user specified path to a local zip file containing the data.
#'
#' @references
#' ABARES 2024, Land use of Australia 2010–11 to 2020–21, Australian Bureau of
#' Agricultural and Resource Economics and Sciences, Canberra, November, CC BY
#' 4.0. \doi{10.25814/w175-xh85}.
#'
#' @examplesIf interactive()
#' Y202021 <- .get_nlum(.data_set = "Y202021", .x = NULL)
#'
#' Y202021
#'
#' @returns A list object of NLUM files.
#'
#' @autoglobal
#' @dev

.get_nlum <- function(.data_set, .x) {
  if (is.null(.x)) {
    ds <- switch(
      .data_set,
      "Y202021" = "NLUM_v7_250_ALUMV8_2020_21_alb_package_20241128",
      "Y201516" = "NLUM_v7_250_ALUMV8_2015_16_alb_package_20241128",
      "Y201011" = "NLUM_v7_250_ALUMV8_2010_11_alb_package_20241128",
      "C201121" = "NLUM_v7_250_CHANGE_SIMP_2011_to_2021_alb_package_20241128",
      "T202021" = "NLUM_v7_250_INPUTS_2020_21_geo_package_20241128",
      "T201516" = "NLUM_v7_250_INPUTS_2015_16_geo_package_20241128",
      "T201011" = "NLUM_v7_250_INPUTS_2010_11_geo_package_20241128",
      "P202021" = "NLUM_v7_250_AgProbabilitySurfaces_2020_21_geo_package_20241128",
      "P201516" = "NLUM_v7_250_AgProbabilitySurfaces_2015_16_geo_package_20241128",
      "P201011" = "NLUM_v7_250_AgProbabilitySurfaces_2010_11_geo_package_20241128",
    )
    .x <- fs::path(tempdir(), sprintf("%s.zip", ds))

    file_url <-
      sprintf(
        "https://www.agriculture.gov.au/sites/default/files/documents/%s.zip",
        ds
      )
    if (!fs::file_exists(.x)) {
      .retry_download(
        url = file_url,
        .f = .x
      )
      .unzip_file(.x)
    }
  } else {
    ds <- fs::path_file(fs::path_ext_remove(.x))
  }

  return(fs::dir_ls(
    fs::path(fs::path_dir(.x), ds)
  ))
}


#' Prints read.abares.nlum.xs Objects
#'
#' Custom [base::print()] method for `read.abares.nlum.xs` objects.
#'
#' @param x a `read.abares.agfd.nlum.xs` object.
#' @param ... ignored.
#' @export
#' @autoglobal
#' @noRd
print.read.abares.agfd.nlum.files <- function(x, ...) {
  cli::cli_h1("Locally Available ABARES National Scale Land Use Files")
  cli::cli_ul(basename(x))
  cli::cat_line()
  invisible(x)
}
