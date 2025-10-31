#' Read ABARES' "Australian Gridded Farm Data" (AGFD) NCDF Files with terra
#'
#' Read "Australian Gridded Farm Data", (\acronym{AGFD}), as a [terra::rast()]
#' object.
#'
#' @inherit read_agfd_dt details
#' @inheritParams read_agfd_dt
#' @inheritParams read_aagis_regions
#' @inheritSection read_agfd_dt Model scenarios
#' @inheritSection read_agfd_dt Data files
#' @inheritSection read_agfd_dt Data layers
#' @inherit read_agfd_dt references
#'
#' @returns A list of \CRANpkg{terra} `SpatRaster` objects of the "Australian
#'  Gridded Farm Data" with the NetCDF objects' names as "year_yyyy".
#'
#' @examplesIf interactive()
#'
#' agfd_terra <- read_agfd_terra()
#'
#' head(agfd_terra)
#'
#' # `plot()` is rexported from the `terra` package
#' plot(agfd_terra[[1]][[1]])
#'
#' @family AGFD
#' @autoglobal
#' @export

read_agfd_terra <- function(
  yyyy = 1991:2023,
  fixed_prices = TRUE,
  x = NULL
) {
  if (any(yyyy %notin% 1991:2023)) {
    cli::cli_abort(
      "{.arg yyyy} must be between 1991 and 2023 inclusive"
    )
  }

  if (is.null(x) || missing(x)) {
    files <- .get_agfd(
      .fixed_prices = fixed_prices,
      .yyyy = yyyy
    )
  } else {
    files <- .read_ncdf_from_zip(zip_path = x)
  }
  r <- purrr::map(.x = files, .f = terra::rast)
  names(r) <- fs::path_file(files)
  return(r)
}
