test_that("read_historical_national_estimates works", {
  skip_if_offline()
  x <- read_historical_national_estimates()
  expect_named(x, c("Variable", "Year", "Industry", "Value", "RSE"))
  expect_s3_class(x, c("data.table", "data.frame"))
  expect_identical(
    lapply(x, typeof),
    list(
      Variable = "character",
      Year = "integer",
      Industry = "character",
      Value = "double",
      RSE = "double"
    )
  )
})
