
#' Read AGFD NCDF Files as a data.table
#'
#' Read Australian Gridded Farm Data, (\acronym{AGFD}) as a [data.table] object.
#'
#' @inherit get_agfd details
#'
#' @param files A list of \acronym{AGFD} NetCDF files to import
#'
#' @inheritSection get_agfd Data Layers
#'
#' @return a [data.table::data.table] object of the Australian Gridded Farm Data
#'
#' @examplesIf interactive()
#' get_agfd(cache = TRUE) |>
#'   read_agfd_dt()
#'
#' @inherit get_agfd references
#' @family AGFD
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
