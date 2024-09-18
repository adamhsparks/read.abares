
#' Read AGFD NCDF Files With terra
#'
#' Read Australian Gridded Farm Data, (\acronym{AGFD}) as a `list` of
#'  [terra::rast] objects.
#'
#' @param files A list of NetCDF files to import
#' @return a `list` object of [terra::rast] objects of the Australian Gridded
#'  Farm Data with the file names as the list's objects' names
#'
#' @examplesIf interactive()
#' get_agfd(cache = TRUE) |>
#'   read_agfd_terra()
#'
#' @family read_agfd
#' @autoglobal
#' @export

read_agfd_terra <- function(files) {
  r <- purrr::map(.x = files, .f = terra::rast)
  names(r) <- basename(files)
  return(r)
}
