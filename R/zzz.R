.onLoad <- function(libname, pkgname) {
  op <- options()
  op.read.abares <- list(
    read.abares.cache = FALSE,
    read.abares.cache_location = tools::R_user_dir(
      package = "read.abares",
      which = "cache"
    ),
    read.abares.user_agent = readabares_user_agent(),
    read.abares.timeout = 2000L,
    read.abares.max_tries = 3L,
    read.abares.quiet = TRUE
  )
  toset <- !(names(op.read.abares) %in% names(op))
  if (any(toset)) {
    options(op.read.abares[toset])
  }
  invisible()
}
