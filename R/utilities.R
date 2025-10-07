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
  if (fs::file_exists(file_path)) {
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

.unzip_file <- function(.x) {
  # Check if zip file exists first
  if (!fs::file_exists(.x)) {
    cli::cli_abort(
      "Zip file does not exist: {.path {.x}}",
      call = rlang::caller_env()
    )
  }

  # Determine extraction directory path
  dat_dir <- fs::path_ext_remove(.x) # deterministic extract folder

  # Clean up any existing extraction directory first
  if (fs::dir_exists(dat_dir)) {
    .safe_delete(dat_dir)
  }

  tryCatch(
    {
      # Create directory for extraction
      fs::dir_create(dat_dir, recurse = TRUE)

      # Use R's internal unzip to avoid system dependency
      unzip_result <- archive::archive_extract(
        archive = .x,
        dir = dat_dir
      )

      # If archive::archive_extract() is successful, check that unzip was
      # successful by verifying some content was extracted
      if (length(fs::dir_ls(dat_dir)) == 0L) {
        cli::cli_abort("No files were extracted from the zip archive")
      }

      invisible(dat_dir)
    },
    error = function(e) {
      # Clean up extraction directory if it was created but extraction failed
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
