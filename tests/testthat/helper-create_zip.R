create_zip <- function(zip_path, files_dir, files_rel) {
  if (!nzchar(Sys.which("zip"))) {
    testthat::skip("System 'zip' utility not available for utils::zip()")
  }

  withr::with_dir(files_dir, {
    utils::zip(zipfile = zip_path, files = files_rel, flags = "-r9Xq")
  })

  invisible(zip_path)
}
