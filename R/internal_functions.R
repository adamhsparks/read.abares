
#' Find the File Path to Users' Cache Directory
#'
#' @return A `character` string value of a file path indicating the proper
#'  directory to use for cached files
#' @noRd
#' @keywords Internal
#' @autoglobal
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
#' @autoglobal
#' @noRd

.check_class <- function(x, class) {
  if (missing(x) || !inherits(x, class)) {
    cli::cli_abort(
      message = "You must provide a {.code read.abares} class object."
    )
  }
}

#' Create curl Handles
#'
#' @return a \CRANpkg{curl} handle for use in downloading files
#' @noRd
#' @keywords Internal
create_handle <- function() {
  h <- curl::new_handle()
  curl::handle_setopt(
    handle = h,
    TCP_KEEPALIVE = 200000,
    CONNECTTIMEOUT = 90,
    http_version = 2
  )
}
