
#' Remove Files in Users' Cache Directory
#'
#' Removes all files in the \pkg{read.abares} cache if any exist.
#'
#' @examples
#' # not run because cached files shouldn't exist on CRAN or testing envs
#' \dontrun{
#' clear_cache()
#' }
#' @family cache
#' @return Nothing, called for its side-effects, clearing the cached files
#' @export

clear_cache <- function() {
  f <- list.files(.find_user_cache(),
                  recursive = TRUE,
                  full.names = TRUE)

  if (length(f) > 0L) {
    unlink(.find_user_cache(), recursive = TRUE, force = TRUE)
  } else {
    cli::cli_inform(
      c(
        "There do not appear to be any files cached for {.pkg {{read.abares}}}
        that need to be cleared at this time."
      )
    )
  }
}
