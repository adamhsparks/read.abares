#' Read \dQuote{Soil Thickness for Australian Areas of Intensive Agriculture of Layer 1} with stars
#'
#' Read \dQuote{Soil Thickness for Australian Areas of Intensive Agriculture of
#'  Layer 1} data as a \CRANpkg{stars} object.
#'
#' @inheritParams read_agfd_dt
#' @param ... Additional arguments passed to [terra::rast()], for *e.g.*,
#'  `activeCat` if you wished to set the active category when loading any of the
#'  available GeoTIFF files that are encoded with a raster attribute table.
#'
#' @references
#' \url{https://data.agriculture.gov.au/geonetwork/srv/eng/catalog.search#/metadata/faa9f157-8e17-4b23-b6a7-37eb7920ead6}
#' @source
#' \url{https://anrdl-integration-web-catalog-saxfirxkxt.s3-ap-southeast-2.amazonaws.com/warehouse/staiar9cl__059/staiar9cl__05911a01eg_geo___.zip}
#'
#' @returns A [stars] object of the 'Soil Thickness for Australian Areas of
#'  Intensive Agriculture of Layer 1'.
#'
#' @examplesIf interactive()
#' st_stars <- read_topsoil_thickness_stars()
#'
#' plot(st_stars)
#'
#' @family topsoil thickness
#' @autoglobal
#' @export

read_topsoil_thickness_stars <- function(files = NULL) {
  files <- .read_topsoil_thickness(.files = files)
  stars::read_stars(as.character(files$GTiff))
}
