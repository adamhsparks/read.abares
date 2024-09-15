
#' Read agfd NCDF Files as a data.table
#'
#' @param files A list of NetCDF files to import
#' @return a [data.table::data.table] object of the Australian Gridded Farm Data
#'
#' @examplesIf interactive()
#' get_agfd(cache = TRUE) |>
#'   read_agfd_dt()
#'
#' @family read_agfd
#' @export

read_agfd_dt <- function(files) {
  tnc_list <- lapply(files, tidync::tidync)
  data.table::rbindlist(lapply(tnc_list, tidync::hyper_tibble))
}
