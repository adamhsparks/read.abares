test_that("read_abs_broadacre_data() uses .retry_download (mocked), maps 'winter' and uses latest year", {
  called_retry <- FALSE
  called_parse <- FALSE
  got_x <- NULL

  available_years <- c("2023-24", "2022-23")

  with_mocked_bindings(
    .find_years = function(data_set) {
      expect_identical(data_set, "broadacre")
      available_years
    },
    .retry_download = function(url, dest, .max_tries = 3L) {
      # Expect 'latest' resolves to first element of available_years and winter -> Winter_Broadacre
      expect_match(
        url,
        "^https://www\\.abs\\.gov\\.au/statistics/industry/agriculture/australian-agriculture-broadacre-crops/2023-24/AABDC_Winter_Broadacre_202324\\.xlsx$"
      )
      expect_identical(basename(dest), "Winter_Broadacre_crops_file")
      expect_identical(.max_tries, 3L)

      # Create an empty file to simulate a download target existing
      fs::dir_create(fs::path_dir(dest), recurse = TRUE)
      fs::file_create(dest)

      called_retry <<- TRUE
      got_x <<- dest
      invisible(NULL)
    },
    parse_abs_production_data = function(x) {
      called_parse <<- TRUE
      expect_identical(x, got_x)
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
      expect_true(called_retry)
      expect_true(called_parse)
      expect_true(file.exists(got_x))

      expect_s3_class(res, "data.table")
      expect_identical(nrow(res), 1L)
      expect_named(res, c("Source", "Crop", "Year", "Rows"))
      expect_identical(res$Crop[[1L]], "winter_broadacre")
      expect_identical(res$Year[[1L]], "2023-24")
    },
    .package = "read.abares"
  )
})

test_that("read_abs_broadacre_data() constructs URL correctly for 'summer' with explicit year", {
  called_retry <- FALSE
  called_parse <- FALSE

  available_years <- c("2022-23", "2021-22")

  with_mocked_bindings(
    .find_years = function(data_set) {
      expect_identical(data_set, "broadacre")
      available_years
    },
    .retry_download = function(url, dest, .max_tries = 3L) {
      expect_match(
        url,
        "^https://www\\.abs\\.gov\\.au/statistics/industry/agriculture/australian-agriculture-broadacre-crops/2021-22/AABDC_Summer_202122\\.xlsx$"
      )
      expect_identical(basename(dest), "Summer_crops_file")
      expect_identical(.max_tries, 3L)

      # Create an empty file to satisfy parse path
      fs::dir_create(fs::path_dir(dest), recurse = TRUE)
      fs::file_create(dest)
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
      expect_true(called_retry)
      expect_true(called_parse)
      expect_s3_class(res, "data.table")
      expect_identical(res$Crop[[1L]], "summer")
      expect_identical(res$Year[[1L]], "2021-22")
    },
    .package = "read.abares"
  )
})

test_that("read_abs_broadacre_data() constructs URL correctly for 'sugarcane' with explicit year", {
  called_retry <- FALSE
  called_parse <- FALSE

  available_years <- c("2022-23", "2021-22")

  with_mocked_bindings(
    .find_years = function(data_set) {
      expect_identical(data_set, "broadacre")
      available_years
    },
    .retry_download = function(url, dest, .max_tries = 3L) {
      expect_match(
        url,
        "^https://www\\.abs\\.gov\\.au/statistics/industry/agriculture/australian-agriculture-broadacre-crops/2022-23/AABDC_Sugarcane_202223\\.xlsx$"
      )
      expect_identical(basename(dest), "Sugarcane_crops_file")
      expect_identical(.max_tries, 3L)

      fs::dir_create(fs::path_dir(dest), recurse = TRUE)
      fs::file_create(dest)
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
      expect_true(called_retry)
      expect_true(called_parse)
      expect_s3_class(res, "data.table")
      expect_identical(res$Crop[[1L]], "sugarcane")
      expect_identical(res$Year[[1L]], "2022-23")
    },
    .package = "read.abares"
  )
})

test_that("read_abs_broadacre_data() reads a provided path without calling .retry_download or .find_years", {
  tmp_dir <- withr::local_tempdir()
  x_path <- fs::path(tmp_dir, "abs_broadacre_mock.xlsx")
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
      data.table::data.table(OK = TRUE)
    },
    {
      res <- read.abares::read_abs_broadacre_data(x = x_path)
      expect_true(called_parse)
      expect_s3_class(res, "data.table")
      expect_true(res$OK[[1L]])
    },
    .package = "read.abares"
  )
})

test_that("read_abs_broadacre_data() validates arguments for crops and year", {
  available_years <- c("2023-24", "2022-23")

  # Invalid crop should error
  with_mocked_bindings(
    .find_years = function(data_set) {
      expect_identical(data_set, "broadacre")
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
  with_mocked_bindings(
    .find_years = function(data_set) {
      expect_identical(data_set, "broadacre")
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
