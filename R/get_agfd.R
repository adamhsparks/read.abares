#' Get "Australian Gridded Farm Data" (AGFD)
#'
#' Used by the `read_agfd` family of functions, downloads the "Australian
#'  Gridded Farm Data" (\acronym{AGFD}) data and unzips the compressed files to
#'  NetCDF for importing.
#'
#' @param .fixed_prices Download historical climate and prices or historical
#'  climate and fixed prices as described in (Hughes *et al.* 2022).
#' @param .yyyy Returns only data for the specified year or years for climate
#'  data (fixed prices) or the years for historical climate and prices depending
#'  upon the setting of `.fixed_prices`.  Note that this will still download the
#'  entire data set, that cannot be avoided, but will only return the
#'  requested year(s) in your \R session.  Valid years are from 1991 to 2023
#'  inclusive.
#'
#' @examples
#' agfd <- get_agfd()
#'
#' agfd
#'
#' @returns A `list()` object, a list of NetCDF files containing the "Australian
#'   Gridded Farm Data".
#' @autoglobal
#' @dev

.get_agfd <- function(
  .fixed_prices,
  .yyyy
) {
  download_file <- fs::path(tempdir(), "agfd.zip")

  # this is where the zip file is downloaded
  download_dir <- fs::path_dir(download_file)

  # this is where the zip files are unzipped and read from
  agfd_nc_dir <- data.table::fifelse(
    .fixed_prices,
    fs::path(download_dir, "historical_climate_prices_fixed"),
    fs::path(download_dir, "historical_climate_and_prices")
  )

  file_url <- data.table::fifelse(
    .fixed_prices,
    "https://daff.ent.sirsidynix.net.au/client/en_AU/search/asset/1036161/3",
    "https://daff.ent.sirsidynix.net.au/client/en_AU/search/asset/1036161/2"
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
      fs::file_delete(download_file, download_dir)
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

  agfd_nc <- fs::dir_ls(agfd_nc_dir, full.names = TRUE)

  if (isFALSE(missing(.yyyy))) {
    yyyy <- sprintf("c%d", .yyyy)
    agfd_nc <- agfd_nc[grepl(paste(yyyy, collapse = "|"), names(agfd_nc))]
  }
  return(agfd_nc)
}
