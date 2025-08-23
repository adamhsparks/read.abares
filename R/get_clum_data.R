#' Get catchment scale \dQuote{Land Use of Australia} data
#'
#' An internal function used by [read_clum_terra()] and [read_clum_stars()] that
#'  downloads catchment level land use data files.
#'
#' @param .data_set A string value indicating the data desired for download.
#' One of:
#' \describe{
#'  \item{clum_50m_2023_v2}{Catchment Scale Land Use of Australia – Update December 2023 version 2}
#'  \item{scale_date_update}{Catchment Scale Land Use of Australia - Date and Scale of Mapping}
#' }.
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
#' CLUM50m <- get_clum(.data_set = "clum_50m_2023_v2")
#'
#' CLUM50m
#'
#' @returns A list of files containing a spatial
#'  data file of or related to Australian catchment scale land use data.
#'
#' @autoglobal
#' @dev

.get_clum <- function(.data_set) {
  talktalk <- !(getOption("read.abares.verbosity") %in% c("quiet", "minimal"))

  download_file <- fs::path(tempdir(), "clum", sprintf("%s.zip", .data_set))

  # this is where the zip file is downloaded
  download_dir <- fs::path_dir(download_file)

  # this is where the zip files are unzipped and read from
  clum_dir <- fs::path(download_dir, .data_set)

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
    )
  )

  .retry_download(
    url = file_url,
    .f = download_file
  )

  tryCatch(
    {
      withr::with_dir(
        download_dir,
        utils::unzip(zipfile = download_file, exdir = download_dir)
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

  clum <- fs::dir_ls(fs::path_abs(clum_dir), regexp = "[.]tif$")
  return(clum)
}
