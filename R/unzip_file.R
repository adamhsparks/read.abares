#' Unzip a zip file
#'
#' Unzips the provided zip file into a folder named after the zip (without .zip).
#' If unzipping fails, it will return an error and delete the corrupted zip file
#' and any partially-created extract directory.
#'
#' @param .x A zip file for unzipping.
#' @returns Invisible directory path, called for side effects.
#' @dev

.unzip_file <- function(.x) {
  tryCatch(
    {
      base_dir <- fs::path_dir(.x)
      dat_dir <- fs::path_ext_remove(.x) # deterministic extract folder
      fs::dir_create(dat_dir, recurse = TRUE)

      # Use R's internal unzip to avoid system dependency
      utils::unzip(
        zipfile = .x,
        exdir = dat_dir,
        overwrite = TRUE,
        unzip = "internal"
      )

      invisible(dat_dir)
    },
    error = function(e) {
      dat_dir <- fs::path_ext_remove(.x)
      if (fs::dir_exists(dat_dir)) {
        .safe_delete(dat_dir)
      }
      cli::cli_abort(
        "Unzip failed for {.path {basename(.x)}}: {conditionMessage(e)}",
        call = rlang::caller_env()
      )
    }
  )
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
