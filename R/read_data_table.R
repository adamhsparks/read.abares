
#' Read AGDF NCDF Files as a data.table
#'
#' @param files A list of NetCDF files to import
#' @return a `list` of \CRANpkg{tidync} [tidync::tidync] objects of the
#'  Australian Gridded Farm Data
#'
#' @examplesIf interactive()
#' get_agfd(cache = TRUE) |>
#'   read_agdf_dt()
#'
#' @family read_agdf
#' @export

read_agdf_dt <- function(files) {
  tnc_list <- lapply(files, tidync::tidync)
  data.table::rbindlist(lapply(tnc_list, tidync::hyper_tibble))
}
