#' Get ABARES' Topsoil Thickness for "Australian Areas of Intensive Agriculture of Layer 1"
#'
#' Fetches topsoil thickness data and associated metadata from \acronym{ABARES}.
#'
#' @param .x A character string passed that provides a file path to the
#'  local directory holding the unzipped files for topsoil thickness.
#' @note
#' A custom `print()` method is provided that will print the metadata associated
#'  with these data. Examples are provided for interacting with the metadata
#'  directly.
#'
#' @examples
#' x <- .get_topsoil_thickness(.x = NULL)
#'
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
#'  with the [terra::rast()] object of the data and text file of metadata.
#'
#' @references <https://data.agriculture.gov.au/geonetwork/srv/eng/catalog.search#/metadata/faa9f157-8e17-4b23-b6a7-37eb7920ead6>
#' @source <https://anrdl-integration-web-catalog-saxfirxkxt.s3-ap-southeast-2.amazonaws.com/warehouse/staiar9cl__059/staiar9cl__05911a01eg_geo___.zip>
#'
#' @dev

.get_topsoil_thickness <- function(.x = NULL) {
  if (is.null(.x)) {
    .x <- fs::path(tempdir(), "staiar9cl__05911a01eg_geo___.zip")
    .retry_download(
      "https://anrdl-integration-web-catalog-saxfirxkxt.s3-ap-southeast-2.amazonaws.com/warehouse/staiar9cl__059/staiar9cl__05911a01eg_geo___.zip",
      dest = .x
    )
  }

  .unzip_file(.x)
  root <- fs::path_dir(.x)

  # Locate metadata file anywhere under root
  md_idx <- fs::dir_ls(
    root,
    recurse = TRUE,
    type = "file",
    regexp = "(^|/)ANZCW1202000149\\.txt$"
  )
  metadata <- readtext::readtext(md_idx[[1L]])

  # Locate raster file; accept thpk_1 or thpk_1.tif
  ras_candidates <- fs::dir_ls(
    root,
    recurse = TRUE,
    type = "file",
    regexp = "(^|/)thpk_1(\\.tif)?$"
  )
  rast_path <- ras_candidates[[1L]]

  x <- terra::rast(rast_path)
  x <- terra::init(x, x[]) # remove RAT legend if present

  out <- list(metadata = metadata$text, data = x)
  class(out) <- union("read.abares.topsoil.thickness", class(out))
  return(out)
}

#' Prints a read.abares.topsoil.thickness Object
#'
#' Custom [base::print()] method for `read.abares.topsoil.thickness`
#' objects.
#'
#' @param x a `read.abares.topsoil.thickness.xs` object.
#' @param ... ignored.
#' @export
#' @noRd

print.read.abares.topsoil.thickness <- function(x, ...) {
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
#'  methods outside of \R, see `.get_topsoil_thickness()` for an example using
#'  [pander::pander()] to print the metadata.
#'
#' @param x A `read.abares.topsoil.thickness` object.
#'
#' @note
#' The original metadata use a title of "Soil Thickness", in the context of this
#' package, we refer to it as "Topsoil Thickness" to be consistent with the
#' actual values in the data.
#'
#' @returns Nothing, called for its side effects, it prints the complete
#'   metadata file to the \R console.
#' @examplesIf interactive()
#' .get_topsoil_thickness() |>
#'   print_topsoil_thickness_metadata()
#'
#' @family topsoil thickness
#'
#' @export
print_topsoil_thickness_metadata <- function(x) {
  if (missing(x) || is.null(x)) {
    x <- .get_topsoil_thickness(.x = NULL)
  }
  loc <- stringr::str_locate(
    x$metadata,
    stringr::fixed("Custodian", ignore_case = FALSE)
  )
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
  return(invisible(NULL))
}
