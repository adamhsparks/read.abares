test_that("read_abs_livestock_data() downloads and parses livestock_and_products data", {
  skip_on_cran()

  temp_file <- fs::path(tempdir(), "livestock_file")
  last_url <- NULL

  retry_mock <- function(url, .f) {
    last_url <<- url
    fs::file_create(.f)
    invisible(.f)
  }

  parse_mock <- function(x) {
    data.table::data.table(Region = c("NSW", "VIC"), Value = c(100, 200))
  }

  testthat::with_mocked_bindings(
    {
      out <- read_abs_livestock_data(data_set = "livestock_and_products")

      expect_true(data.table::is.data.table(out))
      expect_identical(nrow(out), 2L)
      expect_match(
        last_url,
        "Value%20of%20livestock%20and%20products%202023-24.xlsx"
      )
      expect_true(fs::file_exists(temp_file))
    },
    .retry_download = retry_mock,
    parse_abs_production_data = parse_mock
  )
})

test_that("read_abs_livestock_data() downloads and parses cattle_herd data", {
  skip_on_cran()

  temp_file <- fs::path(tempdir(), "livestock_file")
  last_url <- NULL

  retry_mock <- function(url, .f) {
    last_url <<- url
    fs::file_create(.f)
    invisible(.f)
  }

  parse_mock <- function(x) {
    data.table::data.table(Region = c("QLD", "SA"), Herd = c(500, 300))
  }

  testthat::with_mocked_bindings(
    {
      out <- read_abs_livestock_data(data_set = "cattle_herd")

      expect_true(data.table::is.data.table(out))
      expect_identical(nrow(out), 2L)
      expect_match(last_url, "Cattle%20herd_2023_24.xlsx")
      expect_true(fs::file_exists(temp_file))
    },
    .retry_download = retry_mock,
    parse_abs_production_data = parse_mock
  )
})

test_that("read_abs_livestock_data() downloads and parses cattle_herd_series data", {
  skip_on_cran()

  temp_file <- fs::path(tempdir(), "livestock_file")
  last_url <- NULL

  retry_mock <- function(url, .f) {
    last_url <<- url
    fs::file_create(.f)
    invisible(.f)
  }

  parse_mock <- function(x) {
    data.table::data.table(
      Region = c("WA", "TAS"),
      Year = c(2005, 2024),
      Herd = c(400, 600)
    )
  }

  testthat::with_mocked_bindings(
    {
      out <- read_abs_livestock_data(data_set = "cattle_herd_series")

      expect_true(data.table::is.data.table(out))
      expect_identical(nrow(out), 2L)
      expect_match(last_url, "Cattle%20herd%20series_2005%20to%202024.xlsx")
      expect_true(fs::file_exists(temp_file))
    },
    .retry_download = retry_mock,
    parse_abs_production_data = parse_mock
  )
})

test_that("read_abs_livestock_data() uses provided file path and parses it", {
  skip_on_cran()

  tmp_file <- withr::local_tempfile(fileext = ".xlsx")
  fs::file_create(tmp_file)

  parse_mock <- function(x) {
    expect_identical(x, tmp_file)
    data.table::data.table(Region = c("ACT", "NT"), Value = c(50, 75))
  }

  testthat::with_mocked_bindings(
    {
      out <- read_abs_livestock_data(x = tmp_file)

      expect_true(data.table::is.data.table(out))
      expect_identical(nrow(out), 2L)
      expect_setequal(out$Region, c("ACT", "NT"))
    },
    parse_abs_production_data = parse_mock
  )
})

test_that("read_abs_livestock_data() errors on invalid data_set", {
  skip_on_cran()

  expect_error(
    read_abs_livestock_data(data_set = "invalid_set"),
    regexp = "must be one of"
  )
})
