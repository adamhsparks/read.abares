with_mock_dir("abares/read_historical_state_estimates", {
  test_that("read_historical_state_estimates works", {
    skip_if_offline()
    skip_on_ci()
    x <- read_historical_state_estimates()
    expect_named(x, c("Variable", "Year", "State", "Industry", "Value", "RSE"))
    expect_s3_class(x, c("data.table", "data.frame"))
    expect_identical(
      lapply(x, typeof),
      list(
        Variable = "character",
        Year = "integer",
        State = "character",
        Industry = "character",
        Value = "double",
        RSE = "integer"
      )
    )
  })
})
