#' Utility operator for NULL coalescing
#' @param x First value
#' @param y Second value (used if x is `NULL`)
#' @return `x` if not `NULL`, otherwise `y`
#' @dev
`%||%` <- function(x, y) if (is.null(x)) y else x


#' Safe file deletion helper.
#' @param file_path Path to file to delete.
#' @return Logical indicating success.
#' @dev
.safe_delete <- function(file_path) {
  if (file.exists(file_path)) {
    tryCatch(
      {
        fs::file_delete(file_path)
        TRUE
      },
      error = function(e) {
        FALSE
      }
    )
  } else {
    TRUE
  }
}
