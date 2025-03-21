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
#' @returns An invisible `NULL`, called for its side-effects, clearing the
#' cached files and deleting the cache directory.
#' @export

clear_cache <- function() {
  ra_cache <- dir.exists(.find_user_cache())

  if (ra_cache) {
    unlink(.find_user_cache(), recursive = TRUE)
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
