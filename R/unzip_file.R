#' Unzip a zip file
#'
#' Unzips the provided zip file into a folder named after the zip (without .zip).
#' If unzipping fails, it will return an error and delete the corrupted zip file.
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
      .safe_delete(.x)
      cli::cli_abort(
        "There was an issue with the downloaded file.
        I've deleted this bad zip; please retry.",
        call = rlang::caller_env()
      )
    }
  )
}
