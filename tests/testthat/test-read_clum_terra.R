# tests/testthat/test-read_clum_terra.R

skip_if_not("read_clum_terra" %in% ls(getNamespace("read.abares")))
testthat::skip_if_not_installed("terra")

test_that("CLUM: x = NULL => download mocked; unzip + terra::rast mocked to return a real SpatRaster", {
  # 1) Build a tiny, real SpatRaster in memory (no files, no internet)
  r0 <- terra::rast(nrows = 1, ncols = 2, vals = c(1, 2))
  terra::crs(r0) <- "EPSG:4326" # not strictly necessary, but harmless

  # 2) Create a fake unzip directory and a fake .tif "found" by fs::dir_ls()
  exdir <- withr::local_tempdir()
  fake_tif <- file.path(exdir, "clum.tif")
  writeLines("tif-bytes", fake_tif) # never actually read; terra::rast is mocked

  # 3) Mock the download/unzip/list steps (no real IO)
  testthat::local_mocked_bindings(
    .retry_download = function(url, .f) {
      writeLines("zip", .f)
      invisible(NULL)
    },
    .unzip_file = function(x) exdir
  )
  testthat::local_mocked_bindings(
    dir_ls = function(...) fake_tif,
    .package = "fs"
  )

  # 4) Most important: mock terra::rast to return our *real* SpatRaster object
  #    This avoids the S4 slot (@pntr) error inside terra when coltab<- is applied.
  testthat::local_mocked_bindings(
    rast = function(x, ...) r0,
    .package = "terra"
  )

  # 5) Run the function under test
  out <- read_clum_terra(data_set = "clum_50m_2023_v2")

  # 6) Assertions
  #    Depending on your function, out should be a real SpatRaster or a derived object.
  expect_true(inherits(out, "SpatRaster") || is.list(out))
})
