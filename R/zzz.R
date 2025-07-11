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
    read.abares.verbosity = "verbose"
  )
  toset <- !(names(op.read.abares) %in% names(op))
  if (any(toset)) {
    options(op.read.abares[toset])
  }

  verbosity <- getOption("read.abares.verbosity")
  rlib_message_level <- switch(
    verbosity,
    "quiet" = "quiet",
    "minimal" = "quiet",
    "verbose" = "verbose",
    "verbose"
  )
  rlib_warning_level <- switch(
    verbosity,
    "quiet" = "quiet",
    "minimal" = "verbose",
    "verbose" = "verbose",
    "verbose"
  )
  options(
    rlib_message_verbosity = rlib_message_level,
    rlib_warning_verbosity = rlib_warning_level
  )
}
