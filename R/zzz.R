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
  rlang::run_on_load()
  invisible(NULL)
}

rlang::on_load(
  rlang::on_package_load({
    data.table::fcase(
      getOption(read.abares.verbosity) == "quiet",
      options(
        rlang_quiet = TRUE,
        rlang_warning_verbosity = "quiet"
      ),
      getOption(read.abares.verbosity) == "verbose",
      options(
        rlang_quiet = FALSE,
        rlang_warning_verbosity = "verbose"
      ),
      getOption(read.abares.verbosity) == "minimal",
      options(
        rlang_quiet = TRUE,
        rlang_warning_verbosity = "minimal"
      )
    )
  })
)
