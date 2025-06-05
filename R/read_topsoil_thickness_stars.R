#' Read a 'Soil Thickness for Australian Areas of Intensive Agriculture of Layer 1' file with stars
#'
#' Read Soil Thickness for Australian Areas of Intensive Agriculture of Layer 1
#'  data as a \CRANpkg{stars} object.
#'
#' @param files An \pkg{read.abares} `read.abares.topsoil.thickness` object, a
#'  `list` that contains the \acronym{ESRI} grid file to import.
#'
#' @references <https://data.agriculture.gov.au/geonetwork/srv/eng/catalog.search#/metadata/faa9f157-8e17-4b23-b6a7-37eb7920ead6>
#' @source <https://anrdl-integration-web-catalog-saxfirxkxt.s3-ap-southeast-2.amazonaws.com/warehouse/staiar9cl__059/staiar9cl__05911a01eg_geo___.zip>
#'
#' @returns A [stars] object of the 'Soil Thickness for Australian Areas of
#'  Intensive Agriculture of Layer 1'.
#'
#' @examplesIf interactive()
#' st_stars <- get_topsoil_thickness(cache = FALSE) |>
#'   read_topsoil_thickness_stars()
#'
#' plot(st_stars)
#'
#' @family topsoil_thickness
#' @autoglobal
#' @export

read_topsoil_thickness_stars <- function(files) {
  .check_class(x = files, class = "read.abares.topsoil.thickness.files")
  stars::read_stars(as.character(files$GTiff))
}
