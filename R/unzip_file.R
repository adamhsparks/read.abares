#' Unzip a Zip File
#'
#' Unzips the provided zip file. If unzipping fails, it will return an error and
#'  delete the corrupted zip file.
#'
#' @param .file A zip file for unzipping
#'
#' @returns Called for its side-effects of unzipping a file, returns an
#'  invisible `NULL`.
#' @dev
.unzip_file <- function(.file) {
  tryCatch(
    {
      ex_dir <- fs::path_dir(.file)
      dat_dir <- fs::path_ext_remove(.file)
      withr::with_dir(
        fs::path_dir(.file),
        utils::unzip(.file, exdir = dat_dir, overwrite = TRUE)
      )
    },
    error = function(e) {
      fs::file_delete(.file)
      cli::cli_abort(
        "There was an issue with the downloaded file. I've deleted
           this bad version of the zip file, please retry.",
        call = rlang::caller_env()
      )
    }
  )

  return(invisible(NULL))
}
