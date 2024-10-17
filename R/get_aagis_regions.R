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
#' plot(aagis)
#'
#' @return An \CRANpkg{sf} object of the \acronym{AAGIS} regions
#'
#' @references <https://www.agriculture.gov.au/abares/research-topics/surveys/farm-definitions-methods#regions>
#'
#' @export

get_aagis_regions <- function(cache = TRUE) {
  aagis_rds <- file.path(.find_user_cache(), "aagis_regions_dir/aagis.rds")

  if (exists(aagis_rds)) {
    readRDS(aagis_rds)
  }

  tmp_shp <- file.path(tempdir(), "aagis_asgs16v1_g5a.shp")
  if (exists(tmp_shp)) {
    sf::sf_read(tmp_shp)
  }

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

  url <-
    "https://www.agriculture.gov.au/sites/default/files/documents/aagis_asgs16v1_g5a.shp_.zip"

  h <- curl::new_handle()
  curl::handle_setopt(
    handle = h,
    TCP_KEEPALIVE = 200000,
    CONNECTTIMEOUT = 90,
    http_version = 2
  )
  curl::curl_download(url = url,
                      destfile = aagis_zip,
                      quiet = FALSE,
                      handle = h)

  withr::with_dir(aagis_regions_dir,
                  utils::unzip(aagis_zip, exdir = aagis_regions_dir))

  aagis_sf <- sf::read_sf(
    dsn = file.path(aagis_regions_dir, "aagis_asgs16v1_g5a.shp"))

  if (cache) {
    saveRDS(aagis_sf, file = aagis_rds)
    unlink(c(
      aagis_zip,
      file.path(aagis_regions_dir, "aagis_asgs16v1_g5a.*")
    ))
  }
  return(aagis_sf)
}
