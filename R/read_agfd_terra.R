
#' Read AGFD NCDF Files
#'
#' Read Australian Gridded Farm Data, (\acronym{AGFD}) as a [terra::rast]
#'  object.
#'
#' @param files A list of NetCDF files to import
#' @return a `list` object of [terra::rast] object of the Australian Gridded
#'  Farm Data with the file names as the `rast's` layers' names
#'
#' @examplesIf interactive()
#' get_agfd(cache = TRUE) |>
#'   read_agfd_terra()
#'
#' @family read_agfd
#' @export

read_agfd_terra <- function(files) {
  r <- purrr::map(.x = files, .f = terra::rast)
  names(r) <- basename(files)
  return(r)
}
