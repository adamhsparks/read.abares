#' Fetch Australian Gridded Farm Data
#'
#' @param fixed `Boolean` Download fixed historical climate prices?  Defaults
#'  to `FALSE`, downloads the data from ABARES \sQuote{farmpredict} (Hughes
#'  *et al.* 2022). Using `TRUE` will download simulations where global output
#'  and input price indexes are fixed at values from the most recently completed
#'  financial year.
#' @param cache `Boolean` Cache the Australian Gridded Farm Data files after
#'  download using [tools::R_user_dir] to identify the proper directory for
#'  storing user data in a cache for this package.
#'
#' @references N. Hughes, W.Y. Soh, C. Boult, K. Lawson, Defining drought from
#'  the perspective of Australian farmers, Climate Risk Management, Volume 35,
#'  2022, 100420, ISSN 2212-0963, DOI
#'  [10.1016/j.crm.2022.100420](https://doi.org/10.1016/j.crm.2022.100420).
#'
#' @examplesIf interactive()
#' get_agfd()
#'
#' @return A character `vector` of NetCDF files containing the Australian
#'  Gridded Farm Data with fullnames.
#'
#' @export

get_agfd <- function(fixed = FALSE, cache = FALSE) {
  agfd_zip <- data.table::fifelse(cache,
                                  file.path(
                                    tools::R_user_dir(package = "agfd", which = "cache"),
                                    "agfd.zip"
                                  ),
                                  file.path(file.path(tempdir(), "agfd.zip")))

  # this is where the zip file is downloaded
  agfd_zip_dir <- dirname(agfd_zip)

  # this is where the zip files are unzipped in `agfd_zip_dir`
  agfd_nc_dir <- data.table::fifelse(
    fixed,
    file.path(agfd_zip_dir, "historical_climate_prices_fixed"),
    file.path(agfd_zip_dir, "historical_climate_and_prices")
  )

  # only download if the files aren't already local
  if (!file.exists(agfd_nc_dir)) {
    # if caching is enabled but the {agfd} cache dir doesn't exist, create it
    if (cache) {
      dir.create(agfd_zip_dir)
    }

    url <- data.table::fifelse(
      fixed,
      "https://daff.ent.sirsidynix.net.au/client/en_AU/search/asset/1036161/3",
      "https://daff.ent.sirsidynix.net.au/client/en_AU/search/asset/1036161/2"
    )

    curl::curl_download(url = url,
                        destfile = agfd_zip,
                        quiet = FALSE)

    withr::with_dir(agfd_zip_dir, utils::untar(agfd_zip, exdir = agfd_zip_dir))
    unlink(agfd_zip)
  }

  list.files(agfd_nc_dir, full.names = TRUE)
}
