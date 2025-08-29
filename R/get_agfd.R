#' Get ABARES' "Australian Gridded Farm Data" (AGFD)
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
#' @param .file A user specified path to a local zip file containing the data.
#'
#' @examples
#' # this will download the data and then return only 2020 and 2021 years' data
#' agfd <- .get_agfd(.fixed_prices = TRUE, .yyyy = 2020:2021, .file = NULL)
#'
#' agfd
#'
#' @returns A `list()` object, a list of NetCDF files containing the "Australian
#'   Gridded Farm Data".
#' @autoglobal
#' @dev

.get_agfd <- function(
  .fixed_prices,
  .yyyy,
  .file
) {
  if (is.null(.file)) {
    ds <- data.table::fifelse(
      .fixed_prices,
      "historical_climate_prices_fixed",
      "historical_climate_prices"
    )
    .file <- fs::path(tempdir(), sprintf("%s.zip", ds))

    file_url <- data.table::fifelse(
      .fixed_prices,
      "https://daff.ent.sirsidynix.net.au/client/en_AU/search/asset/1036161/3",
      "https://daff.ent.sirsidynix.net.au/client/en_AU/search/asset/1036161/2"
    )
    if (!fs::file_exists(.file)) {
      .retry_download(
        url = file_url,
        .f = .file
      )
      .unzip_file(.file)
    }
  } else if (!is.null(.file)) {
    ds <- fs::path_file(fs::path_ext_remove(.file))
    .unzip_file(.file)
  }

  agfd_nc <- fs::dir_ls(
    fs::path(fs::path_dir(.file), ds),
    full_names = TRUE,
    recurse = TRUE
  )

  yyyy <- sprintf("c%s", as.character(.yyyy))
  agfd_nc <- agfd_nc[grepl(paste(yyyy, collapse = "|"), names(agfd_nc))]
  return(agfd_nc)
}
