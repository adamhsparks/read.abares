test_that("read_historical_forecast_database reads local file correctly", {
  tmp <- tempfile(fileext = ".xlsx")
  wb <- openxlsx::createWorkbook()
  openxlsx::addWorksheet(wb, "Database")
  openxlsx::writeData(
    wb,
    "Database",
    data.frame(
      Year_Issued = 2020,
      Month_Issued = "March",
      Year_Issued_FY = 2020,
      Forecast_Year_FY = 2021,
      Forecast_Value = 100,
      Actual_Value = 90,
      Commodity = "Wheat",
      Estimate_Type = "Production",
      Estimate_description = "Dummy",
      Unit = "kt",
      Region = "World"
    )
  )
  openxlsx::saveWorkbook(wb, tmp, overwrite = TRUE)

  result <- read_historical_forecast_database(tmp)
  expect_s3_class(result, "data.table")
  expect_equal(result$Month_issued, 3L)
})
