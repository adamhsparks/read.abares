#' Unzip a Zip File
#'
#' Unzips the provided zip file. If unzipping fails, it will return an error and
#'  delete the corrupted zip file.
#'
#' @param .x A zip file for unzipping
#'
#' @returns Called for its side-effects of unzipping a file, returns an
#'  invisible `NULL`.
#' @dev
.unzip_file <- function(.x) {
  tryCatch(
    {
      ex_dir <- fs::path_dir(.x)
      dat_dir <- fs::path_ext_remove(.x)
      withr::with_dir(
        fs::path_dir(.x),
        utils::unzip(.x, exdir = dat_dir, overwrite = TRUE)
      )
    },
    error = function(e) {
      fs::file_delete(.x)
      cli::cli_abort(
        "There was an issue with the downloaded file. I've deleted
           this bad version of the zip file, please retry.",
        call = rlang::caller_env()
      )
    }
  )

  return(invisible(NULL))
}
