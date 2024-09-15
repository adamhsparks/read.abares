
#' List the File Path to Users' Cache Directory
#'
#' Check what files exist in your \pkg{agfd} file cache.  This function will
#' always return full file names, *i.e.*, the directory path is prepended.  See
#' the help file for `list.files()` for more on the `full.names` argument. If
#' you wish to strip the file path and only return the directory or filenames,
#' use `basename()`. See examples for more.
#'
#' @param recursive `Boolean` value indicating whether or not to list files in
#'  subdirectories of the cache directory. Defaults to `FALSE` returning only
#'  the top-level directories contained in the cache directory.
#'
#' @examples
#' # list directories in cache only
#' inspect_cache()
#'
#' # list directory names, stripping the file path
#' basename(inspect_cache)
#'
#' # list all files in subdirectories of the cache
#' inspect_cache(recursive = TRUE)
#'
#' # list all files in subdirectories, stripping the file path
#' basename(inspect_cache(recursive_true))
#'
#'
#' @return A `list` of directories or files in the cache
#' @export

inspect_cache <- function(recursive = FALSE) {
  f <- .find_user_cache()
  if (recursive) {
    f <- list.files(f, recursive = TRUE, full.names = TRUE)
  } else {
    f <- list.files(f, full.names = TRUE)
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
