#' Read a Soil Thickness for Australian Areas of Intensive Agriculture of Layer 1 file with terra
#'
#' Read Soil Thickness for Australian Areas of Intensive Agriculture of Layer 1
#'  data as a [terra::rast()] object.
#'
#'
#' @inheritParams get_agfd
#' @param ... Additional arguments passed to [terra::rast()], for *e.g.*,
#'  `activeCat` if you wished to set the active category when loading any of the
#'  available GeoTIFF files that are encoded with a raster attribute table.
#'
#' @inheritSection get_agfd Caching
#'
#' @references
#' \url{https://data.agriculture.gov.au/geonetwork/srv/eng/catalog.search#/metadata/faa9f157-8e17-4b23-b6a7-37eb7920ead6}
#' @source
#' \url{https://anrdl-integration-web-catalog-saxfirxkxt.s3-ap-southeast-2.amazonaws.com/warehouse/staiar9cl__059/staiar9cl__05911a01eg_geo___.zip}

#'
#' @returns A [terra::rast()] object of the 'Soil Thickness for Australian Areas
#'  of Intensive Agriculture of Layer 1'.
#'
#' @examplesIf interactive()
#' st_terra <- read_topsoil_thickness_terra()
#'
#' # terra::plot() is reexported for convenience
#' plot(st_terra)
#'
#' @family topsoil thickness
#' @autoglobal
#' @export

read_topsoil_thickness_terra <- function(cache = FALSE) {
  files <- get_topsoil_thickness(cache = cache)

  # if we're reading from tempdir() we need to remove the RAT that is removed
  # by default when caching the GTiff
  if (!grepl(pattern = .find_user_cache(), files$GTiff)) {
    t <- terra::rast(
      files$GTiff
    )
    return(terra::init(
      t,
      t[]
    ))
  }
  return(terra::rast(files$GTiff))
}
