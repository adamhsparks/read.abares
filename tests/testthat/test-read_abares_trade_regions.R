# sets up a custom cache environment in `tempdir()` just for testing
withr::local_envvar(R_USER_CACHE_DIR = file.path(tempdir(), "abares.cache.1"))

# without caching ----

test_that("read_abares_trade_regions doesn't cache", {
  skip_if_offline()
  skip_on_ci()
  x <- read_abares_trade_regions(cache = FALSE)
  expect_s3_class(x, c("data.table", "data.frame"))
  expect_named(
    x,
    c(
      "Classification",
      "Region",
      "Subregion",
      "SACC_Destination",
      "Destination"
    )
  )
  expect_identical(
    lapply(x, typeof),
    list(
      Classification = "character",
      Region = "character",
      Subregion = "character",
      SACC_Destination = "character",
      Destination = "character"
    )
  )
  expect_false(file.exists(
    file.path(.find_user_cache(), "abares_trade_dir/abares_trade_regions.gz")
  ))
})


# with caching ----

test_that("read_abares_trade_regions caches", {
  skip_if_offline()
  skip_on_ci()
  read_abares_trade_regions(cache = TRUE)
  expect_true(file.exists(
    file.path(.find_user_cache(), "abares_trade_dir/abares_trade_regions.gz")
  ))
})

# cleanup if running tests in same session again so first test passes
unlink(file.path(.find_user_cache(), "abares_trade_dir/abares_trade_regions.gz"))

withr::deferred_run()
