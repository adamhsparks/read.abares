#' Remove the user's cache directory and all cached files
#'
#' Removes the cache directory and all files in the \pkg{read.abares} cache if
#' any exist locally.
#'
#' @examples
#' # not run because cached files shouldn't exist on CRAN or testing envs
#' \dontrun{
#' clear_cache()
#' }
#' @family cache
#' @returns An invisible `NULL`, called for its side-effects, clearing the
#' cached files and deleting the cache directory.
#' @export

clear_cache <- function() {
  ra_cache <- fs::dir_exists(.find_user_cache())

  if (ra_cache) {
    fs::dir_delete(.find_user_cache())
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
