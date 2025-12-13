test_that("read_historical_state_estimates calls .retry_download when x is NULL", {
  ns <- asNamespace("read.abares")

  called <- FALSE
  fake_retry <- function(url, dest) {
    called <<- TRUE
    dest
  }

  fake_dt <- data.table::data.table(
    Variable = "Production",
    Year = 2020,
    State = "WA",
    Industry = "Grains",
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

      result <- read_historical_state_estimates()
      expect_true(called)
      expect_s3_class(result, "data.table")
      expect_equal(data.table::key(result), "Variable")
      expect_equal(
        names(result),
        c("Variable", "Year", "State", "Industry", "Value", "RSE")
      )
    },
    .retry_download = fake_retry,
    .env = ns
  )
})

test_that("read_historical_state_estimates bypasses download when x provided", {
  ns <- asNamespace("read.abares")

  fake_dt <- data.table::data.table(
    Variable = "Exports",
    Year = 2021,
    State = "NSW",
    Industry = "Livestock",
    Value = 200,
    RSE = 10
  )

  fake_fread <- function(file, verbose) fake_dt

  old_fread <- data.table::fread
  assignInNamespace("fread", fake_fread, ns = "data.table")
  on.exit(assignInNamespace("fread", old_fread, ns = "data.table"), add = TRUE)

  result <- read_historical_state_estimates(x = "local.csv")
  expect_s3_class(result, "data.table")
  expect_equal(result$Variable, "Exports")
  expect_equal(data.table::key(result), "Variable")
})

test_that("read_hist_st_est alias works", {
  ns <- asNamespace("read.abares")

  fake_dt <- data.table::data.table(
    Variable = "Imports",
    Year = 2022,
    State = "VIC",
    Industry = "Mixed",
    Value = 300,
    RSE = 15
  )

  fake_fread <- function(file, verbose) fake_dt

  old_fread <- data.table::fread
  assignInNamespace("fread", fake_fread, ns = "data.table")
  on.exit(assignInNamespace("fread", old_fread, ns = "data.table"), add = TRUE)

  result <- read_hist_st_est(x = "alias.csv")
  expect_s3_class(result, "data.table")
  expect_equal(result$Variable, "Imports")
  expect_equal(data.table::key(result), "Variable")
})
