#' Read AGDF NCDF Files with tidync
#'
#' @param files A list of NetCDF files to import
#' @return a `list` of \CRANpkg{tidync} [tidync::tidync] objects of the
#'  Australian Gridded Farm Data
#'
#' @examplesIf interactive()
#' terr_a <- get_agfd(cache = TRUE) |>
#'   read_agdf_terra()
#'
#' @export

read_agdf_tidync <- function(files) {
  lapply(files, tidync::tidync)
}
