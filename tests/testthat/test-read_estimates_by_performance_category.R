test_that("reads from a provided local CSV path and returns a data.table", {
  skip_on_cran()

  # Create a small CSV with headers
  tmp_csv <- withr::local_tempfile(fileext = ".csv")
  DT_in <- data.table::data.table(
    Region = c("A", "B"),
    Year = c(2020L, 2021L),
    Value = c(1.23, 4.56)
  )
  data.table::fwrite(DT_in, tmp_csv)

  # Sanity
  expect_true(fs::file_exists(tmp_csv))

  out <- read_estimates_by_performance_category(x = tmp_csv)

  # Type and shape
  expect_true(data.table::is.data.table(out))
  expect_equal(nrow(out), nrow(DT_in))

  # Columns preserved as written (function currently does no renaming)
  expect_setequal(names(out), names(DT_in))

  # Data equality (order-insensitive)
  expect_true(data.table::fsetequal(out, DT_in))
})

test_that("when x is NULL it downloads (mocked) to tempdir and reads the CSV", {
  skip_on_cran()

  # Stage a CSV that we will "download"
  staged_csv <- withr::local_tempfile(fileext = ".csv")
  DT_stage <- data.table::data.table(
    region = c("North", "South"),
    year = c(2019L, 2020L),
    value = c(10.0, 20.0)
  )
  data.table::fwrite(DT_stage, staged_csv)

  # Expected target path used by the function when x = NULL
  target_csv <- fs::path(tempdir(), "fdp-BySize-ByPerformance.csv")
  if (fs::file_exists(target_csv)) {
    fs::file_delete(target_csv)
  }
  withr::defer({
    if (fs::file_exists(target_csv)) fs::file_delete(target_csv)
  })

  # Capture URL and ensure the staged file is copied to the expected target
  last_url <- NULL
  retry_mock <- function(url, .f) {
    last_url <<- url
    fs::file_copy(staged_csv, .f, overwrite = TRUE)
    invisible(.f)
  }

  expected_url <- "https://www.agriculture.gov.au/sites/default/files/documents/fdp-BySize-ByPerformance.csv"

  testthat::with_mocked_bindings(
    {
      out <- read_estimates_by_performance_category(x = NULL)

      # The function should have requested the right URL
      expect_identical(last_url, expected_url)

      # Target must now exist
      expect_true(fs::file_exists(target_csv))

      # Output must be a data.table with our staged content
      expect_true(data.table::is.data.table(out))
      expect_setequal(names(out), names(DT_stage))
      expect_true(data.table::fsetequal(out, DT_stage))
    },
    .retry_download = retry_mock
  )
})

test_that("alias read_est_by_perf_cat returns identical results", {
  skip_on_cran()

  tmp_csv <- withr::local_tempfile(fileext = ".csv")
  DT_in <- data.table::data.table(
    reg = c("X", "Y", "Z"),
    yr = c(2018L, 2019L, 2020L),
    val = c(0.1, 0.2, 0.3)
  )
  data.table::fwrite(DT_in, tmp_csv)

  a <- read_estimates_by_performance_category(x = tmp_csv)
  b <- read_est_by_perf_cat(x = tmp_csv)

  expect_true(data.table::is.data.table(a))
  expect_true(data.table::is.data.table(b))
  expect_true(data.table::fsetequal(a, b))
  expect_true(data.table::fsetequal(a, DT_in))
})

test_that("errors cleanly when the provided file does not exist", {
  skip_on_cran()

  # Point to a path that doesn't exist
  bogus <- fs::path(tempdir(), "nope-does-not-exist.csv")
  if (fs::file_exists(bogus)) {
    fs::file_delete(bogus)
  }

  expect_error(
    read_estimates_by_performance_category(x = bogus),
    regexp = "does not exist|cannot open|Open failed",
    ignore.case = TRUE
  )
})
