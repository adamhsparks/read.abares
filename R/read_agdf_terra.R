#' Read AGDF NCDF Files
#'
#' @param files A list of NetCDF files to import
#' @return a \CRANpkg{terra} [terra::rast] object of the Australian Gridded Farm
#'  Data
#'
#' @examplesIf interactive()
#' terr_a <- get_agfd(cache = TRUE) |>
#'   read_agdf_terra()
#'
#' @family read_agdf
#' @export

read_agdf_terra <- function(files) {
    r <- terra::rast(files)
}
