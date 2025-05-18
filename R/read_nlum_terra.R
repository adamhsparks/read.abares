#' Read national scale Land Use of Australia GeoTIFFs using terra
#'
#' Read national scale Land Use of Australia GeoTIFFs using terra as a
#'  categorical [terra::rast] object.
#'
#' # Note on cached files
#' If the data are cached you can pass only the `data_set` along with no need to
#'  use [get_nlum()].
#'
#' @inherit get_nlum details
#' @inherit get_nlum references
#'
#' @param data_set A string value indicating the GeoTIFF desired for loading
#'  into the active \R session.
#' One of:
#' \describe{
#'  \item{Y201011}{Land use of Australia 2010–11}
#'  \item{Y201516}{Land use of Australia 2015–16}
#'  \item{Y202021}{Land use of Australia 2020–21}
#'  \item{C201021}{Land use of Australia change}
#'  \item{T201011}{Land use of Australia 2010–11 thematic layers}
#'  \item{T201516}{Land use of Australia 2015–16 thematic layers}
#'  \item{T202021}{Land use of Australia 2020–21 thematic layers}
#'  \item{P201011}{Land use of Australia 2010–11 agricultural commodities probability grids}
#'  \item{P201516}{Land use of Australia 2015–16 agricultural commodities probability grids}
#'  \item{P202021}{Land use of Australia 2020–21 agricultural commodities probability grids}
#' }
#'
#' @returns A [terra::rast] object of the requested national scale Land Use of
#'  Australia GeoTIFF.
#'
#' @examplesIf interactive()
#'
#' # using piping, which can use the {read.abares} cache after the first DL
#'
#' nlum_terra <- get_nlum(data_set = "Y2020212", cache = TRUE) |>
#'   read_nlum_terra()
#'
#' nlum_terra
#'
#' plot(nlum_terra)
#'
#' @family nlum
#' @autoglobal
#' @export

# TODO: consider checking if the data are available, if not, ask user if they
#  would like to download it using `get_nlum()` and cache or not.

read_nlum_terra <- function(data_set) {
  .check_class(x = files, class = "read.abares.nlum.files")
  r <- purrr::map(.x = files, .f = terra::rast)
  names(r) <- fs::path_file(files)
  return(r)
}
