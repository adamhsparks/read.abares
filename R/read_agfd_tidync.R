#' Read ABARES' "Australian Gridded Farm Data" (AGFD) NCDF Files with tidync
#'
#' Read "Australian Gridded Farm Data", (\acronym{AGFD}) as a list of
#'   [tidync::tidync()] objects.
#'
#' @inherit read_agfd_dt details
#'
#' @inheritParams read_agfd_dt
#'
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
  yyyy = 1991:2023,
  fixed_prices = TRUE,
  x = NULL
) {
  if (any(yyyy %notin% 1991:2023)) {
    cli::cli_abort(
      "{.arg yyyy} must be between 1991 and 2023 inclusive"
    )
  }
  if (x == NULL) {
    files <- .get_agfd(
      .fixed_prices = fixed_prices,
      .yyyy = yyyy,
      .x = x
    )
  } else {
    files <- .read_ncdf_from_zip(zip_path = x)
  }
  tnc <- purrr::map(files, tidync::tidync)
  names(tnc) <- fs::path_file(files)
  return(tnc)
}
