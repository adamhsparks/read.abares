test_that("read_estimates_by_performance_category returns a data.table", {
  # Create a temporary CSV file with sample data
  tmp <- tempfile(fileext = ".csv")
  write.csv(
    data.frame(
      category = c("A", "B"),
      value = c(10, 20)
    ),
    tmp,
    row.names = FALSE
  )

  result <- read_estimates_by_performance_category(tmp)
  expect_s3_class(result, "data.table")
})

test_that("read_estimates_by_performance_category reads provided file correctly", {
  tmp <- tempfile(fileext = ".csv")
  write.csv(
    data.frame(
      category = c("X", "Y"),
      value = c(1, 2)
    ),
    tmp,
    row.names = FALSE
  )

  result <- read_estimates_by_performance_category(tmp)
  expect_identical(result$category, c("X", "Y"))
  expect_identical(result$value, c(1, 2))
})

test_that("read_est_by_perf_cat is an alias", {
  tmp <- tempfile(fileext = ".csv")
  write.csv(
    data.frame(
      category = c("M", "N"),
      value = c(5, 6)
    ),
    tmp,
    row.names = FALSE
  )

  result1 <- read_estimates_by_performance_category(tmp)
  result2 <- read_est_by_perf_cat(tmp)
  expect_identical(result1, result2)
})

# Optional: if you know expected columns from ABARES data
test_that("ABARES data has expected columns", {
  tmp <- tempfile(fileext = ".csv")
  write.csv(
    data.frame(
      category = c("Test"),
      value = c(99)
    ),
    tmp,
    row.names = FALSE
  )

  result <- read_estimates_by_performance_category(tmp)
  expect_true(all(c("category", "value") %in% names(result)))
})
