test_that("parse_abs_production_data processes horticulture data correctly", {
  # Create mock Excel file structure for horticulture
  temp_file <- tempfile(fileext = ".xlsx")
  
  # Mock readxl functions
  local_mocked_bindings(
    readxl::excel_sheets = function(path) {
      c("Sheet1", "Data1", "Data2", "Summary")
    },
    readxl::read_excel = function(path, sheet, ...) {
      if (sheet == "Sheet1") {
        # First sheet with no data
        data.frame(
          col1 = c("Title", "Information"),
          col2 = c("", ""),
          stringsAsFactors = FALSE
        )
      } else if (sheet == "Data1") {
        # Horticulture data sheet
        data.frame(
          col1 = c("Header", "Info", "Region"),
          col2 = c("Region codes", "codes", "Region"),
          col3 = c("Data item", "item", "Data item"),
          stringsAsFactors = FALSE
        ) %>%
          rbind(data.frame(
            col1 = c("NSW", "VIC", "QLD"),
            col2 = c("1", "2", "3"),
            col3 = c("Apples - tonnes", "Oranges - tonnes", "Bananas - tonnes"),
            stringsAsFactors = FALSE
          ))
      } else if (sheet == "Data2") {
        # Another data sheet
        data.frame(
          col1 = c("Header2", "Info2", "Region"),
          col2 = c("Region codes", "codes", "Region"),
          col3 = c("Data item", "item", "Data item"),
          stringsAsFactors = FALSE
        ) %>%
          rbind(data.frame(
            col1 = c("SA", "WA"),
            col2 = c("4", "5"),
            col3 = c("Grapes - tonnes", "Citrus - tonnes"),
            stringsAsFactors = FALSE
          ))
      } else {
        # Summary sheet with no data
        data.frame(
          col1 = c("Summary", "End"),
          col2 = c("", ""),
          stringsAsFactors = FALSE
        )
      }
    }
  )
  
  # Create a flag to identify horticulture data 
  horticulture_flag <- TRUE
  
  result <- parse_abs_production_data(temp_file)
  
  expect_s3_class(result, "data.table")
  expect_true("region" %in% names(result))
  expect_true("region_codes" %in% names(result))
  expect_true("commidity" %in% names(result))
  expect_true("units" %in% names(result))
})

test_that("parse_abs_production_data processes non-horticulture data correctly", {
  temp_file <- tempfile(fileext = ".xlsx")
  
  # Mock readxl functions for non-horticulture data
  local_mocked_bindings(
    readxl::excel_sheets = function(path) {
      c("Sheet1", "Broadacre_Data", "Summary")
    },
    readxl::read_excel = function(path, sheet, ...) {
      if (sheet == "Sheet1") {
        data.frame(
          col1 = c("Title", "Information"),
          col2 = c("", ""),
          stringsAsFactors = FALSE
        )
      } else if (sheet == "Broadacre_Data") {
        data.frame(
          col1 = c("Header", "Info", "Region"),
          col2 = c("Region", "Region", "Region"),
          col3 = c("Region codes", "codes", "Region codes"),
          col4 = c("Data item", "item", "Data item"),
          stringsAsFactors = FALSE
        ) %>%
          rbind(data.frame(
            col1 = c("NSW", "VIC"),
            col2 = c("NSW", "VIC"),
            col3 = c("1", "2"),
            col4 = c("Wheat - tonnes", "Barley - tonnes"),
            stringsAsFactors = FALSE
          ))
      } else {
        data.frame(
          col1 = c("Summary"),
          col2 = c(""),
          stringsAsFactors = FALSE
        )
      }
    }
  )
  
  # Mock that this is NOT horticulture data by adjusting data structure
  horticulture_flag <- FALSE
  
  result <- parse_abs_production_data(temp_file)
  
  expect_s3_class(result, "data.table")
  expect_true("region" %in% names(result))
  expect_true("region_codes" %in% names(result))
})

test_that("parse_abs_production_data handles single table data", {
  temp_file <- tempfile(fileext = ".xlsx")
  
  # Mock for single table (like cane data)
  local_mocked_bindings(
    readxl::excel_sheets = function(path) {
      c("Info", "CaneData", "Summary")
    },
    readxl::read_excel = function(path, sheet, ...) {
      if (sheet == "Info") {
        data.frame(col1 = "Info", stringsAsFactors = FALSE)
      } else if (sheet == "CaneData") {
        data.frame(
          Region = c("Header", "Region"),
          Region.codes = c("codes", "Region codes"),
          Data.item = c("item", "Data item"),
          stringsAsFactors = FALSE
        ) %>%
          rbind(data.frame(
            Region = c("QLD", "NSW"),
            Region.codes = c("3", "1"),
            Data.item = c("Sugar cane - tonnes", "Sugar cane - tonnes"),
            stringsAsFactors = FALSE
          ))
      } else {
        data.frame(col1 = "Summary", stringsAsFactors = FALSE)
      }
    }
  )
  
  horticulture_flag <- FALSE
  
  result <- parse_abs_production_data(temp_file)
  
  expect_s3_class(result, "data.table")
  expect_true(nrow(result) > 0)
})

test_that(".find_years extracts years from web page correctly", {
  # Mock htm2txt::gettxt to return page with years
  local_mocked_bindings(
    htm2txt::gettxt = function(url) {
      "This page contains data for 2021-22, 2022-23, and 2023-24 financial years. 
      Some other text with 2020-21 year and additional 2019-20 data."
    }
  )
  
  result <- .find_years("broadacre")
  
  expect_type(result, "character")
  expect_true(length(result) > 0)
  expect_true(all(grepl("\\d{4}-\\d{2}", result)))
  expect_true("2021-22" %in% result)
  expect_true("2022-23" %in% result)
  expect_true("2023-24" %in% result)
})

test_that(".find_years works with different data sets", {
  # Mock different responses for different URLs
  local_mocked_bindings(
    htm2txt::gettxt = function(url) {
      if (grepl("broadacre", url)) {
        "Broadacre data for 2022-23 and 2023-24"
      } else if (grepl("horticulture", url)) {
        "Horticulture information 2021-22, 2022-23"
      } else if (grepl("livestock", url)) {
        "Livestock data 2020-21, 2021-22, 2022-23"
      } else {
        "No years found"
      }
    }
  )
  
  broadacre_result <- .find_years("broadacre")
  hort_result <- .find_years("horticulture")
  livestock_result <- .find_years("livestock")
  
  expect_true("2022-23" %in% broadacre_result)
  expect_true("2023-24" %in% broadacre_result)
  
  expect_true("2021-22" %in% hort_result)
  expect_true("2022-23" %in% hort_result)
  
  expect_true("2020-21" %in% livestock_result)
  expect_true("2021-22" %in% livestock_result)
  expect_true("2022-23" %in% livestock_result)
})

test_that(".find_years handles page with no years", {
  local_mocked_bindings(
    htm2txt::gettxt = function(url) {
      "This page has no valid financial year data."
    }
  )
  
  result <- .find_years("broadacre")
  
  expect_type(result, "character")
  expect_length(result, 0)
})