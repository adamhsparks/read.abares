# with caching ----
# sets up a custom cache environment in `tempdir()` just for testing
withr::local_envvar(R_USER_CACHE_DIR = tempdir())
withr::local_options(read.abares.cache = TRUE)

test_that("read_aagis_regions does cache", {
  skip_if_offline()
  skip_on_ci()
  read_aagis_regions() # create the cache
  expect_true(fs::file_exists(
    fs::path(.find_user_cache(), "aagis_regions_dir/aagis.gpkg")
  ))
  x <- read_aagis_regions()
  expect_s3_class(x, "sf")
  expect_named(x, c("Class", "ABARES_region", "Zone", "State", "geom"))
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
withr::local_options(read.abares.cache = FALSE)
test_that("read_aagis_regions doesn't cache", {
  skip_if_offline()
  skip_on_ci()
  withr::local_options(list(cache = FALSE), getOption("read.abares.cache"))
  x <- read_aagis_regions()
  expect_s3_class(x, "sf")
  expect_false(fs::file_exists(
    fs::path(.find_user_cache(), "aagis_regions_dir/aagis.gpkg")
  ))
})
withr::deferred_run()
