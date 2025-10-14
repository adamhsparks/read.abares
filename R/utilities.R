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

.safe_delete <- function(file_path) {
  # Return TRUE even if 'path' doesn't exist
  if (!fs::file_exists(file_path) && !fs::dir_exists(file_path)) {
    return(TRUE)
  }

  # Try to delete; return TRUE on success, FALSE on failure
  tryCatch(
    {
      if (fs::dir_exists(file_path)) {
        fs::dir_delete(file_path)
      } else {
        fs::file_delete(file_path)
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
#'

.unzip_file <- function(.x) {
  # Validate input (return a CHARACTER path, not logical)
  if (
    !is.character(.x) ||
      length(.x) != 1L ||
      is.na(.x) ||
      !fs::file_exists(.x)
  ) {
    cli::cli_abort("Zip file does not exist", call = rlang::caller_env())
  }

  extract_dir <- fs::path_ext_remove(.x)

  # Overwrite extraction directory
  if (fs::dir_exists(extract_dir)) {
    fs::dir_delete(extract_dir)
  }
  fs::dir_create(extract_dir)

  # Use {zip} for consistent cross-platform unzipping
  tryCatch(
    {
      zip::unzip(zipfile = .x, exdir = extract_dir, junkpaths = FALSE)
      invisible(as.character(extract_dir)) # ensure CHARACTER output
    },
    error = function(e) {
      # Roll back partial extraction and propagate ORIGINAL message
      if (fs::dir_exists(extract_dir)) {
        fs::dir_delete(extract_dir)
      }
      cli::cli_abort(e$message, call = rlang::caller_env())
    }
  )
}
