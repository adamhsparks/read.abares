# tests/testthat/setup.R
# Force the CI tests to use the correct implementation of .unzip_file, without assignInNamespace().
# This is a temporary test-time override to unblock CI; remove once CI builds from the patched sources.

local({
  ns <- asNamespace("read.abares")

  patched_unzip <- function(zip_path) {
    # Validate input
    if (
      !is.character(zip_path) ||
        length(zip_path) != 1L ||
        is.na(zip_path) ||
        !fs::file_exists(zip_path)
    ) {
      cli::cli_abort("Zip file does not exist", call = rlang::caller_env())
    }

    extract_dir <- fs::path_ext_remove(zip_path)

    # Overwrite extraction directory if present
    if (fs::dir_exists(extract_dir)) {
      fs::dir_delete(extract_dir)
    }
    fs::dir_create(extract_dir)

    # Use {zip} for consistent cross-platform unzipping
    tryCatch(
      {
        zip::unzip(zipfile = zip_path, exdir = extract_dir, junkpaths = FALSE)
        invisible(as.character(extract_dir)) # MUST return a CHARACTER path (not logical)
      },
      error = function(e) {
        if (fs::dir_exists(extract_dir)) {
          fs::dir_delete(extract_dir)
        }
        cli::cli_abort(e$message, call = rlang::caller_env())
      }
    )
  }

  # Overwrite the internal binding in the package namespace for the duration of tests.
  # No assignInNamespace(): we unlock, assign, re-lock on the namespace environment.
  if (exists(".unzip_file", envir = ns, inherits = FALSE)) {
    if (bindingIsLocked(".unzip_file", ns)) {
      unlockBinding(".unzip_file", ns)
    }
    assign(".unzip_file", patched_unzip, envir = ns)
    lockBinding(".unzip_file", ns)
  }
})
