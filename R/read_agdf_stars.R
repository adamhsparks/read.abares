#' Read AGDF NCDF Files
#'
#' @param files A list of NetCDF files to import
#' @return a `list` of \CRANpkg{stars} objects of the Australian Gridded Farm
#'  Data
#' @examplesIf interactive()
#' star_s <- get_agfd(cache = TRUE) |>
#'   read_agdf_stars()
#'
#' @family read_agdf
#' @export

read_agdf_stars <- function(files) {
    s <- lapply(files, stars::read_ncdf)
}
