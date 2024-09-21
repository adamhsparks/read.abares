
#' Fetch Australian Gridded Farm Data
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
#' @return An `abares.agfd.nc.files` object, a `list` of NetCDF files containing
#'  the Australian Gridded Farm Data
#'
#' @export

get_agfd <- function(fixed_prices = TRUE, cache = TRUE) {
  download_file <- data.table::fifelse(cache,
                                  file.path(.find_user_cache(), "agfd.zip"),
                                  file.path(file.path(tempdir(), "agfd.zip")))

  # this is where the zip file is downloaded
  download_dir <- dirname(download_file)

  # this is where the zip files are unzipped in `agfd_zip_dir`
  agfd_nc_dir <- data.table::fifelse(
    fixed_prices,
    file.path(download_dir, "historical_climate_prices_fixed"),
    file.path(download_dir, "historical_climate_and_prices")
  )

  # only download if the files aren't already local
  if (!dir.exists(agfd_nc_dir)) {
    # if caching is enabled but the {abares} cache dir doesn't exist, create it
    if (cache) {
      dir.create(download_dir, recursive = TRUE)
    }

    url <- data.table::fifelse(
      fixed_prices,
      "https://daff.ent.sirsidynix.net.au/client/en_AU/search/asset/1036161/3",
      "https://daff.ent.sirsidynix.net.au/client/en_AU/search/asset/1036161/2"
    )

    curl::curl_download(url = url,
                        destfile = download_file,
                        quiet = FALSE)

    withr::with_dir(download_dir,
                    utils::unzip(download_file, exdir = download_dir))
    unlink(download_file)
  }

  agfd_nc <- list.files(agfd_nc_dir, full.names = TRUE)
  class(agfd_nc) <- union("abares.agfd.nc.files", class(agfd_nc))
  return(agfd_nc)
}

#' Prints abares.agfd.nc.files Object
#'
#' Custom [print()] method for `abares.agfd.nc.files` objects.
#'
#' @param x an `abares.agfd.nc.files` object
#' @param ... ignored
#' @export
#' @noRd
print.abares.agfd.nc.files <- function(x) {
  cli::cli_h1("\nLocally Available ABARES AGFD NetCDF Files\n")
  cli::cli_ul(basename(agfd_nc))
  cat("\n")
  invisible(x)
}
