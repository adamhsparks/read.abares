
#' Find the File Path to Users' Cache Directory
#'
#' @return A `character` string value of a file path indicating the proper
#'  directory to use for cached files
#' @noRd
#' @keywords Internal
.find_user_cache <- function() {
  tools::R_user_dir(package = "abares", which = "cache")
}
