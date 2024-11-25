
#' Fetch Australian Gridded Farm Data
#'
#' @description
#' A short description...
#'
#' From the [ABARES website](https://www.agriculture.gov.au/abares/research-topics/surveys/farm-survey-data/australian-gridded-farm-data):
#' \dQuote{The Australian Gridded Farm Data (\acronym{AGFD}) are a set of national
#'  scale maps containing simulated data on historical broadacre farm business
#'  outcomes including farm profitability on an 0.05-degree (approximately 5 km)
#'  grid.\cr
#'  These data have been produced by \acronym{ABARES} as part of the ongoing
#'  Australian Agricultural Drought Indicator (\acronym{AADI}) project
#'  (previously known as the Drought Early Warning System Project) and were
#'  derived using \acronym{ABARES}
#'  [*farmpredict*](https://www.agriculture.gov.au/abares/research-topics/climate/drought/farmpredict)
#'  model, which in turn is based on ABARES Agricultural and Grazing Industries
#'  Survey (\acronym{AAGIS}) data.\cr
#'  These maps provide estimates of farm business profit, revenue, costs and
#'  production by location (grid cell) and year for the period 1990-91 to
#'  2022-23. The data do not include actual observed outcomes but rather model
#'  predicted outcomes for representative or \sQuote{typical} broadacre farm
#'  businesses at each location considering likely farm characteristics and
#'  prevailing weather conditions and commodity prices.}\cr
#'  -- \acronym{ABARES}, 2024-11-25
#'
#' Both sets of data are large in file size, *i.e.*, >1GB, and will require time
#'   to download.
#'
#' @param fixed_prices `Boolean` Download historical climate and prices or
#'  historical climate and fixed prices as described in  (Hughes *et al.* 2022).
#'  Defaults to `TRUE` and downloads the data with historical climate and fixed
#'  prices \dQuote{to isolate the effects of climate variability on financial
#'  incomes for broadacre farm businesses} (ABARES 2024). Using `TRUE` will
#'  download simulations where global output and input price indexes are fixed
#'  at values from the most recently completed financial year.
#' @param cache `Boolean` Cache the Australian Gridded Farm Data files after
#'  download using [tools::R_user_dir] to identify the proper directory for
#'  storing user data in a cache for this package. Defaults to `TRUE`, caching
#'  the files locally. If `FALSE`, this function uses `tempdir()` and the files
#'  are deleted upon closing of the \R session.
#'
#' @references
#' *Australian gridded farm data*, Australian Bureau of Agricultural and
#'  Resource Economics and Sciences, Canberra, July 2024, DOI:
#'  [10.25814/7n6z-ev41](https://doi.org/10.25814/7n6z-ev41).
#'  [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/legalcode).
#'
#' N. Hughes, W.Y. Soh, C. Boult, K. Lawson, *Defining drought from
#'  the perspective of Australian farmers*, Climate Risk Management, Volume 35,
#'  2022, 100420, ISSN 2212-0963, DOI:
#'  [10.1016/j.crm.2022.100420](https://doi.org/10.1016/j.crm.2022.100420).
#'
#' @examplesIf interactive()
#' get_agfd()
#'
#' @return A `read.abares.agfd.nc.files` object, a `list` of NetCDF files
#'  containing the Australian Gridded Farm Data
#' @family AGFD
#' @autoglobal
#' @export

get_agfd <- function(fixed_prices = TRUE, cache = TRUE) {
  download_file <- data.table::fifelse(cache,
                                  file.path(.find_user_cache(), "agfd.zip"),
                                  file.path(file.path(tempdir(), "agfd.zip")))

  # this is where the zip file is downloaded
  download_dir <- dirname(download_file)

  # this is where the zip files are unzipped and read from
  agfd_nc_dir <- data.table::fifelse(
    fixed_prices,
    file.path(download_dir, "historical_climate_prices_fixed"),
    file.path(download_dir, "historical_climate_and_prices")
  )

  # only download if the files aren't already local
  if (!dir.exists(agfd_nc_dir)) {
    # if caching is enabled but the {read.abares} cache dir doesn't exist, create it
    if (cache) {
      dir.create(download_dir, recursive = TRUE)
    }

    url <- data.table::fifelse(
      fixed_prices,
      "https://daff.ent.sirsidynix.net.au/client/en_AU/search/asset/1036161/3",
      "https://daff.ent.sirsidynix.net.au/client/en_AU/search/asset/1036161/2"
    )

    .retry_download(url = url,
                    .f = download_file)

    withr::with_dir(download_dir,
                    utils::unzip(zipfile = download_file,
                                 exdir = download_dir))
    unlink(download_file)
  }

  agfd_nc <- list.files(agfd_nc_dir, full.names = TRUE)
  class(agfd_nc) <- union("read.abares.agfd.nc.files", class(agfd_nc))
  return(agfd_nc)
}

#' Prints read.abares.agfd.nc.files Objects
#'
#' Custom [print()] method for `read.abares.agfd.nc.files` objects.
#'
#' @param x a `read.abares.agfd.nc.files` object
#' @param ... ignored
#' @export
#' @autoglobal
#' @noRd
print.read.abares.agfd.nc.files <- function(x, ...) {
  cli::cli_h1("\nLocally Available ABARES AGFD NetCDF Files\n")
  cli::cli_ul(basename(x))
  cat("\n")
  invisible(x)
}
