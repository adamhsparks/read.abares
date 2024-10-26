test_that("get_historical_regional_estimates works", {
  skip_if_offline()
  x <- get_historical_regional_estimates()
  expect_named(x, c("Variable", "Year", "ABARES region", "Value", "RSE"))
  expect_s3_class(x, c("data.table", "data.frame"))
  expect_identical(
    lapply(x, typeof),
    list(
      Variable = "character",
      Year = "integer",
      `ABARES region` = "character",
      Value = "double",
      RSE = "integer"
    )
  )
})
