#' Get topsoil thickness for 'Australian Areas of Intensive Agriculture of Layer 1' for local use
#'
#' Fetches topsoil thickness data and associated metadata from \acronym{ABARES}.
#'
#' @inheritParams get_agfd
#' @inheritSection get_agfd Caching
#'
#' @note
#' A custom `print()` method is provided that will print the metadata associated
#'  with these data. Examples are provided for interacting with the metadata
#'  directly.
#'
#' @examplesIf interactive()
#' x <- get_topsoil_thickness()
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
#' @returns A `read.abares.topsoil.thickness` object, which is a named `list()`
#'  with the [fs::path_file()] of the data file and text file of metadata.
#'
#' @references <https://data.agriculture.gov.au/geonetwork/srv/eng/catalog.search#/metadata/faa9f157-8e17-4b23-b6a7-37eb7920ead6>
#' @source <https://anrdl-integration-web-catalog-saxfirxkxt.s3-ap-southeast-2.amazonaws.com/warehouse/staiar9cl__059/staiar9cl__05911a01eg_geo___.zip>
#' @autoglobal
#' @family topsoil thickness
#' @export

get_topsoil_thickness <- function(
  cache = getOption("read.abares.cache")
) {
  if (missing(cache)) {
    cache <- getOption("read.abares.cache", default = FALSE)
  }

  topsoil_thickness_cache <- fs::path(
    .find_user_cache(),
    "topsoil_thickness_dir"
  )
  if (fs::dir_exists(topsoil_thickness_cache)) {
    return(.create_topsoil_thickness_list(topsoil_thickness_cache))
  } else {
    return(.create_topsoil_thickness_list(.download_topsoil_thickness(cache)))
  }
}

#' Create a object of read.abares.topsoil.thickness.files
#'
#' @param dir File where files have been stored.
#'
#' @returns A `read.abares.soil.thickness` object, which is a named `list` with
#' the [fs::path_file] of the resulting GTiff file and text file of metadata.
#' @dev

.create_topsoil_thickness_list <- function(topsoil_thickness_cache) {
  metadata <- readtext::readtext(fs::path(
    topsoil_thickness_cache,
    "ANZCW1202000149.txt"
  ))
  topsoil_thickness <- list(
    "metadata" = metadata$text,
    "GTiff" = fs::path(topsoil_thickness_cache, "thpk_1.tif")
  )
  class(topsoil_thickness) <- union(
    "read.abares.topsoil.thickness.files",
    class(topsoil_thickness)
  )
  return(topsoil_thickness)
}

#' Downloads Topsoil thickness data if not already found locally
#' @param cache `Boolean` Cache the soil thickness data files after download
#' using `tools::R_user_dir()` to identify the proper directory for storing
#' user data in a cache for this package. Defaults to `FALSE`.
#' locally. If `FALSE`, this function uses `tempdir()` and the files are deleted
#' upon closing of the active \R session.
#'
#' @returns An [fs::path()] of the resulting data and text file of metadata,
#'  with metadata and data files being created in the user's cache if requested.
#'
#' @dev

.download_topsoil_thickness <- function(cache) {
  download_file <- fs::path(tempdir(), "topsoil_thick.zip")
  tempdir_topsoil_dir <- fs::path(tempdir(), "staiar9cl__05911a01eg_geo___/")
  cache_topsoil_dir <- fs::path(.find_user_cache(), "topsoil_thickness_dir")

  # only download if the files aren't already local
  if (!fs::dir_exists(tempdir_topsoil_dir)) {
    .retry_download(
      "https://anrdl-integration-web-catalog-saxfirxkxt.s3-ap-southeast-2.amazonaws.com/warehouse/staiar9cl__059/staiar9cl__05911a01eg_geo___.zip",
      .f = download_file
    )

    withr::with_dir(
      tempdir(),
      utils::unzip(download_file, exdir = tempdir())
    )
    fs::file_delete(download_file)
  }

  # now move the files to the cache if caching is requested
  if (cache) {
    if (!fs::dir_exists(cache_topsoil_dir)) {
      fs::dir_create(cache_topsoil_dir, recurse = TRUE)
    }
    x <- terra::rast(fs::path(tempdir_topsoil_dir, "thpk_1"))
    x <- terra::init(x, x[]) # remove RAT legend

    terra::writeRaster(
      x,
      filename = fs::path(cache_topsoil_dir, "thpk_1.tif"),
      overwrite = TRUE
    )
    fs::file_copy(
      path = fs::path(
        tempdir_topsoil_dir,
        "ANZCW1202000149.txt"
      ),
      new_path = fs::path(cache_topsoil_dir)
    )
  }

  return(data.table::fifelse(
    cache,
    cache_topsoil_dir,
    tempdir_topsoil_dir
  ))
}

#' Prints read.abares.topsoil.thickness.files object
#'
#' Custom [base::print()] method for `read.abares.topsoil.thickness.files`
#' objects.
#'
#' @param x a `read.abares.topsoil.thickness.files` object.
#' @param ... ignored.
#' @export
#' @noRd
print.read.abares.topsoil.thickness.files <- function(x, ...) {
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
    {.fn print_topsoil_thickness_metadata} on a soil thickness object in your R
                session."
  )
  cli::cat_line()
  invisible(x)
}

#' Display complete metadata associated with soil thickness data
#'
#' Displays the complete set of metadata associated with the soil thickness
#'  data in your \R console. For including the metadata in documents or other
#'  methods outside of \R, see [get_topsoil_thickness()] for an example using
#'  [pander::pander()] to print the metadata.
#'
#' @param x A `read.abares.topsoil.thickness.files` object.
#'
#' @note
#' The original metadata use a title of "Soil Thickness", in the context of this
#' package, we refer to it as "Topsoil Thickness" to be consistent with the
#' actual values in the data.
#'
#' @returns Nothing, called for its side effects, it prints the complete
#'   metadata file to the \R console.
#' @examplesIf interactive()
#' get_topsoil_thickness() |>
#'   print_topsoil thickness_metadata()
#'
#' @family topsoil thickness
#'
#' @export
print_topsoil_thickness_metadata <- function(x) {
  .check_class(x = x, class = "read.abares.topsoil.thickness.files")
  loc <- stringr::str_locate(x$metadata, "Custodian")
  metadata <- stringr::str_sub(
    x$metadata,
    loc[, "start"] - 1L,
    nchar(x$metadata)
  )
  cli::cli_h1(
    "Topsoil Thickness for Australian areas of intensive agriculture of Layer 1 (A Horizon - top-soil)\n"
  )
  cli::cli_h2("Dataset ANZLIC ID ANZCW1202000149")
  cli::cli_text(metadata)
  cli::cat_line()
  invisible(x)
}
