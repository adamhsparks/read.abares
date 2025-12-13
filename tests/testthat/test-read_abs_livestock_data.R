test_that("invalid data_set argument errors", {
  expect_error(
    read_abs_livestock_data(data_set = NA),
    "must be a single character string value"
  )
  expect_error(
    read_abs_livestock_data(data_set = c("a", "b")),
    "must be a single character string value"
  )
  expect_error(
    read_abs_livestock_data(data_set = 123),
    "must be a single character string value"
  )
})

test_that("read_abs_livestock_data works for each valid dataset", {
  ns <- asNamespace("read.abares")

  fake_dt <- data.table::data.table(animal = "Cattle", value = 100)
  fake_retry <- function(url, dest) dest
  fake_parse <- function(path) fake_dt

  with_mocked_bindings(
    {
      result <- read_abs_livestock_data(data_set = "livestock_and_products")
      expect_s3_class(result, "data.table")
      expect_equal(result$animal, "Cattle")
      expect_equal(result$value, 100)
    },
    .retry_download = fake_retry,
    parse_abs_production_data = fake_parse,
    .env = ns
  )

  with_mocked_bindings(
    {
      result <- read_abs_livestock_data(data_set = "cattle_herd")
      expect_s3_class(result, "data.table")
    },
    .retry_download = fake_retry,
    parse_abs_production_data = fake_parse,
    .env = ns
  )

  with_mocked_bindings(
    {
      result <- read_abs_livestock_data(data_set = "cattle_herd_series")
      expect_s3_class(result, "data.table")
    },
    .retry_download = fake_retry,
    parse_abs_production_data = fake_parse,
    .env = ns
  )
})

test_that("read_abs_livestock_data bypasses download when x is provided", {
  ns <- asNamespace("read.abares")

  fake_dt <- data.table::data.table(animal = "Sheep", value = 200)
  fake_parse <- function(path) fake_dt

  with_mocked_bindings(
    {
      result <- read_abs_livestock_data(x = "local.xlsx")
      expect_s3_class(result, "data.table")
      expect_equal(result$animal, "Sheep")
      expect_equal(result$value, 200)
    },
    parse_abs_production_data = fake_parse,
    .env = ns
  )
})
