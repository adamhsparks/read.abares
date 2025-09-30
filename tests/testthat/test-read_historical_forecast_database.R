test_that("reads from a provided local Excel path, renames columns, and maps Month_issued to integers", {
  skip_on_cran()
  skip_if_not_installed("readxl")
  skip_if_not_installed("writexl")

  # Build a minimal workbook with the required original column names
  df <- data.frame(
    Year_Issued = 2020L,
    Month_Issued = "March",
    Year_Issued_FY = 2020L,
    Forecast_Year_FY = 2021L,
    Forecast_Value = 10.5,
    Actual_Value = "na", # will become NA via readxl(na = "na")
    Commodity = "Wheat",
    Estimate_Type = "Production",
    Estimate_description = "Production (kt)",
    Unit = "kt",
    Region = "Australia",
    stringsAsFactors = FALSE
  )

  # Write a real .xlsx to a temp path with sheet "Database"
  xlsx <- withr::local_tempfile(fileext = ".xlsx")
  writexl::write_xlsx(list(Database = df), path = xlsx)
  expect_true(fs::file_exists(xlsx))

  # Run the function
  out <- read_historical_forecast_database(x = xlsx)

  # Must be a data.table with one row
  expect_s3_class(out, "data.table")
  expect_identical(nrow(out), 1L)

  # Exact column names after renaming
  expect_named(
    out,
    c(
      "Year_issued",
      "Month_issued",
      "Year_issued_FY",
      "Forecast_year_FY",
      "Forecast_value",
      "Actual_value",
      "Commodity",
      "Estimate_type",
      "Estimate_description",
      "Unit",
      "Region"
    )
  )

  # Month mapping: "March" -> 3L
  expect_type(out$Month_issued, "integer")
  expect_identical(out$Month_issued, 3L)

  # "na" -> NA_real_ through readxl and conversion
  expect_true(is.na(out$Actual_value))

  # A few field sanity checks
  expect_identical(out$Commodity, "Wheat")
  expect_identical(out$Estimate_type, "Production")
  expect_identical(out$Unit, "kt")
  expect_identical(out$Region, "Australia")
})

test_that("when x is NULL it downloads (mocked) to tempdir and reads the workbook", {
  skip_on_cran()
  skip_if_not_installed("readxl")
  skip_if_not_installed("writexl")

  # Prepare a workbook with different values to confirm this path is exercised
  df <- data.frame(
    Year_Issued = 2019L,
    Month_Issued = "October",
    Year_Issued_FY = 2020L,
    Forecast_Year_FY = 2020L,
    Forecast_Value = 99.9,
    Actual_Value = 101.1,
    Commodity = "AUD",
    Estimate_Type = "Price",
    Estimate_description = "AUD/USD",
    Unit = "$",
    Region = "World",
    stringsAsFactors = FALSE
  )

  staged <- withr::local_tempfile(fileext = ".xlsx")
  writexl::write_xlsx(list(Database = df), path = staged)
  expect_true(fs::file_exists(staged))

  target <- fs::path(tempdir(), "historical_db.xlsx")
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

  expected_url <- "https://daff.ent.sirsidynix.net.au/client/en_AU/search/asset/1031941/0"

  testthat::with_mocked_bindings(
    {
      out <- read_historical_forecast_database(x = NULL)

      # Correct URL used and target created
      expect_identical(last_url, expected_url)
      expect_true(fs::file_exists(target))

      # Output checks
      expect_true(data.table::is.data.table(out))
      expect_identical(out$Month_issued, 10L) # October -> 10
      expect_identical(out$Commodity, "AUD")
      expect_identical(out$Estimate_type, "Price")
    },
    .retry_download = retry_mock
  )
})

test_that("alias read_historical_forecast returns identical results", {
  skip_on_cran()
  skip_if_not_installed("readxl")
  skip_if_not_installed("writexl")

  df <- data.frame(
    Year_Issued = 2022L,
    Month_Issued = "January",
    Year_Issued_FY = 2022L,
    Forecast_Year_FY = 2023L,
    Forecast_Value = 1.23,
    Actual_Value = 2.34,
    Commodity = "Barley",
    Estimate_Type = "Production",
    Estimate_description = "Production (kt)",
    Unit = "kt",
    Region = "Australia",
    stringsAsFactors = FALSE
  )

  xlsx <- withr::local_tempfile(fileext = ".xlsx")
  writexl::write_xlsx(list(Database = df), path = xlsx)

  a <- read_historical_forecast_database(x = xlsx)
  b <- read_historical_forecast(x = xlsx)

  expect_true(data.table::is.data.table(a))
  expect_true(data.table::is.data.table(b))
  expect_true(data.table::fsetequal(a, b))
  expect_identical(a$Month_issued, 1L) # January -> 1
})

test_that("maps all months correctly to 1..12", {
  skip_on_cran()
  skip_if_not_installed("readxl")
  skip_if_not_installed("writexl")

  months <- c(
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  )

  df <- data.frame(
    Year_Issued = rep(2021L, length(months)),
    Month_Issued = months,
    Year_Issued_FY = rep(2021L, length(months)),
    Forecast_Year_FY = rep(2022L, length(months)),
    Forecast_Value = seq_along(months),
    Actual_Value = seq_along(months),
    Commodity = "Wheat",
    Estimate_Type = "Production",
    Estimate_description = "Prod",
    Unit = "kt",
    Region = "Australia",
    stringsAsFactors = FALSE
  )

  xlsx <- withr::local_tempfile(fileext = ".xlsx")
  writexl::write_xlsx(list(Database = df), path = xlsx)

  out <- read_historical_forecast_database(x = xlsx)

  expect_true(data.table::is.data.table(out))
  expect_true(is.integer(out$Month_issued))
  expect_identical(out$Month_issued, as.integer(1:12))
})

test_that("errors cleanly when the provided file does not exist (no mocking)", {
  skip_on_cran()
  skip_if_not_installed("readxl")

  bogus <- fs::path(tempdir(), "no-such-historical_db.xlsx")
  if (fs::file_exists(bogus)) {
    fs::file_delete(bogus)
  }

  expect_error(
    read_historical_forecast_database(x = bogus),
    regexp = "cannot open|does not exist|Failed to open|cannot find",
    ignore.case = TRUE
  )
})

test_that("when x is NULL it downloads (mocked) to tempdir and reads the workbook", {
  skip_on_cran()
  skip_if_not_installed("readxl")
  skip_if_not_installed("writexl")

  # Prepare a workbook with different values to confirm this path is exercised
  df <- data.frame(
    Year_Issued = 2019L,
    Month_Issued = "October",
    Year_Issued_FY = 2020L,
    Forecast_Year_FY = 2020L,
    Forecast_Value = 99.9,
    Actual_Value = 101.1,
    Commodity = "AUD",
    Estimate_Type = "Price",
    Estimate_description = "AUD/USD",
    Unit = "$",
    Region = "World",
    stringsAsFactors = FALSE
  )

  staged <- withr::local_tempfile(fileext = ".xlsx")
  writexl::write_xlsx(list(Database = df), path = staged)
  expect_true(fs::file_exists(staged))

  target <- fs::path(tempdir(), "historical_db.xlsx")
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

  expected_url <- "https://daff.ent.sirsidynix.net.au/client/en_AU/search/asset/1031941/0"

  testthat::with_mocked_bindings(
    {
      out <- read_historical_forecast_database(x = NULL)

      # Correct URL used and target created
      expect_identical(last_url, expected_url)
      expect_true(fs::file_exists(target))

      # Output checks
      expect_true(data.table::is.data.table(out))
      expect_identical(out$Month_issued, 10L) # October -> 10
      expect_identical(out$Commodity, "AUD")
      expect_identical(out$Estimate_type, "Price")
    },
    .retry_download = retry_mock
  )
})

test_that("maps all months correctly to 1..12", {
  skip_on_cran()
  skip_if_not_installed("readxl")
  skip_if_not_installed("writexl")

  months <- c(
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
  )

  # Build a workbook with the original column names the function expects
  df <- data.frame(
    Year_Issued = rep(2021L, length(months)),
    Month_Issued = months,
    Year_Issued_FY = rep(2021L, length(months)),
    Forecast_Year_FY = rep(2022L, length(months)),
    Forecast_Value = seq_along(months),
    Actual_Value = seq_along(months),
    Commodity = "Wheat",
    Estimate_Type = "Production",
    Estimate_description = "Prod",
    Unit = "kt",
    Region = "Australia",
    stringsAsFactors = FALSE
  )

  # Write a real .xlsx with sheet "Database"
  xlsx <- withr::local_tempfile(fileext = ".xlsx")
  writexl::write_xlsx(list(Database = df), path = xlsx)
  expect_true(fs::file_exists(xlsx))

  # Exercise the read function (no mocking of readxl)
  out <- read_historical_forecast_database(x = xlsx)

  # Assertions
  expect_s3_class(out, "data.table")
  expect_type(out$Month_issued, "integer")
  expect_identical(out$Month_issued, as.integer(1:12))

  # Optional extra checks for completeness
  expect_identical(
    names(out),
    c(
      "Year_issued",
      "Month_issued",
      "Year_issued_FY",
      "Forecast_year_FY",
      "Forecast_value",
      "Actual_value",
      "Commodity",
      "Estimate_type",
      "Estimate_description",
      "Unit",
      "Region"
    )
  )
  expect_equal(nrow(out), 12L)
})


test_that("errors cleanly when the provided file does not exist (no mocking)", {
  skip_on_cran()
  skip_if_not_installed("readxl")

  bogus <- fs::path(tempdir(), "no-such-historical_db.xlsx")
  if (fs::file_exists(bogus)) {
    fs::file_delete(bogus)
  }

  # readxl::read_excel will error; we assert a reasonable message pattern
  expect_error(
    read_historical_forecast_database(x = bogus),
    regexp = "cannot open|does not exist|Failed to open|cannot find",
    ignore.case = TRUE
  )
})
