test_that("read_abs_horticulture_data() uses .retry_download (mocked), resolves 'latest', and parses the downloaded file", {
  skip_if_offline()
  called_retry <- FALSE
  called_parse <- FALSE
  got_retry_dest <- NULL
  got_parse_x <- NULL

  available_years <- c("2023-24", "2022-23")

  with_mocked_bindings(
    .find_years = function(data_set) {
      expect_identical(data_set, "horticulture")
      available_years
    },
    .retry_download = function(url, dest, ...) {
      # Base URL and tail should match exactly
      expect_match(
        url,
        "https://www\\.abs\\.gov\\.au/statistics/industry/agriculture/australian-agriculture-horticulture/2023-24/AAHDC_Aust_Horticulture_202324\\.xlsx"
      )
      # Expect the temp file naming convention
      expect_identical(basename(dest), "hort_crops_file")

      # Create a real file where we were told to download
      fs::dir_create(fs::path_dir(dest), recurse = TRUE)
      fs::file_create(dest)

      got_retry_dest <<- dest
      called_retry <<- TRUE
      invisible(NULL)
    },
    parse_abs_production_data = function(x) {
      called_parse <<- TRUE
      got_parse_x <<- x
      # Return a sentinel data.table
      data.table::data.table(
        Dataset = "ABS horticulture",
        Year = "2023-24",
        Rows = 1L
      )
    },
    {
      res <- read_abs_horticulture_data(year = "latest", x = NULL)

      # Ensure mocks ran
      expect_true(called_retry)
      expect_true(called_parse)

      # The parse path should be the same as the retry download target
      expect_false(is.null(got_retry_dest))
      expect_identical(got_parse_x, got_retry_dest)
      expect_true(file.exists(got_parse_x))

      expect_s3_class(res, "data.table")
      expect_identical(nrow(res), 1L)
      expect_named(res, c("Dataset", "Year", "Rows"))
      expect_identical(res$Year[[1L]], "2023-24")
    },
    .package = "read.abares"
  )
})

test_that("read_abs_horticulture_data() constructs URL correctly for an explicit year", {
  skip_if_offline()
  called_retry <- FALSE
  called_parse <- FALSE
  got_retry_dest <- NULL
  got_parse_x <- NULL

  available_years <- c("2021-22", "2020-21")

  with_mocked_bindings(
    .find_years = function(data_set) {
      expect_identical(data_set, "horticulture")
      available_years
    },
    .retry_download = function(url, dest, ...) {
      # Explicit year should appear and dashes removed in trailing code
      expect_match(
        url,
        "https://www\\.abs\\.gov\\.au/statistics/industry/agriculture/australian-agriculture-horticulture/2021-22/AAHDC_Aust_Horticulture_202122\\.xlsx"
      )
      expect_identical(basename(dest), "hort_crops_file")

      fs::dir_create(fs::path_dir(dest), recurse = TRUE)
      fs::file_create(dest)

      got_retry_dest <<- dest
      called_retry <<- TRUE
      invisible(NULL)
    },
    parse_abs_production_data = function(x) {
      called_parse <<- TRUE
      got_parse_x <<- x
      data.table::data.table(Year = "2021-22", OK = TRUE)
    },
    {
      res <- read.abares::read_abs_horticulture_data(year = "2021-22", x = NULL)

      expect_true(called_retry)
      expect_true(called_parse)
      expect_identical(got_parse_x, got_retry_dest)
      expect_true(file.exists(got_parse_x))

      expect_s3_class(res, "data.table")
      expect_identical(res$Year[[1L]], "2021-22")
      expect_true(res$OK[[1L]])
    },
    .package = "read.abares"
  )
})

test_that("read_abs_horticulture_data() reads a provided path without calling .retry_download or .find_years", {
  skip_if_offline()
  tmp_dir <- withr::local_tempdir()
  x_path <- fs::path(tmp_dir, "abs_hort_mock.xlsx")
  fs::file_create(x_path)

  called_parse <- FALSE

  with_mocked_bindings(
    .find_years = function(...) {
      stop("`.find_years()` should not be called when x != NULL")
    },
    .retry_download = function(...) {
      stop("`.retry_download()` should not be called when x != NULL")
    },
    parse_abs_production_data = function(x) {
      expect_identical(x, x_path)
      called_parse <<- TRUE
      data.table::data.table(FromPath = TRUE)
    },
    {
      res <- read.abares::read_abs_horticulture_data(x = x_path)

      expect_true(called_parse)
      expect_s3_class(res, "data.table")
      expect_true(res$FromPath[[1L]])
    },
    .package = "read.abares"
  )
})

test_that("read_abs_horticulture_data() validates year argument", {
  skip_if_offline()
  available_years <- c("2023-24", "2022-23")

  # Invalid year should error (not in available and not 'latest')
  with_mocked_bindings(
    .find_years = function(data_set) {
      expect_identical(data_set, "horticulture")
      available_years
    },
    .retry_download = function(...) {
      stop("`.retry_download()` should not be called on arg error")
    },
    parse_abs_production_data = function(...) {
      stop("`parse_abs_production_data()` should not be called on arg error")
    },
    {
      expect_error(
        read.abares::read_abs_horticulture_data(year = "2018-19", x = NULL),
        regexp = "year|must be one of|`year`"
      )
    },
    .package = "read.abares"
  )
})

test_that("read_abs_horticulture_data() uses the 'latest' year (first in available)", {
  skip_if_offline()
  called_retry <- FALSE

  available_years <- c("2022-23", "2021-22", "2020-21")

  with_mocked_bindings(
    .find_years = function(data_set) {
      expect_identical(data_set, "horticulture")
      available_years
    },
    .retry_download = function(url, dest, ...) {
      # Should pick "2022-23" and 202223 suffix
      expect_match(
        url,
        "https://www\\.abs\\.gov\\.au/statistics/industry/agriculture/australian-agriculture-horticulture/2022-23/AAHDC_Aust_Horticulture_202223\\.xlsx"
      )
      expect_identical(basename(dest), "hort_crops_file")

      fs::dir_create(fs::path_dir(dest), recurse = TRUE)
      fs::file_create(dest)

      called_retry <<- TRUE
      invisible(NULL)
    },
    parse_abs_production_data = function(x) {
      data.table::data.table(Year = "2022-23")
    },
    {
      res <- read.abares::read_abs_horticulture_data(year = "latest", x = NULL)
      expect_true(called_retry)
      expect_s3_class(res, "data.table")
      expect_identical(res$Year[[1L]], "2022-23")
    },
    .package = "read.abares"
  )
})
