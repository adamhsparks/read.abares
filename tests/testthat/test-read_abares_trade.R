# sets up a custom cache environment in `tempdir()` just for testing
withr::local_envvar(R_USER_CACHE_DIR = tempdir())

# without caching ----
test_that("read_abares_trade doesn't cache", {
  skip_if_offline()
  skip_on_ci()
  x <- read_abares_trade(cache = FALSE)
  expect_s3_class(x, c("data.table", "data.frame"))
  expect_named(
    x,
    c(
      "Fiscal_year",
      "Month",
      "Year_month",
      "Calendar_year",
      "Trade_code",
      "Overseas_location",
      "State",
      "Australian_port",
      "Unit",
      "Trade_flow",
      "Mode_of_transport",
      "Value",
      "Quantity",
      "Confidentiality_flag"
    )
  )
  expect_identical(
    lapply(x, typeof),
    list(
      Fiscal_year = "character",
      Month = "integer",
      Year_month = "double",
      Calendar_year = "integer",
      Trade_code = "double",
      Overseas_location = "character",
      State = "character",
      Australian_port = "character",
      Unit = "character",
      Trade_flow = "character",
      Mode_of_transport = "character",
      Value = "double",
      Quantity = "double",
      Confidentiality_flag = "integer"
    )
  )
  expect_false(fs::file_exists(
    fs::path(.find_user_cache(), "abares_trade_dir/abares_trade.gz")
  ))
})

# with caching ----
test_that("read_abares_trade caches", {
  skip_if_offline()
  skip_on_ci()
  read_abares_trade()
  expect_true(fs::file_exists(
    fs::path(.find_user_cache(), "abares_trade_dir/abares_trade.gz")
  ))
})

# cleanup cache if rerunning tests in same R session so first test passes ----

clear_cache()
withr::deferred_run()
