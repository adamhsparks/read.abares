test_that("get_estimates_by_size works", {
  skip_if_offline()
  x <- get_estimates_by_size()
  expect_named(x, c("Variable", "Year", "Industry", "Size", "Value", "RSE"))
  expect_s3_class(x, c("data.table", "data.frame"))
  expect_identical(
    lapply(x, typeof),
    list(
      Variable = "character",
      Year = "integer",
      Industry = "character",
      Size = "character",
      Value = "double",
      RSE = "integer"
    )
  )
  expect_identical(
    lapply(x, typeof),
    list(
      Variable = "character",
      Year = "integer",
      Industry = "character",
      Size = "character",
      Value = "double",
      RSE = "integer"
    )
  )
})
