
#' Read Soil Thickness File With terra
#'
#' Read Soil Thickness for Australian Areas of Intensive Agriculture of Layer 1
#'  data as a [terra::rast] object.
#'
#' @param files An \pkg{read.abares} `read.abares.soil.thickness` object, a `list` that
#'  contains the \acronym{ESRI} grid file to import
#' @return a [terra::rast] object of the Soil Thickness for Australian Areas of
#'  Intensive Agriculture of Layer 1
#'
#' @examplesIf interactive()
#' x <- get_soil_thickness(cache = TRUE) |>
#'   read_soil_thickness_terra()
#'
#' # terra::plot() is reexported for convience
#' plot(x)
#'
#' @family soil_thickness
#' @autoglobal
#' @export

read_soil_thickness_terra <- function(files) {
  .check_class(x = files, class = "read.abares.soil.thickness.files")
  r <- terra::rast(files$grid)
  return(r)
}
