#' Read AGDF NCDF Files
#' @param class Class of objec to return, `terra` or `stars`
#' @param files A list of NetCDF files to import
#' @return a \CRANpkg{stars} object of the Australian Gridded Farm Data

read_agdf_stars <- function(files) {
    #TODO: furrr map to read stars objects?
    s <- stars::read_ncdf(files)
}
