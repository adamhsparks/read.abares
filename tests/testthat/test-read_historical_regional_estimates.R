test_that("read_historical_regional_estimates calls .retry_download when x is NULL", {
  ns <- asNamespace("read.abares")

  called <- FALSE
  fake_retry <- function(url, dest) {
    called <<- TRUE
    dest
  }

  fake_dt <- data.table::data.table(
    Variable = "Production",
    Year = 2020,
    `ABARES region` = "Region A",
    Value = 100,
    RSE = 5
  )

  fake_fread <- function(file, verbose) fake_dt

  with_mocked_bindings(
    {
      old_fread <- data.table::fread
      assignInNamespace("fread", fake_fread, ns = "data.table")
      on.exit(
        assignInNamespace("fread", old_fread, ns = "data.table"),
        add = TRUE
      )

      result <- read_historical_regional_estimates()
      expect_true(called)
      expect_s3_class(result, "data.table")
      expect_identical(data.table::key(result), "Variable")
      expect_named(
        result,
        c("Variable", "Year", "ABARES_region", "Value", "RSE")
      )
      expect_identical(result$ABARES_region, "Region A")
    },
    .retry_download = fake_retry,
    .env = ns
  )
})

test_that("read_historical_regional_estimates bypasses download when x provided", {
  ns <- asNamespace("read.abares")

  fake_dt <- data.table::data.table(
    Variable = "Exports",
    Year = 2021,
    `ABARES region` = "Region B",
    Value = 200,
    RSE = 10
  )

  fake_fread <- function(file, verbose) fake_dt

  old_fread <- data.table::fread
  assignInNamespace("fread", fake_fread, ns = "data.table")
  on.exit(assignInNamespace("fread", old_fread, ns = "data.table"), add = TRUE)

  result <- read_historical_regional_estimates(x = "local.csv")
  expect_s3_class(result, "data.table")
  expect_identical(result$Variable, "Exports")
  expect_identical(result$ABARES_region, "Region B")
  expect_identical(data.table::key(result), "Variable")
})

test_that("read_hist_reg_est alias works", {
  ns <- asNamespace("read.abares")

  fake_dt <- data.table::data.table(
    Variable = "Imports",
    Year = 2022,
    `ABARES region` = "Region C",
    Value = 300,
    RSE = 15
  )

  fake_fread <- function(file, verbose) fake_dt

  old_fread <- data.table::fread
  assignInNamespace("fread", fake_fread, ns = "data.table")
  on.exit(assignInNamespace("fread", old_fread, ns = "data.table"), add = TRUE)

  result <- read_hist_reg_est(x = "alias.csv")
  expect_s3_class(result, "data.table")
  expect_identical(result$Variable, "Imports")
  expect_identical(result$ABARES_region, "Region C")
  expect_identical(data.table::key(result), "Variable")
})
