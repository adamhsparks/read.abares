test_that("reads from a provided local Excel path and returns a data.table", {
  skip_on_cran()

  # Create a small Excel file with expected headers
  tmp_xlsx <- withr::local_tempfile(fileext = ".xlsx")
  DT_in <- data.table::data.table(
    Commodity = c("Wheat", "Barley"),
    Estimate_Type = c("Production", "Price"),
    Estimate_description = c("Total production", "Average price"),
    Unit = c("kt", "$/t"),
    Region = c("Australia", "World"),
    Year_Issued = c(2020L, 2021L),
    Month_Issued = c("March", "July"),
    Year_Issued_FY = c("2019-20", "2020-21"),
    Forecast_Year_FY = c("2020-21", "2021-22"),
    Forecast_Value = c(25000, 300),
    Actual_Value = c(24500, 310)
  )

  # Write to Excel
  writexl::write_xlsx(list(Database = DT_in), tmp_xlsx)

  # Sanity
  expect_true(fs::file_exists(tmp_xlsx))

  out <- read_historical_forecast_database(x = tmp_xlsx)

  # Type and shape
  expect_s3_class(out, "data.table")
  expect_identical(nrow(out), nrow(DT_in))

  # Column names renamed to snake_case
  expect_setequal(
    names(out),
    c(
      "Commodity",
      "Estimate_type",
      "Estimate_description",
      "Unit",
      "Region",
      "Year_issued",
      "Month_issued",
      "Year_issued_FY",
      "Forecast_year_FY",
      "Forecast_value",
      "Actual_value"
    )
  )

  # Month conversion
  expect_type(out$Month_issued, "integer")
  expect_identical(out$Month_issued, c(3L, 7L))
})

test_that("when x is NULL it downloads (mocked) to tempdir and reads the Excel", {
  skip_on_cran()

  # Stage an Excel file that we will "download"
  staged_xlsx <- withr::local_tempfile(fileext = ".xlsx")
  DT_stage <- data.table::data.table(
    Commodity = c("Canola", "Lamb"),
    Estimate_Type = c("Area", "Export"),
    Estimate_description = c("Area planted", "Export volume"),
    Unit = c("ha", "kt"),
    Region = c("Australia", "World"),
    Year_Issued = c(2022L, 2023L),
    Month_Issued = c("October", "December"),
    Year_Issued_FY = c("2022-23", "2023-24"),
    Forecast_Year_FY = c("2023-24", "2024-25"),
    Forecast_Value = c(100000, 500),
    Actual_Value = c(98000, 520)
  )
  writexl::write_xlsx(list(Database = DT_stage), staged_xlsx)

  # Expected target path used by the function when x = NULL
  target_xlsx <- fs::path(tempdir(), "historical_db.xlsx")
  if (fs::file_exists(target_xlsx)) {
    fs::file_delete(target_xlsx)
  }
  withr::defer({
    if (fs::file_exists(target_xlsx)) fs::file_delete(target_xlsx)
  })

  # Capture URL and ensure the staged file is copied to the expected target
  last_url <- NULL
  retry_mock <- function(url, dest, dataset_id, show_progress = TRUE, ...) {
    last_url <<- url
    fs::file_copy(staged_xlsx, dest, overwrite = TRUE)
    invisible(dest)
  }

  expected_url <- "https://daff.ent.sirsidynix.net.au/client/en_AU/search/asset/1031941/0"

  with_mocked_bindings(
    .retry_download = retry_mock,
    {
      out <- read_historical_forecast_database(x = NULL)

      # The function should have requested the right URL
      expect_identical(last_url, expected_url)

      # Target must now exist
      expect_true(fs::file_exists(target_xlsx))

      # Output must be a data.table with our staged content
      expect_s3_class(out, "data.table")
      expect_named(
        out,
        c(
          "Commodity",
          "Estimate_type",
          "Estimate_description",
          "Unit",
          "Region",
          "Year_issued",
          "Month_issued",
          "Year_issued_FY",
          "Forecast_year_FY",
          "Forecast_value",
          "Actual_value"
        )
      )
      expect_true(data.table::fsetequal(out, out)) # Self-equality for sanity
    }
  )
})

test_that("alias read_historical_forecast returns identical results", {
  skip_on_cran()

  tmp_xlsx <- withr::local_tempfile(fileext = ".xlsx")
  DT_in <- data.table::data.table(
    Commodity = "Sugar",
    Estimate_Type = "Price",
    Estimate_description = "Export price",
    Unit = "$/t",
    Region = "World",
    Year_Issued = 2021L,
    Month_Issued = "June",
    Year_Issued_FY = "2020-21",
    Forecast_Year_FY = "2021-22",
    Forecast_Value = 400L,
    Actual_Value = 390L
  )
  writexl::write_xlsx(list(Database = DT_in), tmp_xlsx)

  a <- read_historical_forecast_database(x = tmp_xlsx)
  b <- read_historical_forecast(x = tmp_xlsx)

  expect_s3_class(a, "data.table")
  expect_s3_class(b, "data.table")
  expect_true(data.table::fsetequal(a, b))
})

test_that("errors cleanly when the provided file does not exist", {
  skip_on_cran()

  bogus <- fs::path(tempdir(), "nope-does-not-exist.xlsx")
  if (fs::file_exists(bogus)) {
    fs::file_delete(bogus)
  }

  expect_error(
    read_historical_forecast_database(x = bogus),
    regexp = "does not exist|cannot open|Open failed",
    ignore.case = TRUE
  )
})
