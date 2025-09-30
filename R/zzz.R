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
  # Use the parent of the package namespace (matches your original behavior & tests)
  penv <- parent.env(environment())

  # ----- 1) Snapshot current non-read.abares options (for test introspection/fallback)
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

  # Keep a record in the parent env (as your tests expect)
  read.abares_env <- new.env(parent = emptyenv())
  read.abares_env$old_options <- saved
  assign(".read.abares_env", read.abares_env, envir = penv)

  # ----- 2) Compute defaults; example: compute UA under temporarily relaxed warnings
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

  # Defaults only apply if options are currently missing
  op.read.abares <- list(
    read.abares.user_agent = ua,
    read.abares.timeout = 5000L,
    read.abares.max_tries = 3L,
    read.abares.verbosity = "verbose"
  )
  toset <- !(names(op.read.abares) %in% names(op))
  if (any(toset)) {
    # Persist for package lifetime; auto-restore on unload
    withr::local_options(op.read.abares[toset], .local_envir = penv)
  }

  # ----- 3) Map verbosity to derived options (persist for package lifetime)
  verbosity <- getOption("read.abares.verbosity")
  mapped <- .map_verbosity(verbosity)
  withr::local_options(mapped, .local_envir = penv)

  invisible()
}

.onUnload <- function(libpath) {
  # Execute all cleanups registered with local_options() tied to 'penv'
  penv <- parent.env(environment())
  withr::deferred_run(penv)
  invisible()
}
