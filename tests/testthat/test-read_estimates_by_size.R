test_that("read_estimates_by_size calls .retry_download when x is NULL", {
  ns <- asNamespace("read.abares")

  called <- FALSE
  fake_retry <- function(url, dest) {
    called <<- TRUE
    dest
  }

  fake_dt <- data.table::data.table(
    Variable = "Profit",
    Year = 2020,
    Size = "Small",
    Industry = "Grains",
    Value = 123,
    RSE = 5
  )

  fake_fread <- function(file, verbose) fake_dt

  with_mocked_bindings(
    {
      # patch fread
      old_fread <- data.table::fread
      assignInNamespace("fread", fake_fread, ns = "data.table")
      on.exit(
        assignInNamespace("fread", old_fread, ns = "data.table"),
        add = TRUE
      )

      result <- read_estimates_by_size()
      expect_true(called)
      expect_s3_class(result, "data.table")
      expect_equal(data.table::key(result), "Variable")
      expect_equal(
        names(result),
        c("Variable", "Year", "Size", "Industry", "Value", "RSE")
      )
    },
    .retry_download = fake_retry,
    .env = ns
  )
})

test_that("read_estimates_by_size bypasses download when x provided", {
  ns <- asNamespace("read.abares")

  fake_dt <- data.table::data.table(
    Variable = "Income",
    Year = 2021,
    Size = "Large",
    Industry = "Livestock",
    Value = 456,
    RSE = 10
  )

  fake_fread <- function(file, verbose) fake_dt

  # patch fread directly
  old_fread <- data.table::fread
  assignInNamespace("fread", fake_fread, ns = "data.table")
  on.exit(assignInNamespace("fread", old_fread, ns = "data.table"), add = TRUE)

  result <- read_estimates_by_size(x = "local.csv")
  expect_s3_class(result, "data.table")
  expect_equal(result$Variable, "Income")
  expect_equal(data.table::key(result), "Variable")
})

test_that("read_est_by_size alias works", {
  ns <- asNamespace("read.abares")

  fake_dt <- data.table::data.table(
    Variable = "Costs",
    Year = 2022,
    Size = "Medium",
    Industry = "Mixed",
    Value = 789,
    RSE = 15
  )

  fake_fread <- function(file, verbose) fake_dt

  old_fread <- data.table::fread
  assignInNamespace("fread", fake_fread, ns = "data.table")
  on.exit(assignInNamespace("fread", old_fread, ns = "data.table"), add = TRUE)

  result <- read_est_by_size(x = "alias.csv")
  expect_s3_class(result, "data.table")
  expect_equal(result$Variable, "Costs")
  expect_equal(data.table::key(result), "Variable")
})
