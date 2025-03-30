#' Read a Soil Thickness for Australian Areas of Intensive Agriculture of Layer 1 file with terra
#'
#' Read Soil Thickness for Australian Areas of Intensive Agriculture of Layer 1
#'  data as a [terra::rast] object.
#'
#' @inheritParams read_soil_thickness_stars
#'
#' @references <https://data.agriculture.gov.au/geonetwork/srv/eng/catalog.search#/metadata/faa9f157-8e17-4b23-b6a7-37eb7920ead6>
#' @source <https://anrdl-integration-web-catalog-saxfirxkxt.s3-ap-southeast-2.amazonaws.com/warehouse/staiar9cl__059/staiar9cl__05911a01eg_geo___.zip>

#'
#' @returns A [terra::rast] object of the 'Soil Thickness for Australian Areas
#'  of Intensive Agriculture of Layer 1'.
#'
#' @examplesIf interactive()
#' st_terra <- get_soil_thickness(cache = TRUE) |>
#'   read_soil_thickness_terra()
#'
#' # terra::plot() is reexported for convenience
#' plot(st_terra)
#'
#' @family soil_thickness
#' @autoglobal
#' @export

read_soil_thickness_terra <- function(files) {
  .check_class(x = files, class = "read.abares.soil.thickness.files")
  x <- terra::rast(files$grid)
  # as per Lauren O'Brien's excellent suggestion to deal with an unwiedly legend
  return(terra::init(x, x[]))
}
