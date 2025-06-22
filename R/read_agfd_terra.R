#' Read Australian Gridded Farm Data (AGFD) NCDF files with terra
#'
#' Read Australian Gridded Farm Data, (\acronym{AGFD}) as a `list()` of
#'  [terra::rast()] objects.
#'
#' @inherit get_agfd details
#' @inheritParams read_agfd_dt
#' @inheritSection read_agfd_dt Model scenarios
#' @inheritSection read_agfd_dt Data files
#' @inheritSection read_agfd_dt Data layers
#' @inherit read_agfd_dt references
#'
#' @returns A `list()` object of [terra::rast()] objects of the
#'  \dQuote{Australian Gridded Farm Data} with the file names as the list's
#'  objects' names.
#'
#' @examplesIf interactive()
#'
#' agfd_terra <- read_agfd_terra()
#'
#' head(agfd_terra)
#'
#' plot(agfd_terra[[1]])
#'
#' @family AGFD
#' @autoglobal
#' @export

read_agfd_terra <- function(
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
  r <- purrr::map(.x = files, .f = terra::rast)
  names(r) <- fs::path_file(files)
  return(r)
}
