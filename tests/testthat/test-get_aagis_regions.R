
# sets up a custom cache environment in `tempdir()` just for testing
withr::local_envvar(R_USER_CACHE_DIR = file.path(tempdir(), "abares.cache.1"))

# without caching ----
test_that("get_aagis_regions doesn't cache", {
  skip_if_offline()
  skip_on_ci()
  x <- get_aagis_regions(cache = FALSE)
  expect_s3_class(x, "sf")
  expect_false(file.exists(
    file.path(.find_user_cache(), "aagis_regions_dir/aagis.rds")
  ))
})


test_that("get_aagis_regions skips downloading if still in tempdir()", {
  skip_if_offline()
  skip_on_ci()
  x <- .check_existing_aagis(cache = FALSE)
  expect_s3_class(x, "sf")
})

# with caching ----

test_that("get_aagis_regions caches", {
  skip_if_offline()
  skip_on_ci()
  x <- get_aagis_regions(cache = TRUE)
  expect_s3_class(x, "sf")
  expect_true(file.exists(
    file.path(.find_user_cache(), "aagis_regions_dir/aagis.rds")
  ))
  expect_true(!file.exists(
    file.path(.find_user_cache(), "aagis_regions_dir/aagis_zip")
  ))
  expect_true(!file.exists(file.path(
    .find_user_cache(), "aagis_asgs16v1_g5a.*"
  )))
})

test_that("get_aagis_regions skips downloading if cache is available", {
  skip_if_offline()
  skip_on_ci()
  x <- .check_existing_aagis(cache = TRUE)
  expect_s3_class(x, "sf")
})

# sets up a custom cache environment in `tempdir()` just for testing
withr::local_envvar(R_USER_CACHE_DIR = file.path(tempdir(), "abares.cache.2"))


test_that("get_aagis_regions does cache", {
  skip_if_offline()
  skip_on_ci()
  x <- get_aagis_regions(cache = TRUE)
  expect_s3_class(x, "sf")
  expect_true(file.exists(
    file.path(.find_user_cache(), "aagis_regions_dir/aagis.rds")
  ))
  expect_false(file.exists(
    file.path(
      .find_user_cache(),
      "aagis_regions_dir/aagis_asgs16v1_g5a.shp"
    )
  ))
})

test_that("get_aagis_regions skips downloading if still in tempdir()", {
  skip_if_offline()
  skip_on_ci()
  x <- .check_existing_aagis(cache = TRUE)
  expect_s3_class(x, "sf")
})
})

withr::deferred_run()
