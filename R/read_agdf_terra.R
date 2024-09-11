#' Read AGDF NCDF Files
#' @param files A list of NetCDF files to import
#' @return

read_agdf_terra <- function(class, files) {
    r <- terra::rast(files)
}
