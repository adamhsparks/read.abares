test_that("read_abs_horticulture_data errors if year is invalid", {
  ns <- asNamespace("read.abares")

  fake_years <- c("2022-23", "2023-24")
  fake_find <- function(data_set) fake_years
  fake_retry <- function(url, dest) dest
  fake_parse <- function(path) data.table::data.table(dummy = 1)

  with_mocked_bindings(
    {
      expect_error(
        read_abs_horticulture_data(year = "1999-00"),
        "must be one of"
      )
    },
    .find_years = fake_find,
    .retry_download = fake_retry,
    parse_abs_production_data = fake_parse,
    .env = ns
  )
})

test_that("read_abs_horticulture_data resolves 'latest' year correctly", {
  ns <- asNamespace("read.abares")

  fake_years <- c("2023-24", "2022-23")
  fake_find <- function(data_set) fake_years
  fake_retry <- function(url, dest) dest
  fake_parse <- function(path) {
    data.table::data.table(crop = "Apples", value = 10)
  }
  }
  }
  with_mocked_bindings(
    {
      result <- read_abs_horticulture_data(year = "latest")
      expect_s3_class(result, "data.table")
      expect_identical(result$crop, "Apples")
      expect_identical(result$value, 10)
    },
    .find_years = fake_find,
    .retry_download = fake_retry,
    parse_abs_production_data = fake_parse,
    .env = ns
  )
})

test_that("read_abs_horticulture_data accepts explicit year", {
  ns <- asNamespace("read.abares")

  fake_years <- c("2022-23", "2023-24")
  fake_find <- function(data_set) fake_years
  fake_retry <- function(url, dest) dest
  fake_parse <- function(path) {
    data.table::data.table(crop = "Bananas", value = 20)
  }
    data.table::data.table(crop = "Bananas", value = 20)
  with_mocked_bindings(
    {
      result <- read_abs_horticulture_data(year = "2022-23")
      expect_s3_class(result, "data.table")
      expect_identical(result$crop, "Bananas")
      expect_identical(result$value, 20)
    },
    .find_years = fake_find,
    .retry_download = fake_retry,
    parse_abs_production_data = fake_parse,
    .env = ns
  )
})

test_that("read_abs_horticulture_data bypasses download when x is provided", {
  ns <- asNamespace("read.abares")

  fake_parse <- function(path) {
    data.table::data.table(crop = "Mangoes", value = 30)
  }
    data.table::data.table(crop = "Mangoes", value = 30)
  with_mocked_bindings(
    {
      result <- read_abs_horticulture_data(x = "local.xlsx")
      expect_s3_class(result, "data.table")
      expect_identical(result$crop, "Mangoes")
      expect_identical(result$value, 30)
    },
    parse_abs_production_data = fake_parse,
    .env = ns
  )
})
