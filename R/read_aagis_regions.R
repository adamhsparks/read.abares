#' Read ABARES' "Australian Agricultural and Grazing Industries Survey" (AAGIS) Region Mapping Files
#'
#' Download import the "Australian Agricultural and Grazing Industries Survey"
#'   (\acronym{AAGIS}) regions geospatial shapefile.
#'
#' @param x A file path providing the file with the data to be imported. The
#'  file is assumed to be unarchived (*i.e.*, still zipped). This function does
#'  not provide any checking whether this function is the proper function for
#'  the provided file.  Defaults to `NULL`, assuming that the file will be
#'  downloaded in the active \R session.
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
        url = "https://www.agriculture.gov.au/sites/default/files/documents/aagis_asgs16v1_g5a.shp_.zip",
        dest = x
      )
    }
  }
  # Create an isolated extraction dir under tempdir()
  extract_dir <- fs::path(
    tempdir(),
    paste0("aagis_extract_", as.integer(Sys.time()), "_", sample.int(1e6, 1))
  )
  fs::dir_create(extract_dir)

  # Unzip *only* into our isolated directory
  utils::unzip(x, exdir = extract_dir)

  on.exit(
    {
      if (fs::file_exists(x)) fs::file_delete(x)
    },
    add = TRUE
  )

  # Search *only* for the exact expected shapefile
  shp_paths <- fs::dir_ls(
    fs::path_dir(x),
    regexp = "aagis_asgs16v1_g5a[.]shp$",
    recurse = TRUE,
    type = "file"
  )

  aagis_sf <- sf::st_read(
    dsn = shp_paths[[1]],
    quiet = !(getOption("read.abares.verbosity") %in% c("quiet", "minimal"))
  )

  aagis_sf <- sf::st_make_valid(aagis_sf)
  aagis_sf["aagis"] <- NULL
  aagis_sf$State <- gsub(" .*$", "", aagis_sf$name)
  names(aagis_sf)[names(aagis_sf) == "name"] <- "ABARES_region"
  names(aagis_sf)[names(aagis_sf) == "class"] <- "Class"
  names(aagis_sf)[names(aagis_sf) == "zone"] <- "Zone"

  fs::file_delete(x)
  aagis_sf
}
