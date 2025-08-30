#' Read ABARES' "Soil Thickness for Australian Areas of Intensive Agriculture of Layer 1" with terra
#'
#' Read "Soil Thickness for Australian Areas of Intensive Agriculture of Layer
#'  1" as a [terra::rast()] object.
#'
#' @inheritParams read_agfd_dt
#' @param ... Additional arguments passed to [terra::rast()].
#'
#' @references
#' \url{https://data.agriculture.gov.au/geonetwork/srv/eng/catalog.search#/metadata/faa9f157-8e17-4b23-b6a7-37eb7920ead6}
#' @source
#' \url{https://anrdl-integration-web-catalog-saxfirxkxt.s3-ap-southeast-2.amazonaws.com/warehouse/staiar9cl__059/staiar9cl__05911a01eg_geo___.zip}
#'
#' @returns A [terra::rast()] object of the "Soil Thickness for Australian Areas
#'  of Intensive Agriculture of Layer 1".
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
read_topsoil_thickness_terra <- function(x = NULL) {
  files <- .get_topsoil_thickness(.x = x)
  return(files$data)
}
