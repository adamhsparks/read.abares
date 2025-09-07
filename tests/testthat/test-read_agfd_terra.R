# tests/testthat/test-read_agfd_terra.R

skip_if_not("read_agfd_terra" %in% ls(getNamespace("read.abares")))
testthat::skip_if_not_installed("terra")

# Build a real in-memory SpatRaster so terra S4 ops (e.g., coltab<-) work
build_dummy_spatraster <- function() {
  r <- terra::rast(nrows = 1, ncols = 2, vals = c(1, 2))
  terra::crs(r) <- "EPSG:4326"
  r
}

test_that("AGFD terra: x=NULL => mocked download + .unzip_file + terra::rast (real SpatRaster)", {
  r0 <- build_dummy_spatraster()

  # Pretend we "extracted" here; we won't actually unzip, just return this dir.
  exdir <- withr::local_tempdir()
  # The reader will list a raster-like file; give it a plausible .tif path
  fake_tif <- file.path(exdir, "agfd.tif")
  writeLines("tif-bytes", fake_tif) # never read from disk, terra::rast is mocked

  testthat::local_mocked_bindings(
    # No real network; just satisfy the API
    .retry_download = function(url, .f) {
      writeLines("zip-placeholder", .f) # path exists; contents irrelevant
      invisible(NULL)
    },
    # <<< KEY PART: bypass real utils::unzip entirely >>>
    .unzip_file = function(.x) exdir
  )

  # After "unzip", make any file listing yield our fake tif
  testthat::local_mocked_bindings(
    dir_ls = function(...) fake_tif,
    .package = "fs"
  )

  # Return our real in-memory SpatRaster so downstream terra code works
  testthat::local_mocked_bindings(
    rast = function(x, ...) r0,
    .package = "terra"
  )

  out <- read_agfd_terra()
  expect_true(inherits(out, "SpatRaster") || is.list(out))
})
