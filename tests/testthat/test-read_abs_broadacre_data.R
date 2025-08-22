test_that("read_abs_broadacre_data() returns parsed data for default args", {
  mock_find_years <- function(data_set) c("2022-23", "2021-22")
  mock_parse <- function(file) {
    data.table::data.table(
      region = factor("A"),
      region_codes = factor("1"),
      commidity = "Wheat",
      units = "tonnes"
    )
  }
  mock_retry_download <- function(url, .f) tempfile(fileext = ".xlsx")

  stub(read_abs_broadacre_data, ".find_years", mock_find_years)
  stub(read_abs_broadacre_data, "parse_abs_production_data", mock_parse)
  stub(read_abs_broadacre_data, ".retry_download", mock_retry_download)

  result <- read_abs_broadacre_data()
  expect_s3_class(result, "data.table")
  expect_identical(result$commidity, "Wheat")
})

test_that("read_abs_broadacre_data() handles explicit year and crops", {
  mock_find_years <- function(data_set) c("2022-23", "2021-22")
  mock_parse <- function(file) {
    data.table::data.table(
      region = factor("B"),
      region_codes = factor("2"),
      commidity = "Barley",
      units = "tonnes"
    )
  }
  mock_retry_download <- function(url, .f) tempfile(fileext = ".xlsx")

  stub(read_abs_broadacre_data, ".find_years", mock_find_years)
  stub(read_abs_broadacre_data, "parse_abs_production_data", mock_parse)
  stub(read_abs_broadacre_data, ".retry_download", mock_retry_download)

  result <- read_abs_broadacre_data(crops = "summer", year = "2021-22")
  expect_s3_class(result, "data.table")
  expect_identical(result$commidity, "Barley")
})

test_that("read_abs_broadacre_data() uses provided file", {
  mock_parse <- function(file) data.table::data.table(file = file)
  stub(read_abs_broadacre_data, "parse_abs_production_data", mock_parse)

  result <- read_abs_broadacre_data(file = "myfile.xlsx")
  expect_identical(result$file, "myfile.xlsx")
})
