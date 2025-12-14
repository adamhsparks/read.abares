test_that("read_estimates_by_performance_category calls .retry_download when x is NULL", {
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
    Performance = "High",
    Industry = "Grains",
    Value = 123,
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

      result <- read_estimates_by_performance_category()
      expect_true(called)
      expect_s3_class(result, "data.table")
      expect_identical(result$Variable, "Profit")
      expect_identical(result$Performance, "High")
    },
    .retry_download = fake_retry,
    .env = ns
  )
})

test_that("read_estimates_by_performance_category bypasses download when x provided", {
  ns <- asNamespace("read.abares")

  fake_dt <- data.table::data.table(
    Variable = "Income",
    Year = 2021,
    Size = "Large",
    Performance = "Low",
    Industry = "Livestock",
    Value = 456,
    RSE = 10
  )

  fake_fread <- function(file, verbose) fake_dt

  old_fread <- data.table::fread
  assignInNamespace("fread", fake_fread, ns = "data.table")
  on.exit(assignInNamespace("fread", old_fread, ns = "data.table"), add = TRUE)

  result <- read_estimates_by_performance_category(x = "local.csv")
  expect_s3_class(result, "data.table")
  expect_identical(result$Variable, "Income")
  expect_identical(result$Performance, "Low")
})

test_that("read_est_by_perf_cat alias works", {
  ns <- asNamespace("read.abares")

  fake_dt <- data.table::data.table(
    Variable = "Costs",
    Year = 2022,
    Size = "Medium",
    Performance = "Average",
    Industry = "Mixed",
    Value = 789,
    RSE = 15
  )

  fake_fread <- function(file, verbose) fake_dt

  old_fread <- data.table::fread
  assignInNamespace("fread", fake_fread, ns = "data.table")
  on.exit(assignInNamespace("fread", old_fread, ns = "data.table"), add = TRUE)

  result <- read_est_by_perf_cat(x = "alias.csv")
  expect_s3_class(result, "data.table")
  expect_identical(result$Variable, "Costs")
  expect_identical(result$Performance, "Average")
})
