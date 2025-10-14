testthat::setup({
  ns <- asNamespace("read.abares")

  patched_unzip <- function(zip_path) {
    if (
      !is.character(zip_path) ||
        length(zip_path) != 1L ||
        is.na(zip_path) ||
        !fs::file_exists(zip_path)
    ) {
      cli::cli_abort("Zip file does not exist", call = rlang::caller_env())
    }

    extract_dir <- fs::path_ext_remove(zip_path)

    if (fs::dir_exists(extract_dir)) {
      fs::dir_delete(extract_dir)
    }
    fs::dir_create(extract_dir)

    tryCatch(
      {
        zip::unzip(zipfile = zip_path, exdir = extract_dir, junkpaths = FALSE)
        invisible(as.character(extract_dir)) # CHARACTER return
      },
      error = function(e) {
        if (fs::dir_exists(extract_dir)) {
          fs::dir_delete(extract_dir)
        }
        cli::cli_abort(e$message, call = rlang::caller_env())
      }
    )
  }

  if (bindingIsLocked(".unzip_file", ns)) {
    unlockBinding(".unzip_file", ns)
  }
  assignInNamespace(".unzip_file", patched_unzip, ns = "read.abares")
  lockBinding(".unzip_file", ns)
})
