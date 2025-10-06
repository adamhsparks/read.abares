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
