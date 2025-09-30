test_that("reads from a provided local CSV path and sets key correctly", {
  skip_on_cran()

  df <- data.frame(
    Variable = "Farm cash income",
    Year = 2020L,
    Industry = "All broadacre",
    Value = 123.4,
    RSE = 15.2,
    stringsAsFactors = FALSE
  )

  csv <- withr::local_tempfile(fileext = ".csv")
  data.table::fwrite(df, csv)
  expect_true(fs::file_exists(csv))

  out <- read_historical_national_estimates(x = csv)

  expect_s3_class(out, "data.table")
  expect_identical(nrow(out), 1L)
  expect_named(out, c("Variable", "Year", "Industry", "Value", "RSE"))
  expect_true(data.table::haskey(out))
  expect_identical(data.table::key(out), "Variable")
  expect_identical(out$Variable, "Farm cash income")
  expect_identical(out$Year, 2020L)
  expect_identical(out$Industry, "All broadacre")
  expect_equal(out$Value, 123.4)
  expect_equal(out$RSE, 15.2)
})

test_that("when x is NULL it downloads (mocked) to tempdir and reads the CSV", {
  skip_on_cran()

  df <- data.frame(
    Variable = "Farm business profit",
    Year = 2021L,
    Industry = "Mixed livestock–crops",
    Value = 456.7,
    RSE = 10.1,
    stringsAsFactors = FALSE
  )

  staged <- withr::local_tempfile(fileext = ".csv")
  data.table::fwrite(df, staged)
  expect_true(fs::file_exists(staged))

  target <- fs::path(tempdir(), "fdp-beta-national-historical.csv")
  if (fs::file_exists(target)) {
    fs::file_delete(target)
  }
  withr::defer({
    if (fs::file_exists(target)) fs::file_delete(target)
  })

  last_url <- NULL
  retry_mock <- function(url, .f) {
    last_url <<- url
    fs::file_copy(staged, .f, overwrite = TRUE)
    invisible(.f)
  }

  expected_url <- "https://www.agriculture.gov.au/sites/default/files/documents/fdp-national-historical.csv"

  testthat::with_mocked_bindings(
    {
      out <- read_historical_national_estimates(x = NULL)

      expect_identical(last_url, expected_url)
      expect_true(fs::file_exists(target))
      expect_s3_class(out, "data.table")
      expect_identical(out$Variable, "Farm business profit")
      expect_identical(out$Year, 2021L)
    },
    .retry_download = retry_mock
  )
})

test_that("alias read_hist_nat_est returns identical results", {
  skip_on_cran()

  df <- data.frame(
    Variable = "Total cash receipts",
    Year = 2022L,
    Industry = "Sheep",
    Value = 789.0,
    RSE = 5.5,
    stringsAsFactors = FALSE
  )

  csv <- withr::local_tempfile(fileext = ".csv")
  data.table::fwrite(df, csv)

  a <- read_historical_national_estimates(x = csv)
  b <- read_hist_nat_est(x = csv)

  expect_true(data.table::is.data.table(a))
  expect_true(data.table::is.data.table(b))
  expect_true(data.table::fsetequal(a, b))
})

test_that("errors cleanly when the provided file does not exist", {
  skip_on_cran()
  skip_if_not_installed("data.table")

  bogus <- fs::path(tempdir(), "no-such-national-historical.csv")
  if (fs::file_exists(bogus)) {
    fs::file_delete(bogus)
  }

  expect_error(
    read_historical_national_estimates(x = bogus),
    regexp = "cannot open|does not exist|Failed to open|cannot find",
    ignore.case = TRUE
  )
})
