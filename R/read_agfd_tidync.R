#' Read ABARES' "Australian Gridded Farm Data" (AGFD) NCDF Files with tidync
#'
#' Read "Australian Gridded Farm Data", (\acronym{AGFD}) as a list of
#'   [tidync::tidync()] objects.
#'
#' @inherit read_agfd_dt details
#'
#' @inheritParams read_agfd_dt
#' @inheritParams read_aagis_regions
#'
#' @inheritSection read_agfd_dt Model scenarios
#'
#' @inheritSection read_agfd_dt Data files
#'
#' @inheritSection read_agfd_dt Data layers
#'
#' @inherit read_agfd_dt references
#'
#' @returns A `list` object of \CRANpkg{tidync} objects of the "Australian
#'  Gridded Farm Data" with the file names as the list's objects' names.
#'
#' @examplesIf interactive()
#'
#' agfd_tnc <- read_agfd_tidync()
#'
#' head(agfd_tnc)
#'
#' @family AGFD
#' @export

read_agfd_tidync <- function(
  fixed_prices = TRUE,
  yyyy = 1991:2003,
  file = NULL
) {
  rlang::arg_match(yyyy, values = 1991:2023, multiple = TRUE)
  if (is.null(file)) {
    file <- .get_agfd(
      fixed_prices = fixed_prices,
      yyyy = yyyy
    )
  }
  tnc <- purrr::map(files, tidync::tidync)
  names(tnc) <- fs::path_file(file)
  return(tnc)
}
