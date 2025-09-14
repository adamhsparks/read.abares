#' Read ABARES' "Australian Agricultural and Grazing Industries Survey" (AAGIS) Region Mapping Files
#'
#' Download import the "Australian Agricultural and Grazing Industries Survey"
#'   (\acronym{AAGIS}) regions geospatial shapefile.
#'
#' @param x A file path providing the file with the data to be imported. The
#'  file is assumed to be unarchived locally. This function does not provide any
#'  checking whether this function is the proper function for the provided file.
#'  Defaults to `NULL`, assuming that the file will be downloaded in the active
#'  \R session.
#'
#' @note Upon import a few operations are carried out,
#'  * the geometries are automatically corrected to fix invalid geometries that
#'  are present in the original shapefile,
#'  * column names are set to start with a upper-case letter,
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

read_aagis_regions <- function(x = NULL) {
  if (is.null(x)) {
    x <- fs::path(tempdir(), "aagis.zip")
    if (!fs::file_exists(x)) {
      .retry_download(
        "https://www.agriculture.gov.au/sites/default/files/documents/aagis_asgs16v1_g5a.shp_.zip",
        .f = x
      )
      .unzip_file(x)
    }
  } else {
    .unzip_file(x)
  }
  aagis_sf <- sf::st_read(
    dsn = fs::path(
      fs::path_dir(x),
      "aagis/aagis_asgs16v1_g5a.shp"
    ),
    quiet = !(getOption("read.abares.verbosity") %in% c("quiet", "minimal"))
  )

  # From checking the unzipped file, some geometries are invalid, this corrects
  aagis_sf <- sf::st_make_valid(aagis_sf)
  aagis_sf["aagis"] <- NULL # drop an identical column with class
  # pull the state codes out and create a new state column
  aagis_sf$State <- gsub(" .*$", "", aagis_sf$name)
  names(aagis_sf)[names(aagis_sf) == "name"] <- "ABARES_region"
  names(aagis_sf)[names(aagis_sf) == "class"] <- "Class"
  names(aagis_sf)[names(aagis_sf) == "zone"] <- "Zone"

  fs::file_delete(x)
  return(aagis_sf)
}
