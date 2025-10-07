test_that("reads from a provided local CSV path, reorders columns, and sets key = 'Variable'", {
  skip_on_cran()

  # Create a small CSV with the required columns but in a shuffled order
  tmp_csv <- withr::local_tempfile(fileext = ".csv")
  DT_in <- data.table::data.table(
    Industry = c("Beef", "Dairy", "Cropping"),
    Value = c(1.1, 2.2, 3.3),
    RSE = c(5.0, 10.0, 15.0),
    Year = c(2020L, 2021L, 2022L),
    Variable = c("Revenue", "Costs", "Profit"),
    Size = c("Small", "Medium", "Large")
  )
  # Write with shuffled column order to ensure the function reorders correctly
  data.table::fwrite(
    DT_in[, .(Industry, Value, RSE, Year, Variable, Size)],
    tmp_csv
  )

  out <- read_estimates_by_size(x = tmp_csv)

  # Type and shape
  expect_s3_class(out, "data.table")
  expect_identical(nrow(out), nrow(DT_in))

  # Exact column order enforced by the function
  expect_named(
    out,
    c("Variable", "Year", "Size", "Industry", "Value", "RSE")
  )

  # Key must be set to "Variable"
  expect_true(data.table::haskey(out))
  expect_identical(data.table::key(out), "Variable")

  # Data equality ignoring row order (setkey may reorder rows)
  expect_true(data.table::fsetequal(
    out,
    DT_in[, .(Variable, Year, Size, Industry, Value, RSE)]
  ))
})

test_that("when x is NULL it downloads (mocked) to tempdir and reads/reorders/keys the CSV", {
  skip_on_cran()

  # Stage a CSV that we will "download"
  staged_csv <- withr::local_tempfile(fileext = ".csv")
  DT_stage <- data.table::data.table(
    Variable = c("Profit", "Revenue"),
    Year = c(2022L, 2021L),
    Size = c("Large", "Small"),
    Industry = c("Cropping", "Beef"),
    Value = c(3.3, 1.1),
    RSE = c(12.5, 6.7)
  )
  data.table::fwrite(DT_stage, staged_csv)

  # Expected target path used by the function when x = NULL
  target_csv <- fs::path(tempdir(), "fdp-beta-performance-by-size.csv")
  if (fs::file_exists(target_csv)) {
    fs::file_delete(target_csv)
  }
  withr::defer({
    if (fs::file_exists(target_csv)) fs::file_delete(target_csv)
  })

  # Capture URL and ensure the staged file is copied to the expected target
  last_url <- NULL
  retry_mock <- function(url, dest, dataset_id, show_progress) {
    last_url <<- url
    fs::file_copy(staged_csv, dest, overwrite = TRUE)
    invisible(dest)
  }

  expected_url <- "https://www.agriculture.gov.au/sites/default/files/documents/fdp-performance-by-size.csv"

  local_mocked_bindings(
    .retry_download = retry_mock
  )

  out <- read_estimates_by_size(x = NULL)

  # The function should have requested the right URL
  expect_identical(last_url, expected_url)
  # Target must now exist
  expect_true(fs::file_exists(target_csv))

  # Output must be a data.table with correct order and key
  expect_s3_class(out, "data.table")
  expect_named(
    out,
    c("Variable", "Year", "Size", "Industry", "Value", "RSE")
  )
  expect_true(data.table::haskey(out))
  expect_identical(data.table::key(out), "Variable")

  # Content equality ignoring row order
  expect_true(data.table::fsetequal(out, DT_stage))
})

test_that("alias read_est_by_size returns identical results", {
  skip_on_cran()

  tmp_csv <- withr::local_tempfile(fileext = ".csv")
  DT_in <- data.table::data.table(
    Variable = c("A", "B", "C"),
    Year = c(2018L, 2019L, 2020L),
    Size = c("Small", "Medium", "Large"),
    Industry = c("Beef", "Dairy", "Sheep"),
    Value = c(10.1, 20.2, 30.3),
    RSE = c(5.0, 7.5, 10.0)
  )
  data.table::fwrite(DT_in, tmp_csv)

  a <- read_estimates_by_size(x = tmp_csv)
  b <- read_est_by_size(x = tmp_csv)

  expect_s3_class(a, "data.table")
  expect_s3_class(b, "data.table")
  expect_true(data.table::fsetequal(a, b))
  # Also ensure both reorder columns and set the key
  expect_named(
    a,
    c("Variable", "Year", "Size", "Industry", "Value", "RSE")
  )
  expect_identical(data.table::key(a), "Variable")
  expect_named(
    b,
    c("Variable", "Year", "Size", "Industry", "Value", "RSE")
  )
  expect_identical(data.table::key(b), "Variable")
})

test_that("errors cleanly when the provided file does not exist", {
  skip_on_cran()

  bogus <- fs::path(tempdir(), "nope-does-not-exist.csv")
  if (fs::file_exists(bogus)) {
    fs::file_delete(bogus)
  }

  expect_error(
    read_estimates_by_size(x = bogus),
    regexp = "does not exist|cannot open|Open failed",
    ignore.case = TRUE
  )
})

test_that("column order is enforced even if input CSV columns are shuffled", {
  skip_on_cran()

  tmp_csv <- withr::local_tempfile(fileext = ".csv")
  DT_in <- data.table::data.table(
    RSE = c(1.0, 2.0),
    Industry = c("Beef", "Dairy"),
    Size = c("Small", "Large"),
    Variable = c("Costs", "Revenue"),
    Value = c(100.5, 200.75),
    Year = c(2020L, 2021L)
  )
  # Save with this shuffled order
  data.table::fwrite(DT_in, tmp_csv)

  out <- read_estimates_by_size(x = tmp_csv)

  expect_s3_class(out, "data.table")
  expect_named(
    out,
    c("Variable", "Year", "Size", "Industry", "Value", "RSE")
  )
  expect_true(data.table::haskey(out))
  expect_identical(data.table::key(out), "Variable")

  # Same data ignoring row order and now ordered columns
  expect_true(data.table::fsetequal(
    out,
    DT_in[, .(Variable, Year, Size, Industry, Value, RSE)]
  ))
})
