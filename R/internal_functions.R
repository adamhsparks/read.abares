
#' Find the File Path to Users' Cache Directory
#'
#' @return A `character` string value of a file path indicating the proper
#'  directory to use for cached files
#' @noRd
#' @keywords Internal
.find_user_cache <- function() {
  tools::R_user_dir(package = "read.abares", which = "cache")
}

#' Check for read.abares.something S3 Class
#'
#' @param x An object for validating
#' @param class An S3 class to validate against
#'
#' @return Nothing, called for its side-effects of class validation
#' @keywords Internal
#' @noRd

.check_class <- function(x, class) {
  if (missing(x) || !inherits(x, class)) {
    cli::cli_abort(
      message = "You must provide an {.code class} object."
    )
  }
}
