
test_that("get_estimates_by_size works", {
  skip_if_offline()
  skip_on_ci()
  x <- get_estimates_by_size()
  expect_named(x, c("Variable", "Year", "Size", "Industry", "Value", "RSE"))
  expect_s3_class(x, c("data.table", "data.frame"))
  expect_identical(
    lapply(x, typeof),
    list(
      Variable = "character",
      Year = "integer",
      Size = "character",
      Industry = "character",
      Value = "double",
      RSE = "integer"
    )
  )
})
