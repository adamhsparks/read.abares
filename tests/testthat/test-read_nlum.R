make_zip_with_tif <- function(name = "dummy.tif") {
  tmpdir <- tempdir()
  tif_file <- file.path(tmpdir, name)
  # Create a trivial raster using terra
  r <- terra::rast(nrows = 2, ncols = 2, vals = 1:4)
  terra::writeRaster(r, tif_file, overwrite = TRUE, filetype = "GTiff")
  zipfile <- tempfile(fileext = ".zip")
  zip::zipr(zipfile, files = tif_file)
  list(zipfile = zipfile, tif = name)
}

## -----------------------------
## Tests for read_nlum_stars
test_that("read_nlum_stars returns a stars object when x is provided", {
  files <- make_zip_with_tif("nlum_direct.tif")
  fake_get_lum_files <- function(x, data_set, lum) {
    list(file_path = files$zipfile, tiff = files$tif)
  }
  with_mocked_bindings(
    result <- read_nlum_stars(x = files$zipfile, data_set = NULL),
    .get_lum_files = fake_get_lum_files
  )
  expect_s3_class(result, "stars")
  expect_identical(unname(dim(result)), c(2L, 2L))
})

test_that("read_nlum_stars works with mocked .get_lum_files and data_set", {
  files <- make_zip_with_tif("nlum_mocked.tif")
  fake_get_lum_files <- function(x, data_set, lum) {
    list(file_path = files$zipfile, tiff = files$tif)
  }
  with_mocked_bindings(
    result <- read_nlum_stars(data_set = "nlum_2023"),
    .get_lum_files = fake_get_lum_files
  )
  expect_s3_class(result, "stars")
})

test_that("read_nlum_stars propagates errors from .get_lum_files", {
  fake_get_lum_files <- function(x, data_set, lum) {
    cli::cli_abort("fake error")
  }
  expect_error(
    with_mocked_bindings(
      read_nlum_stars(data_set = "nlum_2023"),
      .get_lum_files = fake_get_lum_files
    ),
    "fake error"
  )
})

test_that("read_nlum_stars passes ... to stars::read_stars", {
  files <- make_zip_with_tif("nlum_rat.tif")
  fake_get_lum_files <- function(x, data_set, lum) {
    list(file_path = files$zipfile, tiff = files$tif)
  }
  with_mocked_bindings(
    result <- read_nlum_stars(data_set = "nlum_2023", proxy = TRUE),
    .get_lum_files = fake_get_lum_files
  )
  # Instead of attr(), check class
  expect_s3_class(result, "stars_proxy")
})

## -----------------------------
## Tests for read_nlum_terra
test_that("read_nlum_terra returns a SpatRaster when x is provided", {
  files <- make_zip_with_tif("nlum_direct.tif")
  fake_get_lum_files <- function(x, data_set, lum) {
    list(file_path = files$zipfile, tiff = files$tif)
  }
  with_mocked_bindings(
    result <- read_nlum_terra(x = files$zipfile, data_set = NULL),
    .get_lum_files = fake_get_lum_files
  )
  expect_s4_class(result, "SpatRaster")
  expect_identical(dim(result), c(2, 2, 1))
})

test_that("read_nlum_terra works with mocked .get_lum_files and data_set", {
  files <- make_zip_with_tif("nlum_mocked.tif")
  fake_get_lum_files <- function(x, data_set, lum) {
    list(file_path = files$zipfile, tiff = files$tif)
  }
  with_mocked_bindings(
    result <- read_nlum_terra(data_set = "nlum_2023"),
    .get_lum_files = fake_get_lum_files
  )
  expect_s4_class(result, "SpatRaster")
})

test_that("read_nlum_terra propagates errors from .get_lum_files", {
  fake_get_lum_files <- function(x, data_set, lum) {
    cli::cli_abort("fake error")
  }
  expect_error(
    with_mocked_bindings(
      read_nlum_terra(data_set = "nlum_2023"),
      .get_lum_files = fake_get_lum_files
    ),
    "fake error"
  )
})

test_that("read_nlum_terra returns correct number of layers", {
  files <- make_zip_with_tif("nlum_layers.tif")
  fake_get_lum_files <- function(x, data_set, lum) {
    list(file_path = files$zipfile, tiff = files$tif)
  }
  with_mocked_bindings(
    result <- read_nlum_terra(data_set = "nlum_2023"),
    .get_lum_files = fake_get_lum_files
  )
  expect_identical(terra::nlyr(result), 1)
})
