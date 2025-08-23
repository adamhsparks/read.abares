#' Read "Australian Agricultural and Grazing Industries Survey" (AAGIS) Region Mapping Files
#'
#' Download import the "Australian Agricultural and Grazing Industries Survey"
#'   (\acronym{AAGIS}) regions geospatial shapefile.
#'
#'  @note Upon import a few operations are carried out,
#'  * the geometries are automatically corrected to fix invalid geometries that
#'  are present in the original shapefile,
#'  * column names are set to start with an upper-case letter,
#'  * the original column named, "name", is set to "AAGIS_region" to align with
#'  column names that the [data.table::data.table()] provided by
#'  [read_historical_regional_estimates()] to allow for easier merging of data
#'  for mapping, and,
#'  * a new column, "State" is added to be used for mapping state estimates with
#'  data for mapping state historical estimate values found in the
#'  [data.table::data.table()] from [read_historical_state_estimates()].
#'
#' @inheritParams read_agfd_dt
#'
#' @examplesIf interactive()
#' aagis <- read_aagis_regions()
#'
#' plot(aagis)
#'
#' @returns An \CRANpkg{sf} object of the \acronym{AAGIS} regions.
#'
#' @family AAGIS
#'
#' @references <https://www.agriculture.gov.au/abares/research-topics/surveys/farm-definitions-methods#regions>
#' @source <https://www.agriculture.gov.au/sites/default/files/documents/aagis_asgs16v1_g5a.shp_.zip>
#' @autoglobal
#' @export

read_aagis_regions <- function(files = NULL) {
  .cache <- getOption("read.abares.cache", default = FALSE)

  if (
    getOption("read.abares.verbosity") == "quiet" ||
      getOption("read.abares.verbosity") == "minimal"
  ) {
    talktalk <- FALSE
  } else {
    talktalk <- TRUE
  }

  aagis_regions_cache <- fs::path(.find_user_cache(), "aagis_regions_dir")
  if (fs::dir_exists(aagis_regions_cache)) {
    return(sf::st_read(
      fs::path(
        aagis_regions_cache,
        "aagis.gpkg"
      ),
      quiet = talktalk
    ))
  } else {
    return(.download_aagis_shp(.cache, .talktalk = talktalk))
  }
}

#' Download the "Australian Agricultural and Grazing Industries Survey" (AAGIS) Regions Shapefile
#'
#' Handles downloading and importing of AAGIS regions geospatial data.  The
#'  geometries are corrected for validity before returning to the user.
#'
#' @param .talktalk Boolean, how verbose should the function be?
#'
#' @returns An \CRANpkg{sf} object of AAGIS regions.
#' @dev
#' @autoglobal

.download_aagis_shp <- function(.talktalk) {
  download_file <- fs::path(tempdir(), "aagis.zip")
  tempdir_aagis_dir <- fs::path(tempdir(), "aagis_regions_dir")

  .retry_download(
    "https://www.agriculture.gov.au/sites/default/files/documents/aagis_asgs16v1_g5a.shp_.zip",
    .f = download_file
  )

  withr::with_dir(
    tempdir(),
    utils::unzip(download_file, exdir = tempdir_aagis_dir)
  )

  aagis_sf <- sf::st_read(
    dsn = fs::path(
      tempdir_aagis_dir,
      "aagis_asgs16v1_g5a.shp"
    ),
    quiet = .talktalk
  )

  # From checking the unzipped file, some geometries are invalid, this corrects
  aagis_sf <- sf::st_make_valid(aagis_sf)
  aagis_sf["aagis"] <- NULL # drop an identical column with class
  # pull the state codes out and create a new state column
  aagis_sf$State <- gsub(" .*$", "", aagis_sf$name)
  names(aagis_sf)[names(aagis_sf) == "name"] <- "ABARES_region"
  names(aagis_sf)[names(aagis_sf) == "class"] <- "Class"
  names(aagis_sf)[names(aagis_sf) == "zone"] <- "Zone"

  fs::file_delete(download_file)
  return(aagis_sf)
}
