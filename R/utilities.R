#' Utility operator for NULL coalescing
#' @param x First value.
#' @param y Second value (used if x is `NULL`).
#' @returns `x` if not `NULL`, otherwise `y`.
#' @dev
`%||%` <- function(x, y) if (is.null(x)) y else x


#' Safe file deletion helper
#' @param file_path Path to file to delete.
#' @returns Logical indicating success.
#' @dev

.safe_delete <- function(path) {
  # Return TRUE even if 'path' doesn't exist
  if (!fs::file_exists(path) && !fs::dir_exists(path)) {
    return(TRUE)
  }

  # Try to delete; return TRUE on success, FALSE on failure
  tryCatch(
    {
      if (fs::dir_exists(path)) {
        fs::dir_delete(path)
      } else {
        fs::file_delete(path)
      }
      TRUE
    },
    error = function(e) {
      FALSE
    }
  )
}

#' Unzip a zip file
#'
#' Unzips the provided zip file into a folder named after the zip (without
#'  .zip).
#' If unzipping fails, it will return an error and delete any partially-created
#' extract directory.
#'
#' @param .x A zip file for unzipping.
#' @returns Invisible directory path, called for side effects.
#' @dev
.unzip_file <- function(zip_path) {
  # Input sanity: must be a single, non-NA character path and must exist
  if (!is.character(zip_path) || length(zip_path) != 1L || is.na(zip_path)) {
    cli::cli_abort("Zip file does not exist", call = rlang::caller_env())
  }
  if (!fs::file_exists(zip_path)) {
    cli::cli_abort("Zip file does not exist", call = rlang::caller_env())
  }

  extract_dir <- fs::path_ext_remove(zip_path)

  # Overwrite existing extraction directory
  if (fs::dir_exists(extract_dir)) {
    fs::dir_delete(extract_dir)
  }
  fs::dir_create(extract_dir)

  # Unzip and return the extraction directory path invisibly
  tryCatch(
    {
      zip::unzip(zipfile = zip_path, exdir = extract_dir, junkpaths = FALSE)
      invisible(extract_dir)
    },
    error = function(e) {
      # Roll back on failure
      if (fs::dir_exists(extract_dir)) {
        fs::dir_delete(extract_dir)
      }
      # Re-throw original message so tests can match (e.g., "Unrecognized archive format")
      cli::cli_abort(e$message, call = rlang::caller_env())
    }
  )
}
