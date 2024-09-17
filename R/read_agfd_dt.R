
#' Read AGFD NCDF Files as a data.table
#'
#' Read Australian Gridded Farm Data, (\acronym{AGFD}) as a [data.table] object.
#'
#' @param files A list of NetCDF files to import
#' @return a [data.table::data.table] object of the Australian Gridded Farm Data
#'
#' @examplesIf interactive()
#' get_agfd(cache = TRUE) |>
#'   read_agfd_dt()
#'
#' @family read_agfd
#' @autoglobal
#' @export

read_agfd_dt <- function(files) {
  tnc_list <- lapply(files, tidync::tidync)
  names(tnc_list) <- basename(files)
  dt <- data.table::rbindlist(lapply(tnc_list, tidync::hyper_tibble),
                              idcol = "id")
  dt[, lat := as.numeric(dt$lat)]
  dt[, lon := as.numeric(dt$lon)]
  rm(tnc_list)
  gc()
  return(dt[])
}
