# Helper: create a zip containing a minimal valid GeoTIFF
make_zip_with_tif <- function(name = "dummy.tif") {
  tmpdir <- tempdir()
  tif_file <- file.path(tmpdir, name)
  # Create a trivial raster using stars, then write to GeoTIFF
  arr <- array(1:4, dim = c(2, 2))
  st <- stars::st_as_stars(arr)
  stars::write_stars(st, tif_file)
  zipfile <- tempfile(fileext = ".zip")
  zip::zipr(zipfile, files = tif_file)
  list(zipfile = zipfile, tif = name)
}

test_that("read_clum_terra returns a SpatRaster when x is provided", {
  files <- make_zip_with_tif("direct.tif")
  result <- read_clum_terra(x = files$zipfile, data_set = NULL)
  expect_s4_class(result, "SpatRaster")
  # Check dimensions (nrow, ncol)
  expect_equal(dim(result), c(2, 2, 1)) # rows, cols, layers
  # Check names of dimensions (terra uses nlyr for layers)
  expect_equal(terra::nrow(result), 2)
  expect_equal(terra::ncol(result), 2)
})

test_that("read_clum_terra works with mocked .get_lum_files", {
  files <- make_zip_with_tif("mocked.tif")
  fake_get_lum_files <- function(x, data_set, lum) {
    list(file_path = files$zipfile, tiff = files$tif)
  }
  with_mocked_bindings(
    result <- read_clum_terra(data_set = "clum_50m_2023_v2"),
    .get_lum_files = fake_get_lum_files
  )
  expect_s4_class(result, "SpatRaster")
  expect_equal(dim(result), c(2, 2, 1))
})

test_that("read_clum_terra propagates errors from .get_lum_files", {
  fake_get_lum_files <- function(x, data_set, lum) {
    cli::cli_abort("fake error")
  }
  expect_error(
    with_mocked_bindings(
      read_clum_terra(data_set = "clum_50m_2023_v2"),
      .get_lum_files = fake_get_lum_files
    ),
    "fake error"
  )
})

test_that("read_clum_terra passes ... to terra::rast", {
  files <- make_zip_with_tif("rat.tif")
  fake_get_lum_files <- function(x, data_set, lum) {
    list(file_path = files$zipfile, tiff = files$tif)
  }
  with_mocked_bindings(
    result <- read_clum_terra(data_set = "clum_50m_2023_v2"),
    .get_lum_files = fake_get_lum_files
  )
  expect_s4_class(result, "SpatRaster")
  expect_equal(dim(result), c(2, 2, 1))
})
