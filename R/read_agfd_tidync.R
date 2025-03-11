#' Read 'Australian Gridded Farm Data' (AGFD) NCDF files with tidync
#'
#' Read Australian Gridded Farm Data, (\acronym{AGFD}) as a list of
#'   [tidync::tidync] objects.
#'
#' @inherit get_agfd details
#' @inheritParams read_agfd_dt
#' @inheritSection get_agfd Model scenarios
#' @inheritSection get_agfd Data files
#' @inheritSection get_agfd Data layers
#' @inherit get_agfd references
#'
#' @returns a `list` object of \CRANpkg{tidync} [tidync::tidync] objects of the
#'  Australian Gridded Farm Data with the file names as the  list's objects'
#'  names.
#'
#' @examplesIf interactive()
#'
#' # using piping, which can use the {read.abares} cache after the first DL
#'
#' x <- get_agfd(cache = TRUE) |>
#'   read_agfd_tidync()
#'
#' @family AGFD
#' @export

read_agfd_tidync <- function(files) {
  tnc <- purrr::map(files, tidync::tidync)
  names(tnc) <- basename(files)
}
