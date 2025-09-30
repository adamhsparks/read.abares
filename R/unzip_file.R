#' Unzip a zip file
#'
#' Unzips the provided zip file into a folder named after the zip (without .zip).
#' If unzipping fails, it will return an error and delete the corrupted zip file
#' and any partially-created extract directory.
#'
#' @param .x A zip file for unzipping.
#' @returns Invisible NULL, called for side effects.
#' @dev
.unzip_file <- function(.x) {
  tryCatch(
    {
      base_dir <- fs::path_dir(.x)
      dat_dir <- fs::path_ext_remove(.x) # deterministic extract folder
      fs::dir_create(dat_dir, recurse = TRUE)

      withr::with_dir(
        base_dir,
        utils::unzip(.x, exdir = dat_dir, overwrite = TRUE)
      )

      # --- Optional: de-nest if the ZIP had a single top-level directory ---
      entries <- fs::dir_ls(dat_dir, all = TRUE, type = "any")
      subdirs <- entries[fs::is_dir(entries)]
      files <- entries[fs::is_file(entries)]

      if (length(files) == 0L && length(subdirs) == 1L) {
        inner <- subdirs
        inner_entries <- fs::dir_ls(inner, all = TRUE)
        if (length(inner_entries)) {
          fs::file_move(
            inner_entries,
            fs::path(dat_dir, fs::path_file(inner_entries))
          )
        }
        fs::dir_delete(inner)
      }

      invisible(NULL)
    },
    error = function(e) {
      # Best-effort cleanup of partial output and bad zip
      dat_dir <- fs::path_ext_remove(.x)
      if (fs::dir_exists(dat_dir)) {
        .safe_delete(dat_dir)
      }
      .safe_delete(.x)

      cli::cli_abort(
        "There was an issue with the downloaded file.
         I've deleted this bad zip and any partial extract; please retry.",
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
