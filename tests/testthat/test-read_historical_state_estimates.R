test_that("reads from a provided local CSV path and sets key correctly", {
  skip_on_cran()

  df <- data.frame(
    Variable = "Farm cash income",
    Year = 2020L,
    State = "Western Australia",
    Industry = "Broadacre",
    Value = 111.1,
    RSE = 9.9,
    stringsAsFactors = FALSE,
    check.rows = FALSE
  )

  csv <- withr::local_tempfile(fileext = ".csv")
  data.table::fwrite(df, csv)
  expect_true(fs::file_exists(csv))

  out <- read_historical_state_estimates(x = csv)

  expect_s3_class(out, "data.table")
  expect_identical(nrow(out), 1L)
  expect_named(out, c("Variable", "Year", "State", "Industry", "Value", "RSE"))
  expect_true(data.table::haskey(out))
  expect_identical(data.table::key(out), "Variable")
  expect_identical(out$State, "Western Australia")
  expect_equal(out$Value, 111.1)
  expect_equal(out$RSE, 9.9)
})

test_that("when x is NULL it downloads (mocked) to tempdir and reads the CSV", {
  skip_on_cran()

  df <- data.frame(
    Variable = "Farm business profit",
    Year = 2021L,
    State = "New South Wales",
    Industry = "Mixed livestock–crops",
    Value = 222.2,
    RSE = 7.7,
    stringsAsFactors = FALSE,
    check.rows = FALSE
  )

  staged <- withr::local_tempfile(fileext = ".csv")
  data.table::fwrite(df, staged)
  expect_true(fs::file_exists(staged))

  target <- fs::path(tempdir(), "fdp-beta-state-historical.csv")
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

  expected_url <- "https://www.agriculture.gov.au/sites/default/files/documents/fdp-state-historical.csv"

  with_mocked_bindings(
    .retry_download = retry_mock,
    {
      out <- read_historical_state_estimates(x = NULL)

      expect_identical(last_url, expected_url)
      expect_true(fs::file_exists(target))
      expect_s3_class(out, "data.table")
      expect_identical(out$State, "New South Wales")
      expect_identical(out$Variable, "Farm business profit")
    }
  )
})

test_that("alias read_hist_st_est returns identical results", {
  skip_on_cran()

  df <- data.frame(
    Variable = "Total cash receipts",
    Year = 2022L,
    State = "Victoria",
    Industry = "Sheep",
    Value = 333.3,
    RSE = 6.6,
    stringsAsFactors = FALSE,
    check.rows = FALSE
  )

  csv <- withr::local_tempfile(fileext = ".csv")
  data.table::fwrite(df, csv)

  a <- read_historical_state_estimates(x = csv)
  b <- read_hist_st_est(x = csv)

  expect_true(data.table::is.data.table(a))
  expect_true(data.table::is.data.table(b))
  expect_true(data.table::fsetequal(a, b))
})

test_that("errors cleanly when the provided file does not exist", {
  skip_on_cran()
  skip_if_not_installed("data.table")

  bogus <- fs::path(tempdir(), "no-such-state-historical.csv")
  if (fs::file_exists(bogus)) {
    fs::file_delete(bogus)
  }

  expect_error(
    read_historical_state_estimates(x = bogus),
    regexp = "cannot open|does not exist|Failed to open|cannot find",
    ignore.case = TRUE
  )
})
