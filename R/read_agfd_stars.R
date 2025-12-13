#' Read ABARES' "Australian Gridded Farm Data" (AGFD) NCDF files with stars
#'
#' Read "Australian Gridded Farm Data", (\acronym{AGFD}), as a list of
#'  \CRANpkg{stars} objects.
#'
#' @inherit read_agfd_dt details
#' @inheritParams read_agfd_dt
#' @inheritParams read_aagis_regions
#' @inheritSection read_agfd_dt Model scenarios
#' @inheritSection read_agfd_dt Data files
#' @inheritSection read_agfd_dt Data layers
#' @inherit read_agfd_dt references
#'
#' @returns A `list` object of \CRANpkg{stars} objects of the "Australian
#'  Gridded Farm Data" with the NetCDF objects' names as "year_yyyy".
#'
#' @examplesIf interactive()
#'
#' agfd_stars <- read_agfd_stars()
#'
#' head(agfd_stars)
#'
#' plot(agfd_stars[[1]])
#'
#' @family AGFD
#' @autoglobal
#' @export

read_agfd_stars <- function(
  yyyy = 1991:2003,
  fixed_prices = TRUE,
  x = NULL
) {
  .check_agfd_yyyy(.yyyy = yyyy)

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
  s2 <- NULL
  q_read_ncdf <- purrr::quietly(stars::read_ncdf)
  n_files <- length(files)

  if (getOption("read.abares.verbosity") == "verbose") {
    s1 <- list(stars::read_ncdf(files[1L]))
    if (length(files) > 1L) {
      s2 <- purrr::modify_depth(
        purrr::map(.x = files[2L:n_files], .f = q_read_ncdf),
        1L,
        "result"
      )
      s1 <- append(s1, s2)
    }
  } else {
    # quietly read all files
    s1 <- purrr::modify_depth(
      purrr::map(.x = files, .f = q_read_ncdf),
      1L,
      "result"
    )
  }
  names(s1) <- fs::path_file(files)

  if (!is.null(s2)) {
    rm(s2)
  }

  gc()
  return(s1)
}
