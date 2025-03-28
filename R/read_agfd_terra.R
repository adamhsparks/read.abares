#' Read 'Australian Gridded Farm Data' (AGFD) NCDF files with terra
#'
#' Read Australian Gridded Farm Data, (\acronym{AGFD}) as a `list` of
#'  [terra::rast] objects.
#'
#' @inherit get_agfd details
#' @inheritParams read_agfd_dt
#' @inheritSection get_agfd Model scenarios
#' @inheritSection get_agfd Data files
#' @inheritSection get_agfd Data layers
#' @inherit get_agfd references
#'
#' @returns a `list` object of [terra::rast] objects of the Australian Gridded
#'  Farm Data with the file names as the list's objects' names.
#'
#' @examplesIf interactive()
#'
#' # using piping, which can use the {read.abares} cache after the first DL
#'
#' get_agfd(cache = TRUE) |>
#'   read_agfd_terra()
#'
#' @family AGFD
#' @autoglobal
#' @export

read_agfd_terra <- function(files) {
  .check_class(x = files, class = "read.abares.agfd.nc.files")
  r <- purrr::map(.x = files, .f = terra::rast)
  names(r) <- fs::path_file(files)
  return(r)
}
