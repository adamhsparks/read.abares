
#' Read agfd NCDF Files
#'
#' @param files A list of NetCDF files to import
#' @return a \CRANpkg{terra} [terra::rast] object of the Australian Gridded Farm
#'  Data
#'
#' @examplesIf interactive()
#' get_agfd(cache = TRUE) |>
#'   read_agfd_terra()
#'
#' @family read_agfd
#' @export

read_agfd_terra <- function(files) {
    r <- terra::rast(files)
}
