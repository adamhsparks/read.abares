
#' Read agfd NCDF Files With tidync
#'
#' @param files A list of NetCDF files to import
#'
#' @return a `list` object of \CRANpkg{tidync} [tidync::tidync] objects of the
#'  Australian Gridded Farm Data with the file names as the  list's objects'
#'  names.
#'
#' @examplesIf interactive()
#' get_agfd(cache = TRUE) |>
#'   read_agfd_tidync()
#'
#' @family AGFD
#' @export

read_agfd_tidync <- function(files) {
  tnc <- purrr::map(files, tidync::tidync)
  names(tnc) <-  basename(files)
  return(tnc)
}
