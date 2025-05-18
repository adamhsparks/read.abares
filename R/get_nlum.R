#' Get national scale Land Use of Australia data for local use
#'
#' Downloads national level land use data GeoTIFF file, unzips the download file
#'  and deletes unnecessary files that are included in the download.  Data are
#'  cached on request.
#'
#' @details
#'
#' From the [ABARES website](https://www.agriculture.gov.au/abares/aclump/land-use/land-use-of-australia-2010-11-to-2020-21):
#' \dQuote{The _Land use of Australia 2010–11 to 2020–21_ data package consists
#' of seamless continental rasters that present land use at national scale for
#' 2010–11, 2015–16 and 2020–21 and the associated change between each target
#' period.  Non-agricultural land uses are mapped using 7 thematic layers,
#' derived from existing datasets provided by state and territory jurisdictions
#' and external agencies. These 7 layers are: protected areas, topographic
#' features, land tenure, forest type, catchment scale land use, urban
#' boundaries, and stock routes. The agricultural land uses are based on the
#' Australian Bureau of Statistics’ 2010–11, 2015–16 and 2020–21 agricultural
#' census data; with spatial distributions modelled using Terra Moderate
#' Resolution Imaging Spectroradiometer (\acronym{MODIS}) satellite imagery and
#' training data, assisted by spatial constraint layers for cultivation,
#' horticulture, and irrigation.
#'
#' Land use is specified according to the Australian Land Use and Management
#' (\acronym{ALUM}) Classification version 8. The same method is applied to all
#' target periods using representative national datasets for each period, where
#' available. All rasters are in GeoTIFF format with geographic coordinates in
#' Geocentric Datum of Australian 1994 (GDA94) and a 0.002197 degree
#' (~250&nbsp;metre) cell size.
#'
#' The _Land use of Australia 2010–11 to 2020–21_ data package is a product of
#' the Australian Collaborative Land Use and Management Program. This data
#' package replaces the Land use of Australia 2010–11 to 2015–16 data package,
#' with updates to these time periods.}
#'  -- \acronym{ABARES}, 2024-11-28
#'
#' @param data_set A string value indicating the GeoTIFF desired for download.
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
#' @param cache Cache the Australian Gridded Farm Data files after download
#'  using [tools::R_user_dir] to identify the proper directory for storing user
#'  data in a cache for this package. Defaults to `TRUE`, caching the files
#'  locally. If `FALSE`, this function uses `tempdir()` and the files are
#'  deleted upon closing of the active \R session.
#' @details
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
#' Y202021 <- get_nlum(data_set = "Y202021")
#'
#' Y202021
#'
#' @returns A `read.abares.nlum` object, a list of files containing a GeoTIFF of
#'  national scale land use data and a PDF file of metadata.
#'
#' @family Land Use
#' @autoglobal
#' @export

get_nlum <- function(data_set, cache = TRUE) {
  valid_sets <- c(
    "Y202021",
    "Y201516",
    "Y201011",
    "C201021",
    "T202021",
    "T201516",
    "T201011",
    "P202021",
    "P201516",
    "P201011"
  )

  data_set <- rlang::arg_match(data_set, valid_sets)

  download_file <- data.table::fifelse(
    cache,
    fs::path(.find_user_cache(), "nlum", sprintf("%s.zip", data_set)),
    fs::path(tempdir(), "nlum", sprintf("%s.zip", data_set))
  )

  # this is where the zip file is downloaded
  download_dir <- fs::path_dir(download_file)

  # this is where the zip files are unzipped and read from
  nlum_dir <- fs::path(download_dir, data_set)

  # only download if the files aren't already local
  if (!fs::dir_exists(nlum_dir)) {
    # if caching is enabled but {read.abares} cache doesn't exist, create it
    if (cache) {
      fs::dir_create(nlum_dir, recurse = TRUE)
    }

    url <-
      "https://www.agriculture.gov.au/sites/default/files/documents/"

    url <- switch(
      data_set,
      "Y202021" = sprintf(
        "%sNLUM_v7_250_ALUMV8_2020_21_alb_package_20241128.zip",
        url
      ),
      "Y201516" = sprintf(
        "%sNLUM_v7_250_ALUMV8_2015_16_alb_package_20241128.zip",
        url
      ),
      "Y201011" = sprintf(
        "%sNLUM_v7_250_ALUMV8_2010_11_alb_package_20241128.zip",
        url
      ),
      "C201021" = sprintf(
        "%sNLUM_v7_250_CHANGE_SIMP_2011_to_2021_alb_package_20241128.zip",
        url
      ),
      "T202021" = sprintf(
        "%sNLUM_v7_250_INPUTS_2020_21_geo_package_20241128.zip",
        url
      ),
      "T201516" = sprintf(
        "%sNLUM_v7_250_INPUTS_2015_16_geo_package_20241128.zip",
        url
      ),
      "T201011" = sprintf(
        "%sNLUM_v7_250_INPUTS_2010_11_geo_package_20241128.zip",
        url
      ),
      "P202021" = sprintf(
        "%sNLUM_v7_250_AgProbabilitySurfaces_2020_21_geo_package_20241128.zip",
        url
      ),
      "P201516" = sprintf(
        "%sNLUM_v7_250_AgProbabilitySurfaces_2015_16_geo_package_20241128.zip",
        url
      ),
      "P201011" = sprintf(
        "%sNLUM_v7_250_AgProbabilitySurfaces_2010_11_geo_package_20241128.zip",
        url
      )
    )

    .retry_download(url = url, .f = download_file)

    tryCatch(
      {
        withr::with_dir(
          download_dir,
          utils::unzip(zipfile = download_file, exdir = nlum_dir)
        )

        if (
          !fs::file_exists(fs::path(
            download_dir,
            "NLUM_v7_DescriptiveMetadata_20241128_0.pdf"
          ))
        ) {
          fs::file_move(
            fs::path(
              nlum_dir,
              "NLUM_v7_DescriptiveMetadata_20241128_0.pdf"
            ),
            fs::path(download_dir, "NLUM_v7_DescriptiveMetadata_20241128_0.pdf")
          )
        }

        fs::dir_delete(
          c(fs::path(nlum_dir, "Maps"), fs::path(nlum_dir, "Symbology"))
        )
        fs::file_delete(
          c(
            fs::path(nlum_dir, "NLUM_v7_DescriptiveMetadata_20241128_0.pdf"),
            fs::path(nlum_dir, "Thumbs.db"),
            fs::path(nlum_dir, "*.tif.aux.xml")
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
  }

  if (fs::file_exists(download_file)) {
    fs::file_delete(download_file)
  }

  nlum <- fs::dir_ls(nlum_dir, full.names = TRUE)

  class(nlum) <- union("read.abares.nlum.files", class(nlum))
  return(nlum)
}

#' Prints read.abares.nlum objects
#'
#' Custom [base::print()] method for `read.abares.nlum.files` objects.
#'
#' @param x a `read.abares.nlum.files` object.
#' @param ... ignored.
#' @export
#' @autoglobal
#' @noRd
print.read.abares.nlum.files <- function(x, ...) {
  cli::cli_h1("Locally Available ABARES National Land Use Files")
  nlum_files <- basename(x)
  nlum_files <- nlum_files[!grepl("csv|pdf", nlum)]
  cli::cli_ul(tools::file_path_sans_ext(basename(nlum_files)))
  cli::cat_line()
  invisible(x)
}

#' Displays the PDF metadata for the National Land Use raster files in a native viewer
#'
#' Each National Land Use raster file comes with a PDF of the metadata. This
#'  function will open and display that file using the native PDF viewer for any
#'  system.
#' @examples
#' view_nlum_metadata_pdf()
#' @returns Called for its side-effects, opens the system's native PDF viewer to
#'  display the requested metadata file.
#' @export
#' @autoglobal

view_nlum_metadata_pdf <- function() {
  "%,%" <- paste0
  n <- grep("pdf", names(options()))
  nlum_metadata_pdf_path <- fs::path(
    .find_user_cache(),
    "nlum",
    "NLUM_v7_DescriptiveMetadata_20241128_0.pdf"
  )
  system(paste0('open "', nlum_metadata_pdf_path, '"'))
}
