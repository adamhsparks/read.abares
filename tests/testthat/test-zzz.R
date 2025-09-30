# Package-private state (never reassign this binding)
.read.abares_state <- new.env(parent = emptyenv())

# Small helper
#' @noRd
`%||%` <- function(x, y) if (is.null(x)) y else x

# Internal: map read.abares.verbosity -> derived options
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
  # Namespace and its parent (imports) env
  ns <- asNamespace("read.abares")
  penv <- parent.env(ns)

  # ----- 1) Snapshot current non-read.abares options
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
  # Save snapshot into package-private state (idempotent)
  .read.abares_state$old_options <- saved

  # Best-effort: expose the same env under the parent env for tools/tests that
  # look there. If the binding is locked, swallow the error and carry on.
  if (!exists(".read.abares_env", envir = penv, inherits = FALSE)) {
    tryCatch(
      assign(".read.abares_env", .read.abares_state, envir = penv),
      error = function(e) invisible(NULL)
    )
  }

  # ----- 2) Compute defaults; temporarily relax warnings around UA
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

  # Defaults, only if missing
  op.read.abares <- list(
    read.abares.user_agent = ua,
    read.abares.timeout = 5000L,
    read.abares.max_tries = 3L,
    read.abares.verbosity = "verbose"
  )
  toset <- !(names(op.read.abares) %in% names(op))
  if (any(toset)) {
    # Persist for package lifetime; auto-restore on unload
    withr::local_options(
      op.read.abares[toset],
      .local_envir = .read.abares_state
    )
  }

  # ----- 3) Apply verbosity mapping for package lifetime
  mapped <- .map_verbosity(getOption("read.abares.verbosity"))
  withr::local_options(mapped, .local_envir = .read.abares_state)

  invisible()
}

.onUnload <- function(libpath) {
  # Run all withr defers tied to package state and restore saved snapshot
  withr::deferred_run(.read.abares_state)

  old_opts <- .read.abares_state$old_options
  if (is.list(old_opts) && length(old_opts)) {
    options(old_opts)
  }
  invisible()
}
