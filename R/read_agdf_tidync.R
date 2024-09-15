
#' Read agfd NCDF Files with tidync
#'
#' @param files A list of NetCDF files to import
#' @return a `list` of \CRANpkg{tidync} [tidync::tidync] objects of the
#'  Australian Gridded Farm Data
#'
#' @examplesIf interactive()
#' get_agfd(cache = TRUE) |>
#'   read_agfd_tidync()
#'
#' @family read_agfd
#' @export

read_agfd_tidync <- function(files) {
  lapply(files, tidync::tidync)
}
