# Test with no caching enabled

withr::local_options(read.abares.cache_location = tempdir())
withr::local_options(read.abares.cache = FALSE)

# test reading with stars ----

test_that("read_topsoil_thickness_stars returns a stars object", {
  skip_if_offline()
  skip_on_ci()
  x <- read_topsoil_thickness_stars()
  expect_s3_class(x, "stars")
  expect_named(x, "thpk_1.tif")
})

# test reading with terra ----

test_that("read_topsoil_thickness_terra returns a terra object", {
  skip_if_offline()
  skip_on_ci()
  x <- read_topsoil_thickness_terra()
  expect_s4_class(x, "SpatRaster")
  expect_named(x, "thpk_1")
})

withr::deferred_run()

# test with caching enabled
withr::local_options(read.abares.cache_location = tempdir())
withr::local_options(read.abares.cache = TRUE)

# test reading with stars ----

test_that("read_topsoil_thickness_stars returns a stars object", {
  skip_if_offline()
  skip_on_ci()
  x <- read_topsoil_thickness_stars()
  expect_s3_class(x, "stars")
  expect_named(x, "thpk_1.tif")
})

# test reading with terra ----

test_that("read_topsoil_thickness_terra returns a terra object", {
  skip_if_offline()
  skip_on_ci()
  x <- read_topsoil_thickness_terra()
  expect_s4_class(x, "SpatRaster")
  expect_named(x, "thpk_1")
})

clear_cache()

withr::deferred_run()
