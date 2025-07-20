# There are two files for this function due to caching tests

# sets up a custom cache environment in `tempdir()` just for testing
withr::local_envvar(R_USER_CACHE_DIR = tempdir())

# without caching enabled ----

test_that(".get_topsoil_thickness doesn't cache", {
  skip_if_offline()
  skip_on_ci()
  x <- .get_topsoil_thickness()
  expect_s3_class(x, c("read.abares.topsoil.thickness", "list"))
  expect_false(fs::dir_exists(fs::path(
    .find_user_cache(),
    "topsoil_thickness_dir"
  )))
  # cleanup on the way out for the next test
  expect_message(clear_cache())
})


# with caching enabled after is was not initially enabled ----

test_that("get_topsoil_thickness caches", {
  skip_if_offline()
  skip_on_ci()
  temp_cache <- fs::path(tempdir(), "R/read.abares/")
  withr::local_options(
    list(read.abares.cache_location = temp_cache),
    getOption("read.abares.cache_location")
  )
  withr::local_options(
    list(read.abares.cache = TRUE),
    getOption("read.abares.cache")
  )
  x <- .get_topsoil_thickness()
  expect_s3_class(x, c("read.abares.topsoil.thickness", "list"))
  expect_true(fs::file_exists(fs::path(
    .find_user_cache(),
    "topsoil_thickness_dir"
  )))
  expect_no_message(clear_cache())
  withr::deferred_run()
})

test_that("get_topsoil_thickness does cache", {
  skip_if_offline()
  skip_on_ci()
  x <- .get_topsoil_thickness()
  expect_s3_class(x, c("read.abares.topsoil.thickness", "list"))
  expect_true(fs::file_exists(fs::path(
    .find_user_cache(),
    "topsoil_thickness_dir"
  )))
})

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
