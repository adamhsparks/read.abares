#' Download Soil Thickness for Australian Areas of Intensive Agriculture of Layer 1
#'
#' @param cache `Boolean` Cache the soil thickness data files after download
#' using `tools::R_user_dir()` to identify the proper directory for storing
#' user data in a cache for this package. Defaults to `TRUE`, caching the files
#' locally. If `FALSE`, this function uses `tempdir()` and the files are deleted
#' upon closing of the \R session.
#'
#' A custom `print` method is provided that will print the metadata associated
#'  with these data. Examples are provided for interacting with the metadata
#'  directly.
#'
#' @examplesIf interactive()
#' x <- get_soil_thickness()
#'
#' # View the metadata with pretty printing
#' x
#'
#' # Extract the metadata as an object in your R session and use it with
#' # {pander}, useful for Markdown files
#'
#' library(pander)
#' y <- x$metadata
#' pander(y)
#'
#' @return An `read.abares.soil.thickness` object, which is a named `list` with
#'  the file path of the resulting \acronym{ESRI} Grid file and text file of
#'  metadata
#'
#' @references <https://data.agriculture.gov.au/geonetwork/srv/eng/catalog.search#/metadata/faa9f157-8e17-4b23-b6a7-37eb7920ead6>
#'
#' @family soil_thickness
#'
#' @export


get_soil_thickness <- function(cache = TRUE) {
  soil_thick <- .check_existing_soil(cache)
  if (is.null(soil_thick)) {
    .download_soil_thickness(cache)
    soil_thick <- .create_soil_thickness_list(
      soil_dir = file.path(tempdir(), "soil_thickness_dir"))
    return(soil_thick)
  } else {
    return(soil_thick)
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
#' @return An `read.abares.soil.thickness` object, which is a named `list` with
#'  the file path of the resulting \acronym{ESRI} Grid file and text file of
#'  metadata
#' @noRd
#' @keywords Internal

.check_existing_soil <- function(cache) {

  cache_grd <- file.path(.find_user_cache(), "soil_thickness_dir/thpk_1")
  thpk_1_cache <- dirname(cache_grd)
  tmp_grd <- file.path(tempdir(), "soil_thickness_dir/thpk_1")

  if (file.exists(cache_grd)) {
    soil_dir <- dirname(cache_grd)
    return(.create_soil_thickness_list(soil_dir))
  } else if (file.exists(tmp_grd)) {
    soil_dir <- dirname(tmp_grd)
    soil_thickness <- .create_soil_thickness_list(soil_dir)
    if (cache && !dir.exists(thpk_1_cache)) {
      dir.create(thpk_1_cache, recursive = TRUE)
      file.copy(
        from = dirname(tmp_grd),
        to = thpk_1_cache,
        recursive = TRUE
      )
    }
    return(soil_thickness)
  } else {
    return(NULL)
  }
}

#' Create a Object of read.abares.soil.thickness.files
#'
#' @param dir File where files have been downloaded
#'
#' @return An `read.abares.soil.thickness` object, which is a named `list` with
#'  the file path of the resulting \acronym{ESRI} Grid file and text file of
#'  metadata
#' @noRd
#' @keywords Internal

.create_soil_thickness_list <- function(soil_dir) {

  metadata <- readtext::readtext(file.path(soil_dir,
                                           "ANZCW1202000149.txt"))
  soil_thickness <- list(
    "metadata" = metadata$text,
    "grid" = file.path(soil_dir, "thpk_1")
  )
  class(soil_thickness) <- union("read.abares.soil.thickness.files",
                                 class(soil_thickness))
  return(soil_thickness)
}

#' Downloads Soil Thickness Data if Not Located Locally
#' @param cache `Boolean` Cache the soil thickness data files after download
#' using `tools::R_user_dir()` to identify the proper directory for storing
#' user data in a cache for this package. Defaults to `TRUE`, caching the files
#' locally. If `FALSE`, this function uses `tempdir()` and the files are deleted
#' upon closing of the \R session.
#'
#' @return Nothing, called for its side-effects of downloading and unzipping
#'  files
#'
#' @noRd
#' @keywords Internal

.download_soil_thickness <- function(cache) {
  download_file <- data.table::fifelse(cache,
                                       file.path(.find_user_cache(), "soil_thick.zip"),
                                       file.path(file.path(tempdir(), "soil_thick.zip")))

  # this is where the zip file is downloaded
  download_dir <- dirname(download_file)

  # this is where the zip files are unzipped in `soil_thick_dir`
  soil_thick_adf_file <- file.path(download_dir, "soil_thickness_dir")

  # only download if the files aren't already local
  if (!file.exists(soil_thick_adf_file)) {
    # if caching is enabled but the {read.abares} cache dir doesn't exist, create it
    if (cache) {
      dir.create(dirname(soil_thick_adf_file), recursive = TRUE)
    }
    url <- "https://anrdl-integration-web-catalog-saxfirxkxt.s3-ap-southeast-2.amazonaws.com/warehouse/staiar9cl__059/staiar9cl__05911a01eg_geo___.zip"
    curl::curl_download(url = url,
                        destfile = download_file,
                        quiet = FALSE)

    withr::with_dir(download_dir,
                    utils::unzip(download_file,
                                 exdir = file.path(download_dir)))
    file.rename(
      file.path(download_dir, "staiar9cl__05911a01eg_geo___/"),
      file.path(download_dir, "soil_thickness_dir")
    )
    unlink(download_file)
  }
  return(invisible(NULL))
}

#' Prints read.abares.soil.thickness.files Object
#'
#' Custom [print()] method for `read.abares.soil.thickness.files` objects.
#'
#' @param x an `read.abares.soil.thickness.files` object
#' @param ... ignored
#' @export
#' @noRd
print.read.abares.soil.thickness.files <- function(x, ...) {
  cli::cli_h1("Soil Thickness for Australian areas of intensive agriculture of Layer 1 (A Horizon - top-soil)")
  cli::cli_h2("Dataset ANZLIC ID ANZCW1202000149")
  cli::cli_text(
    "Feature attribute definition Predicted average Thickness (mm) of soil layer
    1 in the 0.01 X 0.01 degree quadrat.\n\n
    {.strong Custodian:} CSIRO Land & Water\n\n
    {.strong Jurisdiction} Australia\n\n
    {.strong Short Description} The digital map data is provided in geographical
    coordinates based on the World Geodetic System 1984 (WGS84) datum. This
    raster data set has a grid resolution of 0.001 degrees  (approximately
    equivalent to 1.1 km).\n\n
    The data set is a product of the National Land and Water Resources Audit
    (NLWRA) as a base dataset.\n\n
    {.strong Data Type:} Spatial representation type RASTER\n\n
    {.strong Projection Map:} projection GEOGRAPHIC\n\n
    {.strong Datum:} WGS84\n\n
    {.strong Map Units:} DECIMAL DEGREES\n\n
    {.strong Scale:} Scale/ resolution 1:1 000 000\n\n
    Usage Purpose Estimates of soil depths are needed to calculate the amount of
    any soil constituent in either volume or mass terms (bulk density is also
    needed) - for example, the volume of water stored in the rooting zone
    potentially available for plant use, to assess total stores of soil carbon
    for Greenhouse inventory or to assess total stores of nutrients.\n\n
    Provide indications of probable Thickness soil layer 1 in agricultural areas
    where soil thickness testing has not been carried out.\n\n
    Use Limitation: This dataset is bound by the requirements set down by the
    National Land & Water Resources Audit")
  cli::cli_text("To see the full metadata, call
    {.fn print_soil_thickness_metadata} in your R session.")
  cat("\n")
  invisible(x)
}

#' Display Complete Metadata Associated with Soil Thickness Data in the \R Console
#'
#' Displays the complete set of metadata associated with the soil thickness
#'  data in your \R console. For including the metadata in documents or other
#'  methods outside of \R, see [get_soil_thickness] for an example using
#'  [pander::pander] to print the metadata.
#'
#'
#' @param x An `read.abares.soil.thickness.files` object
#'
#' @return Nothing, called for its side effects, it prints the complete
#'   metadata file to the \R console
#' @examplesIf interactive()
#' get_soil_thickness(cache = TRUE) |>
#' print_soil_thickness_metadata()
#'
#' @family soil_thickness
#'
#' @export

print_soil_thickness_metadata <- function(x) {

  .check_class(x = x, class = "read.abares.soil.thickness.files")
  loc <- stringr::str_locate(x$metadata, "Custodian")
  metadata <- stringr::str_sub(x$metadata, loc[, "start"] - 1, nchar(x$metadata))
  cli::cli_h1("Soil Thickness for Australian areas of intensive agriculture of Layer 1 (A Horizon - top-soil)\n")
  cli::cli_h2("Dataset ANZLIC ID ANZCW1202000149")
  cli::cli_text(x$metadata)
  cat("\n")
  invisible(x)
}
