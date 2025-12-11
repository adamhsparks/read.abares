# Helper: create a zip containing a minimal valid GeoTIFF
make_zip_with_tif <- function(name = "dummy.tif") {
  tmpdir <- tempdir()
  tif_file <- file.path(tmpdir, name)
  # Create a trivial raster using stars
  arr <- array(1:4, dim = c(2, 2))
  st <- stars::st_as_stars(arr)
  stars::write_stars(st, tif_file)
  zipfile <- tempfile(fileext = ".zip")
  zip::zipr(zipfile, files = tif_file)
  list(zipfile = zipfile, tif = name)
}

test_that("read_clum_stars returns a stars object when x is provided", {
  files <- make_zip_with_tif("direct.tif")
  result <- read_clum_stars(x = files$zipfile, data_set = NULL)
  expect_s3_class(result, "stars")
  # Check dimensions
  expect_equal(unname(dim(result)), c(2, 2))
  # Check dimension names
  expect_equal(names(dim(result)), c("x", "y"))
})

test_that("read_clum_stars works with mocked .get_lum_files", {
  files <- make_zip_with_tif("mocked.tif")
  fake_get_lum_files <- function(x, data_set, lum) {
    list(file_path = files$zipfile, tiff = files$tif)
  }
  with_mocked_bindings(
    result <- read_clum_stars(data_set = "clum_50m_2023_v2"),
    .get_lum_files = fake_get_lum_files
  )
  expect_s3_class(result, "stars")
  expect_equal(unname(dim(result)), c(2, 2))
  expect_equal(names(dim(result)), c("x", "y"))
})

test_that("read_clum_stars propagates errors from .get_lum_files", {
  fake_get_lum_files <- function(x, data_set, lum) {
    cli::cli_abort("fake error")
  }
  expect_error(
    with_mocked_bindings(
      read_clum_stars(data_set = "clum_50m_2023_v2"),
      .get_lum_files = fake_get_lum_files
    ),
    "fake error"
  )
})

test_that("read_clum_stars passes ... to stars::read_stars", {
  files <- make_zip_with_tif("rat.tif")
  fake_get_lum_files <- function(x, data_set, lum) {
    list(file_path = files$zipfile, tiff = files$tif)
  }
  with_mocked_bindings(
    result <- read_clum_stars(data_set = "clum_50m_2023_v2", RAT = "category"),
    .get_lum_files = fake_get_lum_files
  )
  expect_s3_class(result, "stars")
  expect_equal(unname(dim(result)), c(2, 2))
  expect_equal(names(dim(result)), c("x", "y"))
})
