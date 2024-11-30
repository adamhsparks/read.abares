
# sets up a custom cache environment in `tempdir()` just for testing
withr::local_envvar(R_USER_CACHE_DIR = file.path(tempdir(), "abares.cache.1"))

# without caching ----
with_mock_dir("test-get_aagis_regions", {
  test_that("get_aagis_regions doesn't cache", {
    x <- get_aagis_regions(cache = FALSE)
    expect_s3_class(x, "sf")
    expect_false(file.exists(
      file.path(.find_user_cache(), "aagis_regions_dir/aagis.rds")
    ))
  })
})

with_mock_dir("test-get_aagis_regions", {
  test_that("get_aagis_regions skips downloading if still in tempdir()", {
    x <- .check_existing_aagis(cache = FALSE)
    expect_s3_class(x, "sf")
  })
})

# with caching ----

with_mock_dir("test-get_aagis_regions", {
  test_that("get_aagis_regions caches", {
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
})

with_mock_dir("test-get_aagis_regions", {
  test_that("get_aagis_regions skips downloading if cache is available", {
    x <- .check_existing_aagis(cache = TRUE)
    expect_s3_class(x, "sf")
  })
})

# sets up a custom cache environment in `tempdir()` just for testing
withr::local_envvar(R_USER_CACHE_DIR = file.path(tempdir(), "abares.cache.2"))

with_mock_dir("test-get_aagis_regions", {
  test_that("get_aagis_regions does cache", {
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
})

with_mock_dir("test-get_aagis_regions", {
  test_that("get_aagis_regions skips downloading if still in tempdir()", {
    x <- .check_existing_aagis(cache = TRUE)
    expect_s3_class(x, "sf")
  })
})

withr::deferred_run()
