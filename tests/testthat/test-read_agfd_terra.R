make_tif <- function(path, vals = 1:12, ncols = 4, nrows = 3) {
  # Create a tiny raster (EPSG:4326) and write to GeoTIFF
  r <- terra::rast(
    ncols = ncols,
    nrows = nrows,
    xmin = 0,
    xmax = ncols,
    ymin = 0,
    ymax = nrows,
    crs = "EPSG:4326"
  )
  terra::values(r) <- vals
  # Keep file small and deterministic
  terra::writeRaster(
    r,
    filename = path,
    overwrite = TRUE,
    gdal = c("COMPRESS=LZW")
  )
  normalizePath(path, winslash = "/", mustWork = TRUE)
}

test_that("read_agfd_terra validates yyyy bounds", {
  expect_error(
    read.abares::read_agfd_terra(yyyy = c(1990, 1991)),
    "must be between 1991 and 2023 inclusive"
  )
  expect_error(
    read.abares::read_agfd_terra(yyyy = c(2023, 2024)),
    "must be between 1991 and 2023 inclusive"
  )
})

test_that("read_agfd_terra integrates: calls .get_agfd, reads real GeoTIFFs, returns named list of SpatRaster (fixed prices)", {
  skip_if_offline()
  testthat::skip_if_not_installed("terra")

  # Create two actual GeoTIFFs
  f1 <- tempfile(fileext = "_x_c2020.tif")
  f2 <- tempfile(fileext = "_x_c2021.tif")
  files <- c(
    make_tif(f1, vals = 1:12),
    make_tif(f2, vals = 101:112)
  )

  # Mock only .get_agfd; do NOT mock terra::rast()
  testthat::with_mocked_bindings(
    .get_agfd = function(.fixed_prices, .yyyy, .x) {
      testthat::expect_true(.fixed_prices)
      testthat::expect_equal(.yyyy, 2020:2021)
      testthat::expect_null(.x)
      files
    },
    {
      r <- read.abares::read_agfd_terra(
        fixed_prices = TRUE,
        yyyy = 2020:2021,
        x = NULL
      )

      # Structure and names
      testthat::expect_type(r, "list")
      testthat::expect_length(r, length(files))
      testthat::expect_identical(names(r), basename(files))

      # Each element is a real SpatRaster read by terra::rast()
      testthat::expect_true(all(vapply(r, inherits, logical(1), "SpatRaster")))

      # Sanity check raster properties
      for (ri in r) {
        testthat::expect_equal(terra::nlyr(ri), 1L)
        testthat::expect_equal(terra::ncol(ri), 4L)
        testthat::expect_equal(terra::nrow(ri), 3L)
        testthat::expect_false(is.na(terra::crs(ri, proj = TRUE)))
      }

      # Check values match what we wrote (one layer)
      vals1 <- as.vector(terra::values(r[[basename(f1)]])[, 1])
      vals2 <- as.vector(terra::values(r[[basename(f2)]])[, 1])
      testthat::expect_identical(vals1, 1:12)
      testthat::expect_identical(vals2, 101:112)
    },
    .package = "read.abares"
  )
})

test_that("read_agfd_terra forwards fixed_prices = FALSE to .get_agfd and reads real rasters", {
  skip_if_offline()
  testthat::skip_if_not_installed("terra")

  f1 <- tempfile(fileext = "_y_c1995.tif")
  f2 <- tempfile(fileext = "_y_c1996.tif")
  files <- c(
    make_tif(f1, vals = rep(5L, 12)),
    make_tif(f2, vals = rep(9L, 12))
  )

  testthat::with_mocked_bindings(
    .get_agfd = function(.fixed_prices, .yyyy, .x) {
      testthat::expect_false(.fixed_prices)
      testthat::expect_equal(.yyyy, 1995:1996)
      testthat::expect_null(.x)
      files
    },
    {
      r <- read.abares::read_agfd_terra(
        fixed_prices = FALSE,
        yyyy = 1995:1996,
        x = NULL
      )

      testthat::expect_type(r, "list")
      testthat::expect_length(r, length(files))
      testthat::expect_identical(names(r), basename(files))
      testthat::expect_true(all(vapply(r, inherits, logical(1), "SpatRaster")))

      # Values
      v1 <- unique(as.vector(terra::values(r[[basename(f1)]])[, 1]))
      v2 <- unique(as.vector(terra::values(r[[basename(f2)]])[, 1]))
      testthat::expect_identical(v1, 5L)
      testthat::expect_identical(v2, 9L)
    },
    .package = "read.abares"
  )
})

test_that("read_agfd_terra forwards x to .get_agfd and reads real raster", {
  skip_if_offline()
  testthat::skip_if_not_installed("terra")

  fake_zip <- file.path(tempdir(), "some_agfd.zip")
  f1 <- tempfile(fileext = "_z_c2022.tif")
  files <- make_tif(f1, vals = 11:22)

  testthat::with_mocked_bindings(
    .get_agfd = function(.fixed_prices, .yyyy, .x) {
      testthat::expect_true(.fixed_prices)
      testthat::expect_equal(.yyyy, 2022)
      testthat::expect_identical(.x, fake_zip)
      files
    },
    {
      r <- read.abares::read_agfd_terra(
        fixed_prices = TRUE,
        yyyy = 2022,
        x = fake_zip
      )

      testthat::expect_type(r, "list")
      testthat::expect_length(r, 1L)
      testthat::expect_identical(names(r), basename(files))
      testthat::expect_true(inherits(r[[1]], "SpatRaster"))

      # Values sanity check
      v <- as.vector(terra::values(r[[1]])[, 1])
      testthat::expect_identical(v, 11:22)
    },
    .package = "read.abares"
  )
})

test_that("read_agfd_terra returns empty list when .get_agfd returns no files (document current behavior)", {
  skip_if_offline()

  # With character(0) input, purrr::map() yields list(), and names(list()) <- character(0)
  testthat::with_mocked_bindings(
    .get_agfd = function(...) character(),
    {
      r <- read.abares::read_agfd_terra(
        fixed_prices = TRUE,
        yyyy = 2022,
        x = NULL
      )

      testthat::expect_type(r, "list")
      testthat::expect_length(r, 0L)
      testthat::expect_identical(names(r), character(0))
    },
    .package = "read.abares"
  )
})

test_that("read_agfd_terra forwards defaults to .get_agfd (fixed_prices=TRUE, yyyy=1991:2023, x=NULL)", {
  skip_if_offline()
  testthat::skip_if_not_installed("terra")

  observed <- NULL

  # We don't need a file per year; the function reads whatever .get_agfd returns.
  f1 <- tempfile(fileext = "_default1.tif")
  f2 <- tempfile(fileext = "_default2.tif")
  ret_files <- c(make_tif(f1, vals = 1:12), make_tif(f2, vals = 21:32))

  testthat::with_mocked_bindings(
    .get_agfd = function(.fixed_prices, .yyyy, .x) {
      observed <<- list(.fixed_prices = .fixed_prices, .yyyy = .yyyy, .x = .x)
      ret_files
    },
    {
      r <- read.abares::read_agfd_terra()

      # Confirm defaults were forwarded
      testthat::expect_true(observed$.fixed_prices)
      testthat::expect_identical(observed$.yyyy, 1991:2023)
      testthat::expect_null(observed$.x)

      # Confirm reading works on the returned files
      testthat::expect_type(r, "list")
      testthat::expect_length(r, length(ret_files))
      testthat::expect_identical(names(r), basename(ret_files))
      testthat::expect_true(all(vapply(r, inherits, logical(1), "SpatRaster")))
    },
    .package = "read.abares"
  )
})
