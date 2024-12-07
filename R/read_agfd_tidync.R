
#' Read agfd NCDF Files With tidync
#'
#' Read Australian Gridded Farm Data, (\acronym{AGFD}) as a list of [tidync]
#'  objects
#'
#' @inherit get_agfd details
#' @inheritParams read_agfd_dt
#' @inheritSection get_agfd Data Layers
#' @inherit get_agfd references
#'
#' @return a `list` object of \CRANpkg{tidync} [tidync::tidync] objects of the
#'  Australian Gridded Farm Data with the file names as the  list's objects'
#'  names.
#'
#' @examplesIf interactive()
#' x <- get_agfd(cache = TRUE) |>
#'   read_agfd_tidync()
#'
#' @family AGFD
#' @export

read_agfd_tidync <- function(files) {
  tnc <- purrr::map(files, tidync::tidync)
  names(tnc) <-  basename(files)
  return(tnc)
}
