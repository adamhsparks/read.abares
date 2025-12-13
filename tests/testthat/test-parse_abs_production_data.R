test_that("parse_abs_production_data parses workbook correctly", {
  # Create temporary Excel file
  tmpfile <- fs::file_temp(ext = ".xlsx")

  # Fake sheet 1 (empty, should be dropped)
  sheet1 <- data.frame(a = character(), b = character())

  # Fake sheet 2 (valid horticulture data)
  sheet2 <- data.frame(
    V1 = c("Region codes", "0", "1"),
    V2 = c("Region", "NSW", "VIC"),
    V3 = c("Data item", "Wheat - tonnes", "Barley - tonnes"),
    stringsAsFactors = FALSE
  )

  # Fake sheet 3 (empty, should be dropped)
  sheet3 <- data.frame(a = character(), b = character())

  # Write workbook
  writexl::write_xlsx(
    list(
      Empty1 = sheet1,
      Horticulture = sheet2,
      Empty2 = sheet3
    ),
    tmpfile
  )

  # Run function
  result <- parse_abs_production_data(tmpfile)

  # Check class
  expect_s3_class(result, "data.table")

  # Check column names
  expect_true(all(
    c("region", "region_code", "commodity", "units") %in% names(result)
  ))

  # Check factor conversion
  expect_type(result$region, "integer")
  expect_type(result$region_code, "integer")

  # Check commodity split
  expect_identical(result$commodity, c("Wheat", "Barley"))
  expect_identical(result$units, c("tonnes", "tonnes"))

  # Check numeric conversion only applies to data columns, not units
  numeric_cols <- setdiff(
    names(result),
    c("region", "region_code", "commodity", "units")
  )
  expect_true(all(sapply(result[, ..numeric_cols], is.numeric)))
})


test_that("parse_abs_production_data parses non-horticulture workbook correctly", {
  tmpfile <- fs::file_temp(ext = ".xlsx")

  sheet1 <- data.frame(a = character(), b = character())
  sheet2 <- data.frame(
    V1 = c("Region", "NSW", "VIC"),
    V2 = c("Region codes", "0", "1"),
    V3 = c("Data item", "Wheat - tonnes", "Barley - tonnes"),
    stringsAsFactors = FALSE
  )
  sheet3 <- data.frame(a = character(), b = character())

  writexl::write_xlsx(
    list(Empty1 = sheet1, Crops = sheet2, Empty2 = sheet3),
    tmpfile
  )

  result <- parse_abs_production_data(tmpfile)

  expect_s3_class(result, "data.table")
  expect_true(all(
    c("region", "region_code", "commodity", "units") %in% names(result)
  ))
  expect_identical(result$commodity, c("Wheat", "Barley"))
  expect_identical(result$units, c("tonnes", "tonnes"))
  expect_type(result$region, "integer")
  expect_type(result$region_code, "integer")
})


test_that("parse_abs_production_data parses horticulture workbook with numeric year columns", {
  tmpfile <- fs::file_temp(ext = ".xlsx")

  # First sheet (empty, will be dropped)
  sheet1 <- data.frame(a = character(), b = character())

  # Middle sheet: header row includes year labels
  sheet2 <- data.frame(
    V1 = c("Region codes", "0", "1", "Horticulture"),
    V2 = c("Region", "NSW", "VIC", ""),
    V3 = c("Data item", "Apples - tonnes", "Oranges - tonnes", ""),
    `2023-24` = c("2023-24", "100", "200", ""),
    `2024-25` = c("2024-25", "150", "250", ""),
    stringsAsFactors = FALSE
  )

  # Last sheet (empty, will be dropped)
  sheet3 <- data.frame(a = character(), b = character())

  writexl::write_xlsx(
    list(Empty1 = sheet1, HortSheet = sheet2, Empty2 = sheet3),
    tmpfile
  )

  result <- parse_abs_production_data(tmpfile)

  # Structure checks
  expect_s3_class(result, "data.table")
  expect_true(all(
    c("region", "region_code", "commodity", "units") %in% names(result)
  ))

  # Horticulture-specific renaming
  expect_identical(result$region, factor(c("NSW", "VIC")))
  expect_identical(result$region_code, factor(c("0", "1")))

  # Commodity split
  expect_identical(result$commodity, c("Apples", "Oranges"))
  expect_identical(result$units, c("tonnes", "tonnes"))

  # Numeric conversion check
  expect_type(result$`2023-24`, "double")
  expect_type(result$`2024-25`, "double")
  expect_identical(result$`2023-24`, c(100, 200))
  expect_identical(result$`2024-25`, c(150, 250))
})


test_that(".find_years extracts financial years correctly", {
  fake_text <- "Available data sets include 2021-22, 2022-23, and 2023-24."

  with_mocked_bindings(
    {
      years <- .find_years("broadacre")
      expect_identical(years, c("2021-22", "2022-23", "2023-24"))
    },
    .package = "htm2txt",
    gettxt = function(url) fake_text
  )
})

test_that(".find_years works for horticulture dataset", {
  fake_text <- "ABS horticulture data available for 2019-20 and 2020-21."

  with_mocked_bindings(
    {
      years <- .find_years("horticulture")
      expect_identical(years, c("2019-20", "2020-21"))
    },
    .package = "htm2txt",
    gettxt = function(url) fake_text
  )
})

test_that(".find_years works for livestock dataset", {
  fake_text <- "Livestock reports: 2018-19, 2019-20, 2020-21, 2021-22."

  with_mocked_bindings(
    {
      years <- .find_years("livestock")
      expect_identical(years, c("2018-19", "2019-20", "2020-21", "2021-22"))
    },
    .package = "htm2txt",
    gettxt = function(url) fake_text
  )
})
