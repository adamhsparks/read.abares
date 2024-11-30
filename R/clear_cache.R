
#' Remove Files in Users' Cache Directory
#'
#' Removes all files in the \pkg{read.abares} cache if they exist.
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
  f <- .find_user_cache()

  if (unlink(f, recursive = TRUE, force = FALSE) == 0)
    return(invisible(TRUE))
  cli::cli_inform(
    c(
      "There do not appear to be any files cached for {.pkg {{read.abares}}}
        that need to be cleared at this time."
    )
  )
}
