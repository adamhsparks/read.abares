test_that("read_abares_trade_regions works", {
  skip_if_offline()
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
