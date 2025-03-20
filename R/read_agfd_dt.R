#' Read 'Australian Gridded Farm Data' (AGFD) NCDF files as a data.table
#'
#' Read Australian Gridded Farm Data, (\acronym{AGFD}) as a
#'  [data.table::data.table] object.
#'
#' @inherit get_agfd details
#' @inheritSection get_agfd Model scenarios
#' @inheritSection get_agfd Data files
#' @inheritSection get_agfd Data layers
#' @inherit get_agfd references
#' @param files A list of \acronym{AGFD} NetCDF files to import.
#'
#' @returns a [data.table::data.table] object of the 'Australian Gridded Farm
#'  Data'.
#'
#' @examplesIf interactive()
#'
#' # using piping, which can use the {read.abares} cache after the first DL
#'
#' get_agfd(cache = TRUE) |>
#'   read_agfd_dt()
#'
#' @family AGFD
#' @autoglobal
#' @export

read_agfd_dt <- function(files) {
  tnc_list <- lapply(files, tidync::tidync)
  names(tnc_list) <- basename(files)
  dt <- data.table::rbindlist(
    lapply(tnc_list, tidync::hyper_tibble),
    idcol = "id"
  )
  dt[, lat := as.numeric(dt$lat)]
  dt[, lon := as.numeric(dt$lon)]
  rm(tnc_list)
  gc()
  return(dt[])
}
