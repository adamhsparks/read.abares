test_that("read_estimates_by_performance_category() works", {
  skip_if_offline()
  x <- read_estimates_by_performance_category()
  expect_named(x, c("Variable", "Year", "Size", "Value", "RSE"))
  expect_s3_class(x, c("data.table", "data.frame"))
  expect_identical(
    lapply(x, typeof),
    list(
      Variable = "character",
      Year = "integer",
      Size = "character",
      Value = "double",
      RSE = "integer"
    )
  )
})
