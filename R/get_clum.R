#' Get catchment scale Land Use of Australia data for local use
#'
#' An internal function used by [read_clum_terra] and [read_clum_stars] that
#'  downloads national level land use data GeoTIFF file, unzips the download
#'  file and deletes unnecessary files that are included in the download.  Data
#'  are cached on request.
#'
#' @param .data_set A string value indicating the GeoTIFF desired for download.
#' One of:
#' \describe{
#'  \item{Y201011}{Land use of Australia 2010–11}
#'  \item{Y201516}{Land use of Australia 2015–16}
#'  \item{Y202021}{Land use of Australia 2020–21}
#'  \item{C201021}{Land use of Australia change}
#'  \item{T201011}{Land use of Australia 2010–11 thematic layers}
#'  \item{T201516}{Land use of Australia 2015–16 thematic layers}
#'  \item{T202021}{Land use of Australia 2020–21 thematic layers}
#'  \item{P201011}{Land use of Australia 2010–11 agricultural commodities probability grids}
#'  \item{P201516}{Land use of Australia 2015–16 agricultural commodities probability grids}
#'  \item{P202021}{Land use of Australia 2020–21 agricultural commodities probability grids}
#' }
#'
#' @references
#' ABARES 2024, Land use of Australia 2010–11 to 2020–21, Australian Bureau of
#' Agricultural and Resource Economics and Sciences, Canberra, November, CC BY
#' 4.0. \doi{10.25814/w175-xh85}
#'
#' @source
#' \url{https://doi.org/10.25814/w175-xh85}
#'
#' @examplesIf interactive()
#' Y202021 <- get_clum(data_set = "Y202021")
#'
#' Y202021
#'
#' @returns A `read.abares.clum` object, a list of files containing a GeoTIFF of
#'  national scale land use data and a PDF file of metadata.
#'
#' @family Land Use
#' @autoglobal
#' @dev

.get_clum <- function(.data_set, .cache) {
  download_file <- data.table::fifelse(
    .cache,
    fs::path(.find_user_cache(), "clum", sprintf("%s.zip", .data_set)),
    fs::path(tempdir(), "clum", sprintf("%s.zip", .data_set))
  )

  # this is where the zip file is downloaded
  download_dir <- fs::path_dir(download_file)

  # this is where the zip files are unzipped and read from
  clum_dir <- fs::path(download_dir, .data_set)

  # only download if the files aren't already local
  if (isFALSE(fs::dir_exists(clum_dir))) {
    fs::dir_create(clum_dir, recurse = TRUE)
  }

  file_url <-
    "https://www.agriculture.gov.au/sites/default/files/documents/"

  file_url <- switch(
    data_set,
    "Y202021" = sprintf(
      "%sNLUM_v7_250_ALUMV8_2020_21_alb_package_20241128.zip",
      file_url
    ),
    "Y201516" = sprintf(
      "%sNLUM_v7_250_ALUMV8_2015_16_alb_package_20241128.zip",
      file_url
    ),
    "Y201011" = sprintf(
      "%sNLUM_v7_250_ALUMV8_2010_11_alb_package_20241128.zip",
      file_url
    ),
    "C201021" = sprintf(
      "%sNLUM_v7_250_CHANGE_SIMP_2011_to_2021_alb_package_20241128.zip",
      file_url
    ),
    "T202021" = sprintf(
      "%sNLUM_v7_250_INPUTS_2020_21_geo_package_20241128.zip",
      file_url
    ),
    "T201516" = sprintf(
      "%sNLUM_v7_250_INPUTS_2015_16_geo_package_20241128.zip",
      file_url
    ),
    "T201011" = sprintf(
      "%sNLUM_v7_250_INPUTS_2010_11_geo_package_20241128.zip",
      file_url
    ),
    "P202021" = sprintf(
      "%sNLUM_v7_250_AgProbabilitySurfaces_2020_21_geo_package_20241128.zip",
      file_url
    ),
    "P201516" = sprintf(
      "%sNLUM_v7_250_AgProbabilitySurfaces_2015_16_geo_package_20241128.zip",
      file_url
    ),
    "P201011" = sprintf(
      "%sNLUM_v7_250_AgProbabilitySurfaces_2010_11_geo_package_20241128.zip",
      file_url
    )
  )

  .retry_download(url = file_url, .f = download_file)

  tryCatch(
    {
      withr::with_dir(
        download_dir,
        utils::unzip(zipfile = download_file, exdir = clum_dir)
      )

      if (
        isFALSE(fs::file_exists(fs::path(
          download_dir,
          "NLUM_v7_DescriptiveMetadata_20241128_0.pdf"
        )))
      ) {
        fs::file_move(
          fs::path(
            clum_dir,
            "NLUM_v7_DescriptiveMetadata_20241128_0.pdf"
          ),
          fs::path(download_dir, "NLUM_v7_DescriptiveMetadata_20241128_0.pdf")
        )
      }

      fs::dir_delete(
        c(fs::path(clum_dir, "Maps"), fs::path(clum_dir, "Symbology"))
      )
      fs::file_delete(
        setdiff(
          fs::dir_ls(clum_dir),
          fs::dir_ls(clum_dir, regexp = "[.]tif$|[.]tif[.]aux[.]xml$")
        )
      )
    },
    error = function(e) {
      cli::cli_abort(
        "There was an issue with the downloaded file. I've deleted
           this bad version of the downloaded file, please retry.",
        call = rlang::caller_env()
      )
    }
  )

  if (fs::file_exists(download_file)) {
    fs::file_delete(download_file)
  }

  clum <- fs::dir_ls(fs::path_abs(clum_dir), glob = "*.tif")

  class(clum) <- union("read.abares.clum.files", class(clum))
  return(clum)
}


#' Prints read.abares.clum.files objects
#'
#' Custom [base::print()] method for `read.abares.clum.files` objects.
#'
#' @param x a `read.abares.agfd.clum.files` object.
#' @param ... ignored.
#' @export
#' @autoglobal
#' @noRd
print.read.abares.agfd.clum.files <- function(x, ...) {
  cli::cli_h1("Locally Available ABARES Land Use Files")
  cli::cli_ul(basename(x))
  cli::cat_line()
  invisible(x)
}
