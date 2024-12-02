
#' Read Soil Thickness File With stars
#'
#' Read Soil Thickness for Australian Areas of Intensive Agriculture of Layer 1
#'  data as a \CRANpkg{stars} object.
#'
#' @param files An \pkg{read.abares} `read.abares.soil.thickness` object, a
#'  `list` that contains the \acronym{ESRI} grid file to import
#' @return a [stars] object of the Soil Thickness for Australian Areas of
#'  Intensive Agriculture of Layer 1
#'
#' @examplesIf interactive()
#' get_soil_thickness(cache = TRUE) |>
#'   read_soil_thickness_stars()
#'
#' @family soil_thickness
#' @autoglobal
#' @export

read_soil_thickness_stars <- function(files) {
  .check_class(x = files, class = "read.abares.soil.thickness.files")
  s <- stars::read_stars(files$grid)
  return(s)
}
