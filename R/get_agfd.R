#' Get ABARES' "Australian Gridded Farm Data" (AGFD)
#'
#' Used by the `read_agfd` family of functions, downloads the "Australian
#'  Gridded Farm Data" (\acronym{AGFD}) data.
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
#' # this will download the data and then return only 2020 and 2021 years' data
#' agfd <- .get_agfd(.fixed_prices = TRUE, .yyyy = 2020:2021)
#'
#' agfd
#'
#' @returns A `list()` object, a list of NetCDF files containing the "Australian
#'   Gridded Farm Data".
#' @autoglobal
#' @dev

.get_agfd <- function(.fixed_prices, .yyyy) {
  .x <- fs::path(
    tempdir(),
    sprintf(
      "%s.zip",
      data.table::fifelse(
        .fixed_prices,
        "historical_climate_prices_fixed",
        "historical_climate_prices"
      )
    )
  )

  if (!fs::file_exists(.x)) {
    file_url <- data.table::fifelse(
      .fixed_prices,
      "https://daff.ent.sirsidynix.net.au/client/en_AU/search/asset/1036161/3",
      "https://daff.ent.sirsidynix.net.au/client/en_AU/search/asset/1036161/2"
    )
    .retry_download(
      url = file_url,
      dest = .x
    )
  }

  agfd_nc <- .read_ncdf_from_zip(zip_path = .x)

  yyyy <- sprintf("c%s", as.character(.yyyy))
  nm <- names(agfd_nc)
  if (is.null(nm)) {
    nm <- agfd_nc
  }
  agfd_nc <- agfd_nc[grepl(paste(yyyy, collapse = "|"), nm)]

  return(agfd_nc)
}

#' Unzip AGFD NetCDF files from ZIP
#'
#' @param zip_path Path to the ZIP file containing NetCDF files.
#' @returns A list of paths to the extracted NetCDF files.
#' @dev
.read_ncdf_from_zip <- function(zip_path) {
  # List files in the ZIP
  zip_contents <- utils::unzip(zip_path, list = TRUE)

  # Filter NetCDF files by pattern
  nc_files <- zip_contents$Name[grepl("//.nc$", zip_contents$Name)]

  # Extract only NetCDF files
  utils::unzip(zip_path, files = nc_files, exdir = tempdir())

  return(purrr::map(nc_files, function(f) {
    fs::path(tmpdir(), f)
  }))
}
