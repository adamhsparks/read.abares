#' Check CLUM inputs for stars and terra
#'
#' @param data_set A user provided string value.
#' @param x A user provided string value.
#' @returns A `list` object containing a validated `data_set` value and `x`
#'  object (a geotiff object file path for importing).
#'
#' @dev

.check_clum_inputs <- function(data_set, x) {
  if (length(data_set) != 1L || !is.character(data_set) || is.na(data_set)) {
    cli::cli_abort("{.var data_set} must be a single character string value.")
  }
  data_set <- rlang::arg_match0(
    data_set,
    c("clum_50m_2023_v2", "scale_date_update")
  )
  x <- switch(
    is.null(x),
    .get_clum(.data_set = data_set),
    .copy_local_clum_zip(x)
  )
  return(list("data_set" = data_set, "x" = x))
}
