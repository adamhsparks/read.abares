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
