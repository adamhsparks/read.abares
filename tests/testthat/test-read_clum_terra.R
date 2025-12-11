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

test_that(".set_clum_update_levels returns a list with correct components", {
  res <- .set_clum_update_levels()

  # Check it's a list with named elements
  expect_type(res, "list")
  expect_named(res, c("date_levels", "update_levels", "scale_levels"))

  # Each element should be a data.table
  expect_s3_class(res$date_levels, "data.table")
  expect_s3_class(res$update_levels, "data.table")
  expect_s3_class(res$scale_levels, "data.table")
})

test_that("date_levels has correct years", {
  res <- .set_clum_update_levels()
  dl <- res$date_levels

  expect_equal(dl$int, 2008L:2023L)
  expect_equal(dl$rast_cat, 2008L:2023L)
  expect_equal(nrow(dl), 16)
})

test_that("update_levels has correct categories", {
  res <- .set_clum_update_levels()
  ul <- res$update_levels

  expect_equal(ul$int, 0:1)
  expect_equal(
    ul$rast_cat,
    c("Not Updated", "Updated Since CLUM Dec. 2020 Release")
  )
  expect_equal(nrow(ul), 2)
})

test_that("scale_levels has correct scales", {
  res <- .set_clum_update_levels()
  sl <- res$scale_levels

  expect_equal(
    sl$int,
    c(5000L, 10000L, 20000L, 25000L, 50000L, 100000L, 250000L)
  )
  expect_equal(
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
  expect_equal(nrow(sl), 7)
})


test_that(".create_clum_50m_coltab loads a data.table from Rds file", {
  # Call the function
  ct <- .create_clum_50m_coltab()

  # Check class
  expect_s3_class(ct, "data.table")

  # Check column names
  expect_named(ct, c("value", "color"))

  # Check column types
  expect_type(ct$value, "integer")
  expect_type(ct$color, "character")

  # Ensure non-empty
  expect_gt(nrow(ct), 0)

  # Spot check: first row should be value 0 and color "#ffffff"
  expect_equal(ct$value[1], 0L)
  expect_equal(ct$color[1], "#ffffff")

  # All colors should look like hex codes
  expect_true(all(grepl("^#[0-9A-Fa-f]{6}$", ct$color)))
})
