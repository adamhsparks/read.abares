
test_that("get_historical_state_estimates works", {
  skip_if_offline()
  x <- get_historical_state_estimates()
  expect_named(x, c("Variable", "Year", "Value", "RSE", "State", "Industry"))
  expect_s3_class(x, c("data.table", "data.frame"))
  expect_identical(
    lapply(x, typeof),
    list(
      Variable = "character",
      Year = "integer",
      Value = "double",
      RSE = "integer",
      State = "character",
      Industry = "character"
    )
  )
})
