#' Return the left-hand side if it's not NULL, otherwise it return the right-hand side
#' @dev
`%||%` <- function(x, y) {
  if (is.null(x)) y else x
}


#' Safely delete a file or directory (internal)
#'
#' Attempts to delete a file or directory reliably across platforms.
#' If the target doesn't exist, it does nothing and returns quietly.
#' It relaxes permissions first (best-effort) to avoid failures on read-only
#'  paths.
#'
#' @param path Path to a file or directory.
#' @param recursive Whether to delete directories recursively (default `TRUE`).
#' @return (Invisibly) `TRUE` if a delete was attempted; `FALSE` if nothing to
#'  delete.
#' @dev
.safe_delete <- function(path, recursive = TRUE) {
  if (is.null(path) || !nzchar(path)) {
    return(invisible(FALSE))
  }

  # Normalize & short-circuit if nothing exists
  path <- fs::path_abs(path)
  exists_any <- fs::file_exists(path) | fs::dir_exists(path)
  if (!exists_any) {
    return(invisible(FALSE))
  }

  # Make writable (best-effort). Helps on Windows / read-only files.
  suppressWarnings({
    if (fs::dir_exists(path)) {
      # include all entries inside the directory
      targets <- c(
        path,
        fs::dir_ls(path, recurse = TRUE, all = TRUE, type = "any")
      )
    } else {
      targets <- path
    }
    try(fs::file_chmod(targets, "u+w"), silent = TRUE)
  })

  # Primary delete using fs
  ok <- tryCatch(
    {
      if (fs::dir_exists(path)) {
        fs::dir_delete(path)
      } else {
        fs::file_delete(path)
      }
      TRUE
    },
    error = function(e) FALSE
  )

  # Fallback: base unlink (forceful on Windows)
  if (!ok) {
    try(unlink(path, recursive = recursive, force = TRUE), silent = TRUE)
  }

  invisible(TRUE)
}
