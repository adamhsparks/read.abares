#' Remove the user's cache directory and all cached files
#'
#' Removes the cache and all files in the \pkg{read.abares} cache if any exist.
#'
#' @examples
#' # not run because cached files shouldn't exist on CRAN or testing envs
#' \dontrun{
#' clear_cache()
#' }
#' @family cache
#' @returns An ivisible `NULL`, called for its side-effects, clearing the cached
#' files.
#' @export

clear_cache <- function() {
  ra_cache <- fs::dir_exists(.find_user_cache())

  if (ra_cache) {
    fs::dir_delete(names(ra_cache))
  } else {
    cli::cli_inform(
      c(
        "There do not appear to be any files cached for {.pkg {{read.abares}}}
        that need to be cleared at this time."
      )
    )
  }
  return(invisible(NULL))
}
