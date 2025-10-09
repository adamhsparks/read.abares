test_that("read_abs_livestock_data() downloads and parses livestock_and_products data", {
  skip_if_offline()

  temp_file <- fs::path(tempdir(), "livestock_file")
  last_url <- NULL
  got_dest <- NULL
  called_retry <- FALSE
  called_parse <- FALSE

  retry_mock <- function(url, dest, ...) {
    last_url <<- url
    got_dest <<- dest

    expect_identical(basename(dest), "livestock_file")
    fs::dir_create(fs::path_dir(dest), recurse = TRUE)
    fs::file_create(dest)
    called_retry <<- TRUE
    invisible(NULL)
  }

  parse_mock <- function(x) {
    called_parse <<- TRUE
    expect_identical(x, temp_file)
    data.table::data.table(Region = c("NSW", "VIC"), Value = c(100, 200))
  }

  with_mocked_bindings(
    .retry_download = retry_mock,
    parse_abs_production_data = parse_mock,
    {
      out <- read.abares::read_abs_livestock_data(
        data_set = "livestock_and_products"
      )

      expect_true(called_retry)
      expect_true(called_parse)

      expect_true(data.table::is.data.table(out))
      expect_identical(nrow(out), 2L)
      expect_match(
        last_url,
        "^https://www\\.abs\\.gov\\.au/statistics/industry/agriculture/australian-agriculture-livestock/2023-24/AALDC_Value%20of%20livestock%20and%20products%202023-24\\.xlsx$"
      )
      expect_true(fs::file_exists(temp_file))
      expect_identical(got_dest, temp_file)
    },
    .package = "read.abares"
  )
})

test_that("read_abs_livestock_data() downloads and parses cattle_herd data", {
  skip_if_offline()

  temp_file <- fs::path(tempdir(), "livestock_file")
  last_url <- NULL
  got_dest <- NULL
  called_retry <- FALSE
  called_parse <- FALSE

  retry_mock <- function(url, dest, ...) {
    last_url <<- url
    got_dest <<- dest

    expect_identical(basename(dest), "livestock_file")
    fs::dir_create(fs::path_dir(dest), recurse = TRUE)
    fs::file_create(dest)
    called_retry <<- TRUE
    invisible(NULL)
  }

  parse_mock <- function(x) {
    called_parse <<- TRUE
    expect_identical(x, temp_file)
    data.table::data.table(Region = c("QLD", "SA"), Herd = c(500, 300))
  }

  with_mocked_bindings(
    .retry_download = retry_mock,
    parse_abs_production_data = parse_mock,
    {
      out <- read.abares::read_abs_livestock_data(data_set = "cattle_herd")

      expect_true(called_retry)
      expect_true(called_parse)

      expect_true(data.table::is.data.table(out))
      expect_identical(nrow(out), 2L)
      expect_match(
        last_url,
        "^https://www\\.abs\\.gov\\.au/statistics/industry/agriculture/australian-agriculture-livestock/2023-24/AALDC_Cattle%20herd_2023_24\\.xlsx$"
      )
      expect_true(fs::file_exists(temp_file))
      expect_identical(got_dest, temp_file)
    },
    .package = "read.abares"
  )
})

test_that("read_abs_livestock_data() downloads and parses cattle_herd_series data", {
  skip_if_offline()

  temp_file <- fs::path(tempdir(), "livestock_file")
  last_url <- NULL
  got_dest <- NULL
  called_retry <- FALSE
  called_parse <- FALSE

  retry_mock <- function(url, dest, ...) {
    last_url <<- url
    got_dest <<- dest

    expect_identical(basename(dest), "livestock_file")
    fs::dir_create(fs::path_dir(dest), recurse = TRUE)
    fs::file_create(dest)
    called_retry <<- TRUE
    invisible(NULL)
  }

  parse_mock <- function(x) {
    called_parse <<- TRUE
    expect_identical(x, temp_file)
    data.table::data.table(
      Region = c("WA", "TAS"),
      Year = c(2005, 2024),
      Herd = c(400, 600)
    )
  }

  with_mocked_bindings(
    .retry_download = retry_mock,
    parse_abs_production_data = parse_mock,
    {
      out <- read.abares::read_abs_livestock_data(
        data_set = "cattle_herd_series"
      )

      expect_true(called_retry)
      expect_true(called_parse)

      expect_true(data.table::is.data.table(out))
      expect_identical(nrow(out), 2L)
      expect_match(
        last_url,
        "^https://www\\.abs\\.gov\\.au/statistics/industry/agriculture/australian-agriculture-livestock/2023-24/AALDC_Cattle%20herd%20series_2005%20to%202024\\.xlsx$"
      )
      expect_true(fs::file_exists(temp_file))
      expect_identical(got_dest, temp_file)
    },
    .package = "read.abares"
  )
})

test_that("read_abs_livestock_data() uses provided file path and parses it", {
  skip_if_offline()

  tmp_file <- withr::local_tempfile(fileext = ".xlsx")
  fs::file_create(tmp_file)

  called_parse <- FALSE

  with_mocked_bindings(
    .retry_download = function(...) {
      stop("`.retry_download()` should not be called when x is provided")
    },
    parse_abs_production_data = function(x) {
      expect_identical(x, tmp_file)
      called_parse <<- TRUE
      data.table::data.table(Region = c("ACT", "NT"), Value = c(50, 75))
    },
    {
      out <- read.abares::read_abs_livestock_data(x = tmp_file)

      expect_true(called_parse)
      expect_true(data.table::is.data.table(out))
      expect_identical(nrow(out), 2L)
      expect_setequal(out$Region, c("ACT", "NT"))
    },
    .package = "read.abares"
  )
})

test_that("read_abs_livestock_data() errors on invalid data_set", {
  skip_if_offline()

  expect_error(
    read_abs_livestock_data(data_set = "invalid_set"),
    regexp = "must be one of|`data_set`"
  )
})
