#' Get soil thickness for 'Australian Areas of Intensive Agriculture of Layer 1' for local use
#'
#' @param cache Caches the soil thickness data files after download
#' using `tools::R_user_dir()` to identify the proper directory for storing
#' user data in a cache for this package. Defaults to `TRUE`, caching the files
#' locally. If `FALSE`, this function uses `tempdir()` and the files are deleted
#' upon closing of the active \R session.
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
#' @returns A `read.abares.soil.thickness` object, which is a named `list` with
#'  the fs::path of the resulting Esri Grid file and text file of
#'  metadata.
#'
#' @references <https://data.agriculture.gov.au/geonetwork/srv/eng/catalog.search#/metadata/faa9f157-8e17-4b23-b6a7-37eb7920ead6>
#' @source <https://anrdl-integration-web-catalog-saxfirxkxt.s3-ap-southeast-2.amazonaws.com/warehouse/staiar9cl__059/staiar9cl__05911a01eg_geo___.zip>
#' @autoglobal
#' @family soil_thickness
#' @export

get_soil_thickness <- function(cache = TRUE) {
  soil_cache <- fs::path(.find_user_cache(), "soil_thickness_dir")
  if (fs::dir_exists(soil_cache)) {
    return(.create_soil_thickness_list(soil_cache))
  } else {
    download_file <- data.table::fifelse(
      cache,
      fs::path(.find_user_cache(), "soil_thick.zip"),
      fs::path(tempdir(), "soil_thick.zip")
    )

    # this is where the zip file is downloaded
    download_dir <- fs::path_dir(download_file)
    .download_soil_thickness(cache, download_file, download_dir)
    .create_soil_thickness_list(
      soil_dir = fs::path(download_dir, "soil_thickness_dir")
    )
  }
}

#' Create a object of read.abares.soil.thickness.files
#'
#' @param soil_dir File where files have been downloaded.
#'
#' @returns A `read.abares.soil.thickness` object, which is a named `list` with
#'  the fs::path of the resulting Esri Grid file and text file of
#'  metadata.
#' @dev

.create_soil_thickness_list <- function(soil_dir) {
  soil_thickness <- list(
    "metadata" = readtext::readtext(fs::path(
      soil_dir,
      "ANZCW1202000149.txt"
    ))$text,
    "grid" = fs::path(soil_dir, "thpk_1")
  )
  class(soil_thickness) <- union(
    "read.abares.soil.thickness.files",
    class(soil_thickness)
  )
  return(soil_thickness)
}

#' Downloads soil thickness data if not already found locally
#' @param cache `Boolean` Cache the soil thickness data files after download
#' using `tools::R_user_dir()` to identify the proper directory for storing
#' user data in a cache for this package. Defaults to `TRUE`, caching the files
#' locally. If `FALSE`, this function uses `tempdir()` and the files are deleted
#' upon closing of the active \R session.
#'
#' @returns Nothing, called for its side-effects of downloading and unzipping
#'  files.
#'
#' @dev

.download_soil_thickness <- function(cache, download_file, download_dir) {
  # this is where the zip files are unzipped in `soil_thick_dir`
  soil_thick_adf_file <- fs::path(download_dir, "soil_thickness_dir/thpk_1")

  # only download if the files aren't already local
  if (!fs::file_exists(soil_thick_adf_file)) {
    # if caching is enabled but the {read.abares} cache dir doesn't exist, create it
    if (cache) {
      fs::dir_create(fs::path_dir(soil_thick_adf_file), recurse = TRUE)
    }
    .retry_download(
      "https://anrdl-integration-web-catalog-saxfirxkxt.s3-ap-southeast-2.amazonaws.com/warehouse/staiar9cl__059/staiar9cl__05911a01eg_geo___.zip",
      .f = download_file
    )

    withr::with_dir(
      download_dir,
      utils::unzip(download_file, exdir = fs::path(download_dir))
    )
    file.rename(
      fs::path(download_dir, "staiar9cl__05911a01eg_geo___/"),
      fs::path(download_dir, "soil_thickness_dir")
    )
    fs::file_delete(download_file)
  }
  return(invisible(NULL))
}

#' Prints read.abares.soil.thickness.files object
#'
#' Custom [print] method for `read.abares.soil.thickness.files` objects.
#'
#' @param x a `read.abares.soil.thickness.files` object.
#' @param ... ignored.
#' @export
#' @noRd
print.read.abares.soil.thickness.files <- function(x, ...) {
  cli::cli_h1(
    "Soil Thickness for Australian areas of intensive agriculture of Layer 1 (A Horizon - top-soil)"
  )
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
    for greenhouse inventory or to assess total stores of nutrients.\n\n
    Provide indications of probable thickness soil layer 1 in agricultural areas
    where soil thickness testing has not been carried out.\n\n
    Use Limitation: This dataset is bound by the requirements set down by the
    National Land & Water Resources Audit"
  )
  cli::cli_text(
    "To see the full metadata, call
    {.fn print_soil_thickness_metadata} on a soil thickness object in your R
                session."
  )
  cli::cat_line()
  invisible(x)
}

#' Display complete metadata associated with soil thickness data
#'
#' Displays the complete set of metadata associated with the soil thickness
#'  data in your \R console. For including the metadata in documents or other
#'  methods outside of \R, see [get_soil_thickness] for an example using
#'  [pander::pander] to print the metadata.
#'
#'
#' @param x A `read.abares.soil.thickness.files` object.
#'
#' @returns Nothing, called for its side effects, it prints the complete
#'   metadata file to the \R console.
#' @examplesIf interactive()
#' get_soil_thickness(cache = TRUE) |>
#'   print_soil_thickness_metadata()
#'
#' @family soil_thickness
#'
#' @export

print_soil_thickness_metadata <- function(x) {
  .check_class(x = x, class = "read.abares.soil.thickness.files")
  loc <- stringr::str_locate(x$metadata, "Custodian")
  metadata <- stringr::str_sub(
    x$metadata,
    loc[, "start"] - 1,
    nchar(x$metadata)
  )
  cli::cli_h1(
    "Soil Thickness for Australian areas of intensive agriculture of Layer 1 (A Horizon - top-soil)\n"
  )
  cli::cli_h2("Dataset ANZLIC ID ANZCW1202000149")
  cli::cli_text(x$metadata)
  cli::cat_line()
  invisible(x)
}
