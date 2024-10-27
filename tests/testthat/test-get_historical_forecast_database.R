test_that("get_historical_forecast() works", {
  skip_if_offline()
  x <- get_historical_forecast()
  expect_named(
    x,
    c(
      "Year_issued",
      "Month_issued",
      "Year_issued_FY",
      "Forecast_year_FY",
      "Forecast_value",
      "Actual_value",
      "Commodity",
      "Estimate_type",
      "Estimate_description",
      "Unit",
      "Region"
    )
  )
  expect_s3_class(x, c("data.table", "data.frame"))
  expect_identical(
    lapply(x, typeof),
    list(
      Year_issued = "double",
      Month_issued = "integer",
      Year_issued_FY = "character",
      Forecast_year_FY = "character",
      Forecast_value = "double",
      Actual_value = "double",
      Commodity = "character",
      Estimate_type = "character",
      Estimate_description = "character",
      Unit = "character",
      Region = "character"
    )
  )
})
