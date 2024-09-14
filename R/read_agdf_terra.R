#' Read AGDF NCDF Files
#' @param files A list of NetCDF files to import
#' @return a \CRANpkg{terra} [terra::rast] object of the Australian Gridded Farm
#'  Data

read_agdf_terra <- function(class, files) {
    r <- terra::rast(files)
}
