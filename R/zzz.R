# Small helper: base R has no %||%
#' @noRd
`%||%` <- function(x, y) if (is.null(x)) y else x

# Internal: map read.abares.verbosity to derived options
#' @noRd
.map_verbosity <- function(verbosity) {
  v <- as.character(verbosity %||% "verbose")
  if (!v %in% c("quiet", "minimal", "verbose")) {
    v <- "verbose"
  }

  list(
    rlib_message_verbosity = switch(
      v,
      "quiet" = "quiet",
      "minimal" = "minimal",
      "verbose" = "verbose"
    ),
    rlib_warning_verbosity = switch(
      v,
      "quiet" = "quiet",
      "minimal" = "verbose",
      "verbose" = "verbose"
    ),
    warn = switch(v, "quiet" = -1L, "minimal" = 0L, "verbose" = 0L),
    datatable.showProgress = switch(
      v,
      "quiet" = FALSE,
      "minimal" = FALSE,
      "verbose" = TRUE
    )
  )
}

.onLoad <- function(libname, pkgname) {
  penv <- parent.env(environment())

  op <- options()
  saved <- op[
    names(op) %in%
      c(
        "rlib_message_verbosity",
        "rlib_warning_verbosity",
        "warn",
        "datatable.showProgress"
      )
  ]

  read.abares_env <- new.env(parent = emptyenv())
  read.abares_env$old_options <- saved
  assign(".read.abares_env", read.abares_env, envir = penv)

  ua <- tryCatch(
    withr::with_options(list(warn = 0L), readabares_user_agent()),
    error = function(e) {
      ver <- tryCatch(
        as.character(utils::packageVersion("read.abares")),
        error = function(...) "unknown"
      )
      sprintf("read.abares/%s (unknown UA)", ver)
    }
  )

  op.read.abares <- list(
    read.abares.user_agent = ua,
    read.abares.timeout = 5000L,
    read.abares.max_tries = 3L,
    read.abares.verbosity = "verbose"
  )
  toset <- !(names(op.read.abares) %in% names(op))
  if (any(toset)) {
    withr::local_options(op.read.abares[toset], .local_envir = penv)
  }

  verbosity <- getOption("read.abares.verbosity")
  mapped <- .map_verbosity(verbosity)
  withr::local_options(mapped, .local_envir = penv)

  invisible()
}

.onUnload <- function(libpath) {
  penv <- parent.env(environment())
  withr::deferred_run(penv)
  invisible()
}
