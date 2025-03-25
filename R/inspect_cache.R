#' List the directories and files in your cache directory
#'
#' Check what files exist in your \pkg{read.abares} file cache.  This function
#' will always return full file names, *i.e.*, the directory path is prepended
#' by default.  See the help file for `fs::dir_ls()` for more on returning full
#' paths.  If you wish to strip the full path and only return the directory or
#' file names, see [fs::path_file] or [fs::path_dir]. See examples for more.
#'
#' @param recurse `Boolean` value indicating whether or not to [fs::dir_ls] in
#'  subdirectories of the cache directory. Defaults to `FALSE` returning only
#'  the top-level directories and files contained in the cache directory.
#'
#' @examples
#' # not run because cached files shouldn't exist on CRAN or testing envs
#' \dontrun{
#' # list directories in cache only
#' inspect_cache()
#'
#' # list directory names, stripping the fs::path_file
#' basename(inspect_cache)
#'
#' # list all files in subdirectories of the cache
#' inspect_cache(recurse = TRUE)
#'
#' # list all files in subdirectories, stripping the [fs::path_file]
#' library(fs)
#' path_file(inspect_cache(recurse = TRUE))
#' }
#' @family cache
#' @returns An [fs::path] object containing directories or files in the cache.
#' @export

inspect_cache <- function(recurse = FALSE) {
  f <- .find_user_cache()
  if (recurse) {
    f <- fs::dir_ls(fs::path_abs(f), recurse = TRUE)
  } else {
    f <- fs::dir_ls(fs::path_abs(f))
  }

  if (length(f) < 1) {
    return(cli::cli_inform(
      c(
        "There do not appear to be any files cached for {.pkg {{read.abares}}}."
      )
    ))
  } else {
    cli::cli_h1("Locally Available {{read.abares}} Cached Files")
    cli::cli_ul(basename(f))
  }
}
