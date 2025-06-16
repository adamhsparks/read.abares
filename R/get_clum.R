#' Get catchment scale Land Use of Australia data for local use
#'
#' An internal function used by [read_clum_terra] and [read_clum_stars] or
#'  [read_clum_commodities] that downloads catchment level land use data files,
#'  unzips the download file and deletes unnecessary files that are included in
#'  the download.  Data are cached on request.
#'
#' @param .data_set A string value indicating the data desired for download.
#' One of:
#' \describe{
#'  \item{clum_50m_2023_v2}{Catchment Scale Land Use of Australia – Update December 2023 version 2}
#'  \item{scale_date_update}{Catchment Scale Land Use of Australia - Date and Scale of Mapping}
#'  \item{CLUM_Commodities_2023}{Catchment Scale Land Use of Australia – Commodities – Update December 2023}
#' }.
#'
#' @details
#' The `CLUM_50m_2023v2` and `date_CLUM2023` datasets are available as GeoTIFF
#'  files. The `CLUM_Commodities_2023` dataset is available as a shapefile.
#'  The GeoTIFF files are both saved in the same format. The
#'  `CLUM_Commodities_2023` file is saved as a GeoPackage after correcting
#'  invalid geometries.
#'
#' @references
#' ABARES 2024, Catchment Scale Land Use of Australia – Update December 2023
#' version 2, Australian Bureau of Agricultural and Resource Economics and
#' Sciences, Canberra, June, CC BY 4.0, DOI: \doi{10.25814/2w2p-ph98}.
#'
#' @source
#' \url{https://10.25814/2w2p-ph98}.
#'
#' @examplesIf interactive()
#' CLUM50m <- get_clum(data_set = "CLUM_50m")
#'
#' CLUM50m
#'
#' @returns A `read.abares.clum` object, a list of files containing a spatial
#'  data file of or related to Australian catchment scale land use data.
#'
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
  if (fs::dir_exists(clum_dir)) {
    clum <- fs::dir_ls(fs::path_abs(clum_dir), regexp = "[.]tif$|[.]gpkg$")
    class(clum) <- union("read.abares.clum.files", class(clum))
    return(clum)
  }

  fs::dir_create(clum_dir, recurse = TRUE)

  file_url <-
    "https://data.gov.au/data/dataset/8af26be3-da5d-4255-b554-f615e950e46d/resource/"

  file_url <- switch(
    .data_set,
    "clum_50m_2023_v2" = sprintf(
      "%s6deab695-3661-4135-abf7-19f25806cfd7/download/clum_50m_2023_v2.zip",
      file_url
    ),
    "scale_date_update" = sprintf(
      "%s98b1b93f-e5e1-4cc9-90bf-29641cfc4f11/download/scale_date_update.zip",
      file_url
    ),
    "CLUM_Commodities_2023" = sprintf(
      "%sb216cf90-f4f0-4d88-980f-af7d1ad746cb/download/clum_commodities_2023.zip",
      file_url
    )
  )

  .retry_download(url = file_url, .f = download_file)

  tryCatch(
    {
      withr::with_dir(
        download_dir,
        utils::unzip(zipfile = download_file, exdir = download_dir)
      )
      if (.data_set != "CLUM_Commodities_2023") {
        if (
          isFALSE(fs::file_exists(fs::path(
            download_dir,
            "CLUM_DescriptiveMetadata_December2023.pdf"
          )))
        ) {
          fs::file_move(
            fs::path(
              clum_dir,
              "CLUM_DescriptiveMetadata_December2023.pdf"
            ),
            fs::path(download_dir, "CLUM_DescriptiveMetadata_December2023.pdf")
          )
        }

        fs::file_delete(
          setdiff(
            fs::dir_ls(clum_dir),
            fs::dir_ls(clum_dir, regexp = "[.]tif$|[.]tif[.]aux[.]xml$")
          )
        )
      } else {
        # handle the commodities shape file data
        x <- sf::st_read(
          fs::path(clum_dir, "CLUM_Commodities_2023.shp"),
          quiet = TRUE
        )
        x <- sf::st_make_valid(x)

        sf::st_write(
          x,
          fs::path(clum_dir, "CLUM_Commodities_2023.gpkg"),
          quiet = TRUE
        )

        if (
          isFALSE(fs::file_exists(fs::path(
            download_dir,
            "CLUMC_DescriptiveMetadata_December2023.pdf"
          )))
        ) {
          fs::file_move(
            fs::path(
              clum_dir,
              "CLUMC_DescriptiveMetadata_December2023.pdf"
            ),
            fs::path(download_dir, "CLUMC_DescriptiveMetadata_December2023.pdf")
          )
        }

        fs::file_delete(
          setdiff(
            fs::dir_ls(clum_dir),
            fs::dir_ls(clum_dir, regexp = "[.]gpkg$")
          )
        )
      }
    },
    error = function(e) {
      cli::cli_abort(
        "There was an issue with the downloaded file. I've deleted
           this bad version of the downloaded file, please retry.",
        call = rlang::caller_env()
      )
    }
  )

  if (cache) {
    fs::file_delete(download_file)
  }

  clum <- fs::dir_ls(fs::path_abs(clum_dir), regexp = "[.]tif$|[.]gpkg$")
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
  cli::cli_h1("Locally Available ABARES Catchment Scale Land Use Files")
  cli::cli_ul(basename(x))
  cli::cat_line()
  invisible(x)
}
