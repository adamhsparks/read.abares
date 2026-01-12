# Helper: create a zip containing a minimal valid GeoTIFF
make_zip_with_tif <- function(name = "dummy.tif") {
  tmpdir <- fs::path_temp()
  tif_file <- file.path(tmpdir, name)
  # Create a trivial raster using stars, then write to GeoTIFF
  arr <- array(1:4, dim = c(2, 2))
  st <- stars::st_as_stars(arr)
  stars::write_stars(st, tif_file)
  zipfile <- tempfile(fileext = ".zip")
  # Normalize the zipfile path for Windows
  zipfile <- normalizePath(zipfile, winslash = "/", mustWork = FALSE)
  zip::zipr(zipfile, files = tif_file)
  list(zipfile = zipfile, tif = name)
}

## ---- Tests for read_clum_terra ----
test_that("read_clum_terra returns a SpatRaster when x is provided", {
  files <- make_zip_with_tif("direct.tif")
  result <- read_clum_terra(x = files$zipfile, data_set = NULL)
  expect_s4_class(result, "SpatRaster")
  expect_identical(dim(result), c(2, 2, 1))
  expect_identical(terra::nrow(result), 2)
  expect_identical(terra::ncol(result), 2)
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
  expect_identical(dim(result), c(2, 2, 1))
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
  expect_identical(dim(result), c(2, 2, 1))
})

## ---- Tests for read_clum_stars ----
test_that("read_clum_stars returns a stars object when x is provided", {
  files <- make_zip_with_tif("direct.tif")
  result <- read_clum_stars(x = files$zipfile, data_set = NULL)
  expect_s3_class(result, "stars")
  expect_identical(unname(dim(result)), c(2L, 2L))
  expect_named(dim(result), c("x", "y"))
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
  expect_identical(unname(dim(result)), c(2L, 2L))
  expect_named(dim(result), c("x", "y"))
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
  expect_identical(unname(dim(result)), c(2L, 2L))
  expect_named(dim(result), c("x", "y"))
})

## ---- Tests for CLUM metadata helpers ----
test_that(".set_clum_update_levels returns a list with correct components", {
  res <- .set_clum_update_levels()
  expect_type(res, "list")
  expect_named(res, c("date_levels", "update_levels", "scale_levels"))
  expect_s3_class(res$date_levels, "data.table")
  expect_s3_class(res$update_levels, "data.table")
  expect_s3_class(res$scale_levels, "data.table")
})

test_that("date_levels has correct years", {
  dl <- .set_clum_update_levels()$date_levels
  expect_identical(dl$int, 2008L:2023L)
  expect_identical(dl$rast_cat, 2008L:2023L)
  expect_identical(nrow(dl), 16L)
})

test_that("update_levels has correct categories", {
  ul <- .set_clum_update_levels()$update_levels
  expect_identical(ul$int, 0:1)
  expect_identical(
    ul$rast_cat,
    c("Not Updated", "Updated Since CLUM Dec. 2020 Release")
  )
  expect_identical(nrow(ul), 2L)
})

test_that("scale_levels has correct scales", {
  sl <- .set_clum_update_levels()$scale_levels
  expect_identical(
    sl$int,
    c(5000L, 10000L, 20000L, 25000L, 50000L, 100000L, 250000L)
  )
  expect_identical(
    sl$rast_cat,
    c(
      "1:5,000",
      "1:10,000",
      "1:20,000",
      "1:25,000",
      "1:50,000",
      "1:100,000",
      "1:250,000"
    )
  )
  expect_identical(nrow(sl), 7L)
})

test_that(".create_clum_50m_coltab loads a data.table from Rds file", {
  ct <- .create_clum_50m_coltab()
  expect_s3_class(ct, "data.table")
  expect_named(ct, c("value", "color"))
  expect_type(ct$value, "integer")
  expect_type(ct$color, "character")
  expect_gt(nrow(ct), 0)
  expect_identical(ct$value[1], 0L)
  expect_identical(ct$color[1], "#ffffff")
  expect_true(all(grepl("^#[0-9A-Fa-f]{6}$", ct$color)))
})
