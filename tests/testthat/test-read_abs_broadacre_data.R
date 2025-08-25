test_that("read_abs_broadacre_data() returns parsed data for default args", {
  local_mocked_bindings(
    .find_years = function(data_set) c("2022-23", "2021-22"),
    parse_abs_production_data = function(file) {
      data.table(
        region = factor("A"),
        region_codes = factor("1"),
        commidity = "Wheat",
        units = "tonnes"
      )
    },
    .retry_download = function(url, .f) tempfile(fileext = ".xlsx")
  )

  result <- read_abs_broadacre_data()
  expect_s3_class(result, "data.table")
  expect_identical(result$commidity, "Wheat")
})

test_that("read_abs_broadacre_data() handles explicit year and crops", {
  local_mocked_bindings(
    .find_years = function(data_set) c("2022-23", "2021-22"),
    parse_abs_production_data = function(file) {
      data.table(
        region = factor("B"),
        region_codes = factor("2"),
        commidity = "Barley",
        units = "tonnes"
      )
    },
    .retry_download = function(url, .f) tempfile(fileext = ".xlsx")
  )

  result <- read_abs_broadacre_data(crops = "summer", year = "2021-22")
  expect_s3_class(result, "data.table")
  expect_identical(result$commidity, "Barley")
})
