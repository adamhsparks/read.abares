# sets up a custom cache environment in `tempdir()` just for testing
withr::local_envvar(R_USER_CACHE_DIR = file.path(tempdir(), "abares.cache.1"))

# without caching ----

test_that("read_abares_trade_regions works", {
  skip_if_offline()
  skip_on_ci()
  x <- read_abares_trade_regions()
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
})
