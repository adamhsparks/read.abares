test_that("invalid data_set argument errors", {
  expect_error(
    read_abs_broadacre_data(data_set = NA),
    "must be a single character string value"
  )
  expect_error(
    read_abs_broadacre_data(data_set = c("winter", "summer")),
    "must be a single character string value"
  )
  expect_error(
    read_abs_broadacre_data(data_set = 123),
    "must be a single character string value"
  )
})

test_that("read_abs_broadacre_data calls helpers and returns parsed data", {
  ns <- asNamespace("read.abares")

  fake_years <- c("2022-23", "2023-24")
  fake_file <- "dummy.xlsx"
  fake_dt <- data.table::data.table(crop = "Wheat", value = 100)

  fake_find <- function(data_set) fake_years
  fake_retry <- function(url, dest) dest
  fake_parse <- function(path) fake_dt

  with_mocked_bindings(
    {
      result <- read_abs_broadacre_data(data_set = "winter", year = "latest")
      expect_s3_class(result, "data.table")
      expect_equal(result$crop, "Wheat")
      expect_equal(result$value, 100)
    },
    .find_years = fake_find,
    .retry_download = fake_retry,
    parse_abs_production_data = fake_parse,
    .env = ns
  )
})

test_that("year argument is matched correctly", {
  ns <- asNamespace("read.abares")

  fake_years <- c("2022-23", "2023-24")
  fake_file <- "dummy.xlsx"
  fake_dt <- data.table::data.table(crop = "Barley", value = 200)

  fake_find <- function(data_set) fake_years
  fake_retry <- function(url, dest) dest
  fake_parse <- function(path) fake_dt

  with_mocked_bindings(
    {
      # explicit year
      result <- read_abs_broadacre_data(data_set = "summer", year = "2022-23")
      expect_equal(result$crop, "Barley")
      # latest resolves to first available
      result2 <- read_abs_broadacre_data(
        data_set = "sugarcane",
        year = "latest"
      )
      expect_equal(result2$crop, "Barley")
    },
    .find_years = fake_find,
    .retry_download = fake_retry,
    parse_abs_production_data = fake_parse,
    .env = ns
  )
})

test_that("x argument bypasses download", {
  ns <- asNamespace("read.abares")

  fake_dt <- data.table::data.table(crop = "Canola", value = 300)
  fake_parse <- function(path) fake_dt

  with_mocked_bindings(
    {
      result <- read_abs_broadacre_data(x = "local.xlsx")
      expect_equal(result$crop, "Canola")
      expect_equal(result$value, 300)
    },
    parse_abs_production_data = fake_parse,
    .env = ns
  )
})
