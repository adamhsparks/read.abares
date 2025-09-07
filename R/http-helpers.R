#' Internal HTTP performer (shim for httr2::req_perform)
#'
#' All network I/O flows through this binding so tests can safely mock it.
#' @keywords internal
#' @noRd
.perform_request <- httr2::req_perform
