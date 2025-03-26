# with caching ----
# sets up a custom cache environment in `tempdir()` just for testing
withr::local_envvar(R_USER_CACHE_DIR = tempdir())

test_that("read_aagis_regions does cache", {
  skip_if_offline()
  skip_on_ci()
  read_aagis_regions(cache = TRUE) # create the cache
  expect_true(fs::file_exists(
    fs::path(.find_user_cache(), "aagis_regions_dir/aagis.gpkg")
  ))
  x <- read_aagis_regions(cache = TRUE)
  expect_s3_class(x, "sf")
  expect_false(fs::file_exists(
    fs::path(
      .find_user_cache(),
      "aagis_regions_dir/aagis_asgs16v1_g5a.shp"
    )
  ))
  file.remove(fs::path(.find_user_cache(), "aagis_regions_dir/aagis.gpkg"))
  expect_no_message(clear_cache())
})


# without caching ----
test_that("read_aagis_regions doesn't cache", {
  skip_if_offline()
  skip_on_ci()
  x <- read_aagis_regions(cache = FALSE)
  expect_s3_class(x, "sf")
  expect_false(fs::file_exists(
    fs::path(.find_user_cache(), "aagis_regions_dir/aagis.gpkg")
  ))
})
withr::deferred_run()
