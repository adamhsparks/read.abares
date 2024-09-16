#' Get AAGIS Region Mapping Files
#'
#' @param cache `Boolean` Cache the \acronym{AAGIS} regions shape files after
#'  download using [tools::R_user_dir] to identify the proper directory for
#'  storing user data in a cache for this package. Defaults to `TRUE`, caching
#'  the files locally as a native \R object. If `FALSE`, this function uses
#'  `tempdir()` and the files are deleted upon closing of the \R session.
#'
#' @examplesIf interactive()
#' aagis <- get_aagis_regions()
#' plot(aagis)
#'
#' @return An \CRANpkg{sf} object of the \acronym{AAGIS} regions
#'
#' @export

get_aagis_regions <- function(cache = TRUE) {
  aagis_zip <- data.table::fifelse(
    cache,
    file.path(.find_user_cache(), "aagis_regions_dir/aagis.zip"),
    file.path(file.path(tempdir(), "aagis.zip"))
  )
  aagis_regions_dir <- dirname(aagis_zip)
  aagis_rds <- file.path(aagis_regions_dir, "aagis.rds")

  # only download if the files aren't already local
  if (!file.exists(aagis_regions_dir)) {
    # if caching is enabled but the {agfd} cache dir doesn't exist, create it
    if (cache && !dir.exists(.find_user_cache())) {
      dir.create(.find_user_cache(), recursive = TRUE)
    }
    if (!dir.exists(aagis_regions_dir)) {
      dir.create(aagis_regions_dir, recursive = TRUE)
    }

    url <-
      "https://www.agriculture.gov.au/sites/default/files/documents/aagis_asgs16v1_g5a.shp_.zip"

    curl::curl_download(
      url = url,
      destfile = aagis_zip,
      quiet = FALSE
    )

    withr::with_dir(
      aagis_regions_dir,
      utils::untar(aagis_zip, exdir = aagis_regions_dir)
    )

    aagis_sf <- sf::read_sf(dsn = file.path(
      aagis_regions_dir,
      "aagis_asgs16v1_g5a.shp"
    ))

    if (cache) {
      saveRDS(aagis_sf, file = aagis_rds)
      unlink(c(aagis_zip, file.path(aagis_regions_dir, "aagis_asgs16v1_g5a.*")))
    }
    return(aagis_sf)
  } else {
    readRDS(aagis_rds)
  }
}
