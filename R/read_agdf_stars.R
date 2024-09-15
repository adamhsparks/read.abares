
#' Read agfd NCDF Files
#'
#' @param files A list of NetCDF files to import
#' @return a `list` of \CRANpkg{stars} objects of the Australian Gridded Farm
#'  Data
#' @examplesIf interactive()
#' get_agfd(cache = TRUE) |>
#'   read_agfd_stars()
#'
#' @family read_agfd
#' @export

read_agfd_stars <- function(files) {
    s <- lapply(files, stars::read_ncdf)
}
