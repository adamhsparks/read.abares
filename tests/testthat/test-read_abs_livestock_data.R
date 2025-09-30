testthat::test_that("read_abs_livestock_data() uses .retry_download (mocked), resolves 'latest', and parses the downloaded file", {
  called_retry <- FALSE
  called_parse <- FALSE
  got_retry_f <- NULL
  got_parse_x <- NULL

  available_years <- c("2022-23", "2021-22")

  testthat::with_mocked_bindings(
    .find_years = function(data_set) {
      testthat::expect_identical(data_set, "livestock")
      available_years
    },
    .retry_download = function(url, .f, base_delay = 1L) {
      # Ensure full base URL + year + encoded file name + year suffix
      testthat::expect_match(
        url,
        "^https://www\\.abs\\.gov\\.au/statistics/industry/agriculture/australian-agriculture-livestock/2022-23/AALDC_Value%20of%20livestock%20and%20products%202022-23\\.xlsx$"
      )
      # Download target name is deterministic
      testthat::expect_identical(fs::path_file(.f), "livestock_file")

      # Create the file (using fs)
      fs::dir_create(fs::path_dir(.f), recurse = TRUE)
      fs::file_create(.f)

      got_retry_f <<- .f
      called_retry <<- TRUE
      invisible(NULL)
    },
    parse_abs_production_data = function(x) {
      called_parse <<- TRUE
      got_parse_x <<- x
      data.table::data.table(
        Dataset = "ABS livestock",
        Year = "2022-23",
        Rows = 1L
      )
    },
    {
      res <- read.abares::read_abs_livestock_data(year = "latest", x = NULL)

      # Ensure mocks ran
      testthat::expect_true(called_retry)
      testthat::expect_true(called_parse)

      # Ensure parsed path equals the download target and exists
      testthat::expect_false(is.null(got_retry_f))
      testthat::expect_identical(got_parse_x, got_retry_f)
      testthat::expect_true(fs::file_exists(got_parse_x))

      testthat::expect_s3_class(res, "data.table")
      testthat::expect_identical(nrow(res), 1L)
      testthat::expect_named(res, c("Dataset", "Year", "Rows"))
      testthat::expect_identical(res$Year[[1L]], "2022-23")
    },
    .package = "read.abares"
  )
})

testthat::test_that("read_abs_livestock_data() constructs URL correctly for an explicit year", {
  called_retry <- FALSE
  called_parse <- FALSE
  got_retry_f <- NULL
  got_parse_x <- NULL

  available_years <- c("2021-22", "2020-21")

  testthat::with_mocked_bindings(
    .find_years = function(data_set) {
      testthat::expect_identical(data_set, "livestock")
      available_years
    },
    .retry_download = function(url, .f, base_delay = 1L) {
      # Explicit year (note dashes are NOT removed for this dataset)
      testthat::expect_match(
        url,
        "^https://www\\.abs\\.gov\\.au/statistics/industry/agriculture/australian-agriculture-livestock/2021-22/AALDC_Value%20of%20livestock%20and%20products%202021-22\\.xlsx$"
      )
      testthat::expect_identical(fs::path_file(.f), "livestock_file")

      fs::dir_create(fs::path_dir(.f), recurse = TRUE)
      fs::file_create(.f)

      got_retry_f <<- .f
      called_retry <<- TRUE
      invisible(NULL)
    },
    parse_abs_production_data = function(x) {
      called_parse <<- TRUE
      got_parse_x <<- x
      data.table::data.table(Year = "2021-22", OK = TRUE)
    },
    {
      res <- read.abares::read_abs_livestock_data(year = "2021-22", x = NULL)

      testthat::expect_true(called_retry)
      testthat::expect_true(called_parse)
      testthat::expect_identical(got_parse_x, got_retry_f)
      testthat::expect_true(fs::file_exists(got_parse_x))

      testthat::expect_s3_class(res, "data.table")
      testthat::expect_identical(res$Year[[1L]], "2021-22")
      testthat::expect_true(res$OK[[1L]])
    },
    .package = "read.abares"
  )
})

testthat::test_that("read_abs_livestock_data() reads a provided path without calling .retry_download or .find_years", {
  tmp_dir <- withr::local_tempdir()
  x_path <- fs::path(tmp_dir, "abs_livestock_mock.xlsx")
  fs::file_create(x_path)

  called_parse <- FALSE

  testthat::with_mocked_bindings(
    .find_years = function(...) {
      stop("`.find_years()` should not be called when x != NULL")
    },
    .retry_download = function(...) {
      stop("`.retry_download()` should not be called when x != NULL")
    },
    parse_abs_production_data = function(x) {
      testthat::expect_identical(x, x_path)
      called_parse <<- TRUE
      data.table::data.table(FromPath = TRUE)
    },
    {
      res <- read.abares::read_abs_livestock_data(x = x_path)

      testthat::expect_true(called_parse)
      testthat::expect_s3_class(res, "data.table")
      testthat::expect_true(res$FromPath[[1L]])
    },
    .package = "read.abares"
  )
})

testthat::test_that("read_abs_livestock_data() validates year argument", {
  available_years <- c("2023-24", "2022-23")

  # Invalid year should error (not in available and not 'latest')
  testthat::with_mocked_bindings(
    .find_years = function(data_set) {
      testthat::expect_identical(data_set, "livestock")
      available_years
    },
    .retry_download = function(...) {
      stop("`.retry_download()` should not be called on arg error")
    },
    parse_abs_production_data = function(...) {
      stop("`parse_abs_production_data()` should not be called on arg error")
    },
    {
      testthat::expect_error(
        read.abares::read_abs_livestock_data(year = "2019-20", x = NULL),
        regexp = "year|must be one of|`year`"
      )
    },
    .package = "read.abares"
  )
})

testthat::test_that("read_abs_livestock_data() uses the 'latest' year (first in available)", {
  called_retry <- FALSE

  available_years <- c("2022-23", "2021-22", "2020-21")

  testthat::with_mocked_bindings(
    .find_years = function(data_set) {
      testthat::expect_identical(data_set, "livestock")
      available_years
    },
    .retry_download = function(url, .f, base_delay = 1L) {
      # Should pick "2022-23" (first) and keep dashes in file name
      testthat::expect_match(
        url,
        "/2022-23/AALDC_Value%20of%20livestock%20and%20products%202022-23\\.xlsx$"
      )
      testthat::expect_identical(fs::path_file(.f), "livestock_file")

      fs::dir_create(fs::path_dir(.f), recurse = TRUE)
      fs::file_create(.f)

      called_retry <<- TRUE
      invisible(NULL)
    },
    parse_abs_production_data = function(x) {
      data.table::data.table(Year = "2022-23")
    },
    {
      res <- read.abares::read_abs_livestock_data(year = "latest", x = NULL)
      testthat::expect_true(called_retry)
      testthat::expect_s3_class(res, "data.table")
      testthat::expect_identical(res$Year[[1L]], "2022-23")
    },
    .package = "read.abares"
  )
})
