
#' List the File Path to Users' Cache Directory
#'
#' @param recursive `Boolean` value indicating whether or not to list files in
#'  subdirectories of the cache directory. Defaults to `FALSE`.
#' @return A `character` string value of a file path indicating the proper
#'  directory to use for cached files
#' @noRd
#' @keywords Internal

inspect_cache <- function(recursive = FALSE) {
  f <- .find_user_cache()
  if (recursive) {
    f <- list.files(f, recursive = TRUE)
  } else {
    f <- list.files(f)
  }

  if (length(f > 0)) {
    return(f)
  } else {
    cli::cli_inform(
      c(
        "There do not appear to be any files cached for {.pkg {{agdf}}}.
        You can download and cache files using {.fn get_agdf} and setting
        {.code cache = TRUE}."
      )
    )
  }
}
