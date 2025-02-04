#' Read 'Australian Agricultural and Grazing Industries Survey' (AAGIS) region mapping files
#'
#' Download, cache and import the Australian Agricultural and Grazing
#'  Industries Survey (\acronym{AAGIS} regions geospatial shapefile. Upon
#'  import, the geometries  are automatically corrected to fix invalid
#'  geometries that are present in the original shapefile.
#'
#' @param cache Cache the \acronym{AAGIS} regions' geospatial file after
#' downloading using `tools::R_user_dir("read.abares", "cache")` to identify the
#' proper directory for storing user data in a cache for this package. Defaults
#' to `TRUE`, caching the files locally as a Geopackage. If `FALSE`, this
#' function uses `tempdir()` and the files are deleted upon closing of the
#' active \R session.
#'
#' @examplesIf interactive()
#' aagis <- read_aagis_regions()
#'
#' plot(aagis)
#'
#' @return An \CRANpkg{sf} object of the \acronym{AAGIS} regions.
#'
#' @family AGFD
#'
#' @references <https://www.agriculture.gov.au/abares/research-topics/surveys/farm-definitions-methods#regions>
#' @source <https://www.agriculture.gov.au/sites/default/files/documents/aagis_asgs16v1_g5a.shp_.zip>
#' @autoglobal
#' @export

read_aagis_regions <- function(cache = TRUE) {
  aagis <- .check_existing_aagis(cache)
  if (is.null(aagis)) {
    aagis <- .download_aagis_shp(cache)
  } else {
    return(aagis)
  }
}

#' Check for a pre-existing file before downloading
#'
#' Checks the user cache first, then `tempdir()` for the files before
#' returning a `NULL` value. If `cache == TRUE` and the file is not in the user
#' cache, but is in `tempdir()`, it is saved to the cache before being returned
#' in the current session.
#'
#' @return An \CRANpkg{sf} object of AAGIS regions.
#' @dev
#' @autoglobal

.check_existing_aagis <- function(cache) {
  aagis_gpkg <- file.path(.find_user_cache(), "aagis_regions_dir/aagis.gpkg")
  tmp_shp <- file.path(tempdir(), "aagis_asgs16v1_g5a.shp")

  if (file.exists(aagis_gpkg)) {
    return(sf::st_read(aagis_gpkg, quiet = TRUE))
  } else if (file.exists(tmp_shp)) {
    aagis_sf <- sf::st_read(tmp_shp, quiet = TRUE)
    # From checking the unzipped file, some geometries are invalid, this corrects
    aagis_sf <- sf::st_make_valid(aagis_sf)
    if (cache) {
      dir.create(dirname(aagis_gpkg), recursive = TRUE)
      sf::st_write(obj = aagis_sf, dsn = aagis_gpkg, quiet = TRUE)
    }
    return(aagis_sf)
  } else {
    return(invisible(NULL))
  }
}

#' Download the 'Australian Agricultural and Grazing Industries Survey' (AAGIS) regions shapefile
#'
#' Handles downloading, caching (if requested) and importing of AAGIS regions
#'  geospatial data.  The geometries are corrected for validity before returning
#'  to the user.
#'
#' @param cache `Boolean` Cache the \acronym{AAGIS} regions shape files after
#'  download using `tools::R_user_dir("read.abares")` to identify the proper
#'  directory for storing user data in a cache for this package. Defaults to
#'  `TRUE`, caching the files locally as a native \R object. If `FALSE`, this
#'  function uses `tempdir()` and the files are deleted upon closing of the \R
#'  session.
#'
#' @return An \CRANpkg{sf} object of AAGIS regions.
#' @dev
#' @autoglobal

.download_aagis_shp <- function(cache) {
  # if you make it this far, the cached file doesn't exist, so we need to
  # download it either to `tempdir()` and dispose or cache it
  cached_zip <- file.path(.find_user_cache(), "aagis_regions_dir/aagis.zip")
  tmp_zip <- file.path(file.path(tempdir(), "aagis.zip"))
  aagis_zip <- data.table::fifelse(cache, cached_zip, tmp_zip)
  aagis_regions_dir <- dirname(aagis_zip)
  aagis_gpkg <- file.path(aagis_regions_dir, "aagis.gpkg")

  # the user-cache may not exist if caching is enabled for the 1st time
  if (cache && !dir.exists(aagis_regions_dir)) {
    dir.create(aagis_regions_dir, recursive = TRUE)
  }

  .retry_download("https://www.agriculture.gov.au/sites/default/files/documents/aagis_asgs16v1_g5a.shp_.zip",
    .f = aagis_zip
  )

  withr::with_dir(
    aagis_regions_dir,
    utils::unzip(aagis_zip, exdir = aagis_regions_dir)
  )

  aagis_sf <- sf::read_sf(
    dsn = file.path(
      aagis_regions_dir,
      "aagis_asgs16v1_g5a.shp"
    ),
    quiet = TRUE
  )

  # From checking the unzipped file, some geometries are invalid, this corrects
  aagis_sf <- sf::st_make_valid(aagis_sf)

  if (cache) {
    sf::st_write(obj = aagis_sf, dsn = aagis_gpkg, quiet = TRUE)
    unlink(c(
      aagis_zip,
      file.path(aagis_regions_dir, "aagis_asgs16v1_g5a.*")
    ))
  }
  return(aagis_sf)
}
