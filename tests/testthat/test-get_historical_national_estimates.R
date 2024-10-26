test_that("get_historical_national_estimates works", {
  skip_if_offline()
  x <- get_historical_national_estimates()
  expect_named(x, c("Variable", "Year", "Value", "RSE", "Industry"))
  expect_s3_class(x, c("data.table", "data.frame"))
  expect_identical(
    lapply(x, typeof),
    list(
      Variable = "character",
      Year = "integer",
      Value = "double",
      RSE = "integer",
      Industry = "character"
    )
  )
})
