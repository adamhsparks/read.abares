#' Get AAGIS Region Mapping Files
#'
#' @param cache `Boolean` Cache the \acronym{AAGIS} regions shape files after
#'  download using `tools::R_user_dir()` to identify the proper directory for
#'  storing user data in a cache for this package. Defaults to `TRUE`, caching
#'  the files locally as a native \R object. If `FALSE`, this function uses
#'  `tempdir()` and the files are deleted upon closing of the \R session.
#'
#' @examplesIf interactive()
#' aagis <- get_aagis_regions()
#'
#' plot(aagis)
#'
#' @return An \CRANpkg{sf} object of the \acronym{AAGIS} regions
#'
#' @family AGFD
#'
#' @references <https://www.agriculture.gov.au/abares/research-topics/surveys/farm-definitions-methods#regions>
#' @autoglobal
#' @export

get_aagis_regions <- function(cache = TRUE) {
  aagis_sf <- .check_existing_aagis(cache)
  if (is.null(aagis_sf)) {
    aagis_sf <- .download_aagis_shp(cache)
  } else {
    return(aagis_sf)
  }
}

#' Check for Pre-existing File Before Downloading
#'
#' Checks the user cache first, then `tempdir()` for the files before
#' returning a `NULL` value. If `cache == TRUE` and the file is not in the user
#' cache, but is in `tempdir()`, it is saved to the cache before being returned
#' in the current session.
#'
#'
#' @return An \cranpkg{sf} object of AAGIS regions
#' @noRd
#' @autoglobal
#' @keywords Internal

.check_existing_aagis <- function(cache) {
  aagis_rds <- file.path(.find_user_cache(), "aagis_regions_dir/aagis.rds")
  tmp_shp <- file.path(tempdir(), "aagis_asgs16v1_g5a.shp")

  if (file.exists(aagis_rds)) {
    return(readRDS(aagis_rds))
  } else if (file.exists(tmp_shp)) {
    aagis_sf <- sf::st_read(tmp_shp, quiet = TRUE)
    if (cache) {
      dir.create(dirname(aagis_rds), recursive = TRUE)
      saveRDS(aagis_sf, file = aagis_rds)
    }
    return(aagis_sf)
  } else {
    return(NULL)
  }
}

#' Download the AAGIS Regions Shapefile
#'
#' Handles downloading and caching (if requested) of AAGIS regions geospatial
#' data.
#'
#' @param cache `Boolean` Cache the \acronym{AAGIS} regions shape files after
#'  download using `tools::R_user_dir()` to identify the proper directory for
#'  storing user data in a cache for this package. Defaults to `TRUE`, caching
#'  the files locally as a native \R object. If `FALSE`, this function uses
#'  `tempdir()` and the files are deleted upon closing of the \R session.
#'
#' @return An \cranpkg{sf} object of AAGIS regions
#' @noRd
#' @autoglobal
#' @keywords Internal
.download_aagis_shp <- function(cache) {
  # if you make it this far, the cached file doesn't exist, so we need to
  # download it either to `tempdir()` and dispose or cache it
  cached_zip <- file.path(.find_user_cache(), "aagis_regions_dir/aagis.zip")
  tmp_zip <- file.path(file.path(tempdir(), "aagis.zip"))
  aagis_zip <- data.table::fifelse(cache, cached_zip, tmp_zip)
  aagis_regions_dir <- dirname(aagis_zip)
  aagis_rds <- file.path(aagis_regions_dir, "aagis.rds")

  # the user-cache may not exist if caching is enabled for the 1st time
  if (cache && !dir.exists(aagis_regions_dir)) {
    dir.create(aagis_regions_dir, recursive = TRUE)
  }

  .retry_download("https://www.agriculture.gov.au/sites/default/files/documents/aagis_asgs16v1_g5a.shp_.zip",
                  .f = aagis_zip)

  withr::with_dir(aagis_regions_dir,
                  utils::unzip(aagis_zip, exdir = aagis_regions_dir))

  aagis_sf <- sf::read_sf(dsn = file.path(aagis_regions_dir,
                                          "aagis_asgs16v1_g5a.shp"))

  if (cache) {
    saveRDS(aagis_sf, file = aagis_rds)
    unlink(c(
      aagis_zip,
      file.path(aagis_regions_dir, "aagis_asgs16v1_g5a.*")
    ))
  }
  return(aagis_sf)
}
