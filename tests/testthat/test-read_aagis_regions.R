# with caching ----
# sets up a custom cache environment in `tempdir()` just for testing
withr::local_envvar(R_USER_CACHE_DIR = file.path(tempdir(), "abares.cache.20"))

test_that("read_aagis_regions does cache", {
  skip_if_offline()
  skip_on_ci()
  x <- read_aagis_regions(cache = TRUE)
  expect_s3_class(x, "sf")
  expect_true(file.exists(
    file.path(.find_user_cache(), "aagis_regions_dir/aagis.gpkg")
  ))
  expect_false(file.exists(
    file.path(
      .find_user_cache(),
      "aagis_regions_dir/aagis_asgs16v1_g5a.shp"
    )
  ))
  file.remove(file.path(.find_user_cache(), "aagis_regions_dir/aagis.gpkg"))
})

withr::deferred_run()
# sets up a custom cache environment in `tempdir()` just for testing
withr::local_envvar(R_USER_CACHE_DIR = file.path(tempdir(), "abares.cache.1"))

# without caching ----
test_that("read_aagis_regions doesn't cache", {
  skip_if_offline()
  skip_on_ci()
  x <- read_aagis_regions(cache = FALSE)
  expect_s3_class(x, "sf")
  expect_false(file.exists(
    file.path(.find_user_cache(), "aagis_regions_dir/aagis.gpkg")
  ))
})


test_that("read_aagis_regions skips downloading if still in tempdir()", {
  skip_if_offline()
  skip_on_ci()
  x <- .check_existing_aagis(cache = FALSE)
  expect_s3_class(x, "sf")
})

withr::deferred_run()
