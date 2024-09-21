
#' Read Soil Thickness File With terra
#'
#' Read Soil Thickness for Australian Areas of Intensive Agriculture of Layer 1
#'  data as a [terra::rast] object.
#'
#' @param files An \pkg{abares} `abares.soil.thickness` object, a `list` that
#'  contains the \acronym{ESRI} grid file to import
#' @return a [terra::rast] object of the Soil Thickness for Australian Areas of
#'  Intensive Agriculture of Layer 1
#'
#' @examplesIf interactive()
#' get_soil_thickness(cache = TRUE) |>
#'   read_soil_thickness_terra()
#'
#' @family soil_thickness
#' @autoglobal
#' @export

read_soil_thickness_terra <- function(files) {
  .check_class(x = files, class = "abares.soil.thickness.files")
  r <- terra::rast(files$grid)
  return(r)
}
