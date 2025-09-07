# Reusable helpers for raster/stars tests (no network, minimal memory)

# Build a real in-memory SpatRaster so terra S4 methods (e.g., coltab<-) work.
build_dummy_spatraster <- function() {
  stopifnot(requireNamespace("terra", quietly = TRUE))
  r <- terra::rast(nrows = 1, ncols = 2, vals = c(1, 2))
  terra::crs(r) <- "EPSG:4326"
  r
}

# A tiny stars-like object; most tests just check class/shape
build_dummy_stars <- function() {
  stopifnot(requireNamespace("stars", quietly = TRUE))
  stars::st_as_stars(matrix(1:4, nrow = 2))
}
