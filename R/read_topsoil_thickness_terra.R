#' Read a Soil Thickness for Australian Areas of Intensive Agriculture of Layer 1 file with terra
#'
#' Read Soil Thickness for Australian Areas of Intensive Agriculture of Layer 1
#'  data as a [terra::rast] object.
#'
#' @inheritParams read_topsoil_thickness_stars
#'
#' @references <https://data.agriculture.gov.au/geonetwork/srv/eng/catalog.search#/metadata/faa9f157-8e17-4b23-b6a7-37eb7920ead6>
#' @source <https://anrdl-integration-web-catalog-saxfirxkxt.s3-ap-southeast-2.amazonaws.com/warehouse/staiar9cl__059/staiar9cl__05911a01eg_geo___.zip>

#'
#' @returns A [terra::rast] object of the 'Soil Thickness for Australian Areas
#'  of Intensive Agriculture of Layer 1'.
#'
#' @examplesIf interactive()
#' st_terra <- get_topsoil_thickness(cache = TRUE) |>
#'   read_topsoil_thickness_terra()
#'
#' # terra::plot() is reexported for convenience
#' plot(st_terra)
#'
#' @family topsoil_thickness
#' @autoglobal
#' @export

read_topsoil_thickness_terra <- function(files) {
  .check_class(x = files, class = "read.abares.topsoil.thickness.files")
  # if we're reading from tempdir() we need to remove the RAT that is removed
  # by default when caching the GTiff
  if (!grepl(pattern = .find_user_cache(), files$GTiff)) {
    files$GTiff <- terra::init(
      as.character(files$GTiff),
      as.character(files$Gtiff[])
    ) # remove RAT legend
  }
  return(terra::rast(as.character(files$GTiff)))
}
