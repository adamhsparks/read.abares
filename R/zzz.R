.onLoad <- function(libname, pkgname) {
  # save options for non-read.abares options for resetting after package exits
  op <- options()
  read.abares_env <- new.env(parent = emptyenv())
  read.abares_env$old_options <- op[
    names(op) %in%
      c(
        "rlib_message_verbosity",
        "rlib_warning_verbosity",
        "warn",
        "datatable.showProgress"
      )
  ]
  assign(".read.abares_env", read.abares_env, envir = parent.env(environment()))

  op.read.abares <- list(
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
    "minimal" = "minimal",
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
  warn_level <- switch(
    verbosity,
    "quiet" = -1L,
    "minimal" = 0L,
    "verbose" = 0L
  )
  fread_level <- switch(
    verbosity,
    "quiet" = FALSE,
    "minimal" = FALSE,
    "verbose" = TRUE
  )
  options(
    rlib_message_verbosity = rlib_message_level,
    rlib_warning_verbosity = rlib_warning_level,
    warn = warn_level,
    datatable.showProgress = fread_level
  )
}

.onUnload <- function(libpath) {
  if (exists(".read.abares_env", envir = parent.env(environment()))) {
    old_opts <- get(
      ".read.abares_env",
      envir = parent.env(environment())
    )$old_options
    options(old_opts)
  }
}
