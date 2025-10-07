test_that("reads from a provided local CSV path, renames columns, and sets key", {
  skip_if_offline()

  df <- data.frame(
    Variable = "Farm cash income",
    Year = 2020L,
    `ABARES region` = "South West WA",
    Value = 321.0,
    RSE = 12.5,
    stringsAsFactors = FALSE,
    check.names = FALSE
  )

  csv <- withr::local_tempfile(fileext = ".csv")
  data.table::fwrite(df, csv)
  expect_true(fs::file_exists(csv))

  out <- read_historical_regional_estimates(x = csv)

  expect_s3_class(out, "data.table")
  expect_identical(nrow(out), 1L)
  expect_named(out, c("Variable", "Year", "ABARES_region", "Value", "RSE"))
  expect_true(data.table::haskey(out))
  expect_identical(data.table::key(out), "Variable")
  expect_identical(out$ABARES_region, "South West WA")
  expect_equal(out$Value, 321.0)
  expect_equal(out$RSE, 12.5)
})

test_that("when x is NULL it downloads (mocked) to tempdir and reads the CSV", {
  skip_if_offline()

  df <- data.frame(
    Variable = "Farm business profit",
    Year = 2021L,
    `ABARES region` = "Northern NSW",
    Value = 654.3,
    RSE = 8.9,
    stringsAsFactors = FALSE,
    check.names = FALSE
  )

  staged <- withr::local_tempfile(fileext = ".csv")
  data.table::fwrite(df, staged)
  expect_true(fs::file_exists(staged))

  target <- fs::path(tempdir(), "fdp-beta-regional-historical.csv")
  if (fs::file_exists(target)) {
    fs::file_delete(target)
  }
  withr::defer({
    if (fs::file_exists(target)) fs::file_delete(target)
  })

  last_url <- NULL
  retry_mock <- function(url, dest, dataset_id, show_progress = TRUE, ...) {
    last_url <<- url
    fs::file_copy(staged, dest, overwrite = TRUE)
    invisible(dest)
  }

  expected_url <- "https://www.agriculture.gov.au/sites/default/files/documents/fdp-regional-historical.csv"

  with_mocked_bindings(
    .retry_download = retry_mock,
    {
      out <- read_historical_regional_estimates(x = NULL)

      expect_identical(last_url, expected_url)
      expect_true(fs::file_exists(target))
      expect_s3_class(out, "data.table")
      expect_identical(out$ABARES_region, "Northern NSW")
      expect_identical(out$Variable, "Farm business profit")
    }
  )
})

test_that("alias read_hist_reg_est returns identical results", {
  skip_if_offline()

  df <- data.frame(
    Variable = "Total cash receipts",
    Year = 2022L,
    `ABARES region` = "Mallee VIC",
    Value = 987.6,
    RSE = 6.7,
    stringsAsFactors = FALSE,
    check.names = FALSE
  )

  csv <- withr::local_tempfile(fileext = ".csv")
  data.table::fwrite(df, csv)

  a <- read_historical_regional_estimates(x = csv)
  b <- read_hist_reg_est(x = csv)

  expect_s3_class(a, "data.table")
  expect_s3_class(b, "data.table")
  expect_true(data.table::fsetequal(a, b))
})

test_that("errors cleanly when the provided file does not exist", {
  skip_if_offline()
  skip_if_not_installed("data.table")

  bogus <- fs::path(tempdir(), "no-such-regional-historical.csv")
  if (fs::file_exists(bogus)) {
    fs::file_delete(bogus)
  }

  expect_error(
    read_historical_regional_estimates(x = bogus),
    regexp = "cannot open|does not exist|Failed to open|cannot find",
    ignore.case = TRUE
  )
})
