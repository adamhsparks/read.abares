#' Read ABARES' "Australian Gridded Farm Data" (AGFD) NCDF Files with tidync
#'
#' Read "Australian Gridded Farm Data", (\acronym{AGFD}), as a list of
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
#' @returns A list of \CRANpkg{tidync} objects of the "Australian Gridded Farm
#'  Data"  with the NetCDF objects' names as "year_yyyy".
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
  .check_yyyy(.yyyy = yyyy)

  if (is.null(x) || missing(x)) {
    files <- .get_agfd(
      .fixed_prices = fixed_prices,
      .yyyy = yyyy
    )
  } else {
    # copy the file to the tempdir for the unzip fn to work properly
    # we won't touch the original file provided this way
    files <- .copy_local_agfd_zip(x)
  }
  tnc <- purrr::map(.x = files, .f = tidync::tidync)
  names(tnc) <- fs::path_file(files)
  return(tnc)
}
