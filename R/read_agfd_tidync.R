#' Read Australian Gridded Farm Data (AGFD) NCDF files with tidync
#'
#' Read Australian Gridded Farm Data, (\acronym{AGFD}) as a list of
#'   [tidync::tidync()] objects.
#'
#' @inherit read_agfd_dt details
#' @inheritParams read_agfd_dt
#' @inheritSection read_agfd_dt Model scenarios
#' @inheritSection read_agfd_dt Data files
#' @inheritSection read_agfd_dt Data layers
#' @inherit read_agfd_dt references
#'
#' @returns A `list` object of \CRANpkg{tidync} objects of the
#'  \dQuote{Australian Gridded Farm Data} with the file names as the list's
#'  objects' names.
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
  cache = getOption("read.abares.cache"),
  cache_location = getOption("read.abares.cache_location"),
  user_agent = getOption("read.abares.user_agent"),
  max_tries = getOption("read.abares.max_tries"),
  timout = getOption("read.abares.max_tries"),
  files = NULL
) {
  if (missing(cache)) {
    cache <- getOption("read.abares.cache", default = FALSE)
  }

  rlang::arg_match(yyyy, values = 1991:2023, multiple = TRUE)
  if (is.null(files)) {
    files <- get_agfd(
      fixed_prices = fixed_prices,
      yyyy = yyyy,
      cache = cache,
      cache_location = cache_location,
      user_agent = user_agent,
      max_tries = max_tries,
      timeout = timeout,
      files = files
    )
  }
  tnc <- purrr::map(files, tidync::tidync)
  names(tnc) <- fs::path_file(files)
  return(tnc)
}
