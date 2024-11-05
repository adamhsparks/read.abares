
# sets up a custom cache environment in `tempdir()` just for testing
withr::local_envvar(R_USER_CACHE_DIR = file.path(tempdir(), "abares.cache.1"))

# without caching ----

test_that("get_abares_trade_regions doesn't cache", {
  skip_if_offline()
  skip_on_ci()
  x <- get_abares_trade_regions(cache = FALSE)
  expect_s3_class(x, c("data.table", "data.frame"))
  expect_named(x,
               c("Classification",
                 "Region",
                 "Subregion",
                 "SACC_Destination",
                 "Destination"
               ))
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
    file.path(.find_user_cache(), "abares_trade_dir/abares_trade_regions.rds")
  ))
  expect_false(file.exists(
    file.path(.find_user_cache(), "abares_trade_dir/abares_trade_regions.csv")
  ))
})

test_that("get_abares_trade_regions skips downloading if still in tempdir()", {
  skip_if_offline()
  skip_on_ci()
  x <- .check_existing_trade_regions(cache = FALSE)
  expect_s3_class(x, c("data.table", "data.frame"))
})

# with caching ----

test_that("get_abares_trade_regions caches", {
  skip_if_offline()
  skip_on_ci()
  x <- get_abares_trade_regions(cache = TRUE)
  expect_s3_class(x, c("data.table", "data.frame"))
  y <- list.files(file.path(.find_user_cache(), "abares_trade_dir"))
  expect_true(file.exists(
    file.path(.find_user_cache(), "abares_trade_dir/abares_trade_regions.rds")
  ))
  expect_true(!file.exists(
    file.path(.find_user_cache(), "abares_trade_dir/abares_trade_regions.csv")
  ))
})

test_that("get_abares_trade_regions skips downloading if cache is available", {
  skip_if_offline()
  skip_on_ci()
  x <- .check_existing_trade_regions(cache = TRUE)
  expect_s3_class(x, c("data.table", "data.frame"))
})

withr::deferred_run()
