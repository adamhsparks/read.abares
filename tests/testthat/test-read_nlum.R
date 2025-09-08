test_that("read_nlum_stars returns a named list of SpatRaster objects", {
  # Create dummy raster files
  temp_dir <- tempdir()
  file_paths <- file.path(temp_dir, paste0("stars_", 1L:2L, ".tif"))
  for (f in file_paths) {
    terra::writeRaster(
      terra::rast(matrix(runif(100L), 10L, 10L)),
      f,
      overwrite = TRUE
    )
  }

  result <- read_nlum_stars(file_paths)

  expect_type(result, "list")
  expect_true(all(purrr::map_lgl(result, ~ inherits(.x, "SpatRaster"))))
  expect_named(result, basename(file_paths))
})

test_that("read_nlum_terra returns a named list of SpatRaster objects", {
  skip_if_not_installed("terra")
  skip_if_not_installed("purrr")

  # Create dummy raster files
  temp_dir <- tempdir()
  file_paths <- file.path(temp_dir, paste0("terra_", 1L:2L, ".tif"))
  for (f in file_paths) {
    terra::writeRaster(terra::rast(matrix(runif(100L), 10L, 10L)), f)
  }

  result <- read_nlum_terra(file_paths)

  expect_type(result, "list")
  expect_true(all(purrr::map_lgl(result, ~ inherits(.x, "SpatRaster"))))
  expect_named(result, basename(file_paths))
})
