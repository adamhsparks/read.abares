testthat::test_that("read_abs_broadacre_data() uses .retry_download (mocked), maps 'winter' and uses latest year", {
  called_retry <- FALSE
  called_parse <- FALSE
  got_x <- NULL

  available_years <- c("2023-24", "2022-23")

  testthat::with_mocked_bindings(
    .find_years = function(data_set) {
      testthat::expect_identical(data_set, "broadacre")
      available_years
    },
    .retry_download = function(url, .f, base_delay = 1L) {
      # Expect 'latest' resolves to first element of available_years
      testthat::expect_match(
        url,
        "/2023-24/AABDC_winter_broadacre_202324\\.xlsx$"
      )
      testthat::expect_identical(basename(.f), "winter_broadacre_crops_file")

      # Create an empty file to simulate a download target existing
      if (!file.exists(.f)) {
        dir.create(dirname(.f), showWarnings = FALSE, recursive = TRUE)
        file.create(.f)
      }

      called_retry <<- TRUE
      invisible(NULL)
    },
    parse_abs_production_data = function(x) {
      called_parse <<- TRUE
      got_x <<- x
      # Return a small, realistic sentinel result
      data.table::data.table(
        Source = "ABS",
        Crop = "winter_broadacre",
        Year = "2023-24",
        Rows = 1L
      )
    },
    {
      res <- read.abares::read_abs_broadacre_data(
        crops = "winter",
        year = "latest",
        x = NULL
      )

      # Ensure the mocks ran
      testthat::expect_true(called_retry)
      testthat::expect_true(called_parse)
      testthat::expect_true(file.exists(got_x))

      testthat::expect_s3_class(res, "data.table")
      testthat::expect_identical(nrow(res), 1L)
      testthat::expect_named(res, c("Source", "Crop", "Year", "Rows"))
      testthat::expect_identical(res$Crop[[1L]], "winter_broadacre")
      testthat::expect_identical(res$Year[[1L]], "2023-24")
    },
    .package = "read.abares"
  )
})

testthat::test_that("read_abs_broadacre_data() constructs URL correctly for 'summer' with explicit year", {
  called_retry <- FALSE
  called_parse <- FALSE

  available_years <- c("2022-23", "2021-22")

  testthat::with_mocked_bindings(
    .find_years = function(data_set) {
      testthat::expect_identical(data_set, "broadacre")
      available_years
    },
    .retry_download = function(url, .f, base_delay = 1L) {
      testthat::expect_match(
        url,
        "/2021-22/AABDC_summer_202122\\.xlsx$"
      )
      testthat::expect_identical(basename(.f), "summer_crops_file")
      # Create an empty file to satisfy parse path
      if (!file.exists(.f)) {
        dir.create(dirname(.f), showWarnings = FALSE, recursive = TRUE)
        file.create(.f)
      }
      called_retry <<- TRUE
      invisible(NULL)
    },
    parse_abs_production_data = function(x) {
      called_parse <<- TRUE
      data.table::data.table(Crop = "summer", Year = "2021-22")
    },
    {
      res <- read.abares::read_abs_broadacre_data(
        crops = "summer",
        year = "2021-22",
        x = NULL
      )
      testthat::expect_true(called_retry)
      testthat::expect_true(called_parse)
      testthat::expect_s3_class(res, "data.table")
      testthat::expect_identical(res$Crop[[1L]], "summer")
      testthat::expect_identical(res$Year[[1L]], "2021-22")
    },
    .package = "read.abares"
  )
})

testthat::test_that("read_abs_broadacre_data() constructs URL correctly for 'sugarcane' with explicit year", {
  called_retry <- FALSE
  called_parse <- FALSE

  available_years <- c("2022-23", "2021-22")

  testthat::with_mocked_bindings(
    .find_years = function(data_set) {
      testthat::expect_identical(data_set, "broadacre")
      available_years
    },
    .retry_download = function(url, .f, base_delay = 1L) {
      testthat::expect_match(
        url,
        "/2022-23/AABDC_sugarcane_202223\\.xlsx$"
      )
      testthat::expect_identical(basename(.f), "sugarcane_crops_file")
      if (!file.exists(.f)) {
        dir.create(dirname(.f), showWarnings = FALSE, recursive = TRUE)
        file.create(.f)
      }
      called_retry <<- TRUE
      invisible(NULL)
    },
    parse_abs_production_data = function(x) {
      called_parse <<- TRUE
      data.table::data.table(Crop = "sugarcane", Year = "2022-23")
    },
    {
      res <- read.abares::read_abs_broadacre_data(
        crops = "sugarcane",
        year = "2022-23",
        x = NULL
      )
      testthat::expect_true(called_retry)
      testthat::expect_true(called_parse)
      testthat::expect_s3_class(res, "data.table")
      testthat::expect_identical(res$Crop[[1L]], "sugarcane")
      testthat::expect_identical(res$Year[[1L]], "2022-23")
    },
    .package = "read.abares"
  )
})

testthat::test_that("read_abs_broadacre_data() reads a provided path without calling .retry_download or .find_years", {
  tmp_dir <- withr::local_tempdir()
  x_path <- fs::path(tmp_dir, "abs_broadacre_mock.xlsx")
  file.create(x_path)

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
      data.table::data.table(OK = TRUE)
    },
    {
      res <- read.abares::read_abs_broadacre_data(x = x_path)
      testthat::expect_true(called_parse)
      testthat::expect_s3_class(res, "data.table")
      testthat::expect_true(res$OK[[1L]])
    },
    .package = "read.abares"
  )
})

testthat::test_that("read_abs_broadacre_data() validates arguments for crops and year", {
  available_years <- c("2023-24", "2022-23")

  # Invalid crop should error
  testthat::with_mocked_bindings(
    .find_years = function(data_set) {
      testthat::expect_identical(data_set, "broadacre")
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
        read.abares::read_abs_broadacre_data(
          crops = "notacrop",
          year = "latest"
        ),
        regexp = "crops|must be one of|`crops`"
      )
    },
    .package = "read.abares"
  )

  # Invalid year should error (not in available and not 'latest')
  testthat::with_mocked_bindings(
    .find_years = function(data_set) {
      testthat::expect_identical(data_set, "broadacre")
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
        read.abares::read_abs_broadacre_data(
          crops = "winter",
          year = "2019-20"
        ),
        regexp = "year|must be one of|`year`"
      )
    },
    .package = "read.abares"
  )
})
