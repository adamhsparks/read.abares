
# sets up a custom cache environment in `tempdir()` just for testing
withr::local_envvar(R_USER_CACHE_DIR = file.path(tempdir(), "abares.cache.1"))

# without caching ----

test_that("get_soil_thickness doesn't cache", {
  skip_if_offline()
  x <- get_soil_thickness(cache = FALSE)
  expect_s3_class(x, "read.abares.soil.thickness")
  expect_false(dir.exists(
    file.path(.find_user_cache(), "soil_thickness_dir")
  ))
})

test_that("get_soil_thickness skips downloading if still in tempdir()", {
  skip_if_offline()
  x <- .check_existing_aagis(cache = FALSE)
  expect_s3_class(x, "read.abares.soil.thickness")
})

# with caching ----

test_that("get_soil_thickness caches", {
  skip_if_offline()
  x <- get_soil_thickness(cache = TRUE)
  expect_s3_class(x, "read.abares.soil.thickness")
  expect_true(file.exists(
    file.path(.find_user_cache(), "soil_thickness_dir")
  ))
})

test_that("get_soil_thickness skips downloading if cache is available", {
  skip_if_offline()
  x <- .check_existing_aagis(cache = TRUE)
  expect_s3_class(x, "read.abares.soil.thickness")
})

# sets up a custom cache environment in `tempdir()` just for testing
withr::local_envvar(R_USER_CACHE_DIR = file.path(tempdir(), "abares.cache.2"))

test_that("get_soil_thickness does cache", {
  skip_if_offline()
  x <- get_soil_thickness(cache = TRUE)
  expect_s3_class(x, "read.abares.soil.thickness")
  expect_true(file.exists(
    file.path(.find_user_cache(), "soil_thickness_dir")
  ))
  expect_false(dir.exists(
    file.path(
      .find_user_cache(),
      "soil_thickness_dir"
    )
  ))
})

test_that("get_soil_thickness skips downloading if still in tempdir()", {
  skip_if_offline()
  x <- .check_existing_aagis(cache = TRUE)
  expect_s3_class(x, "read.abares.soil.thickness")
})

withr::deferred_run()
