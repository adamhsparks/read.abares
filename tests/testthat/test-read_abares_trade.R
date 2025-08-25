test_that("read_abares_trade returns a data.table", {
  skip_if_offline()
  skip_on_ci()
  x <- read_abares_trade()
  expect_s3_class(x, c("data.table", "data.frame"))
  expect_named(
    x,
    c(
      "Fiscal_year",
      "Month",
      "Year_month",
      "Calendar_year",
      "Trade_code",
      "Overseas_location",
      "State",
      "Australian_port",
      "Unit",
      "Trade_flow",
      "Mode_of_transport",
      "Value",
      "Quantity",
      "Confidentiality_flag"
    )
  )
  expect_identical(
    lapply(x, typeof),
    list(
      Fiscal_year = "character",
      Month = "integer",
      Year_month = "double",
      Calendar_year = "integer",
      Trade_code = "double",
      Overseas_location = "character",
      State = "character",
      Australian_port = "character",
      Unit = "character",
      Trade_flow = "character",
      Mode_of_transport = "character",
      Value = "double",
      Quantity = "double",
      Confidentiality_flag = "integer"
    )
  )
})
