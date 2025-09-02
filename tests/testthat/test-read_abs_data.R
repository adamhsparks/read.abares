test_that("read_abs_horticulture_data downloads and processes latest data", {
  # Mock dependencies
  local_mocked_bindings(
    .find_years = function(data_set) {
      expect_equal(data_set, "horticulture")
      c("2023-24", "2022-23", "2021-22")
    },
    .retry_download = function(url, .f) {
      expect_true(grepl("2023-24", url))
      expect_true(grepl("AAHDC_Aust_Horticulture", url))
      writeLines("mock excel content", .f)
      return(invisible(NULL))
    },
    parse_abs_production_data = function(filename) {
      data.table::data.table(
        region = c("NSW", "VIC", "QLD"),
        region_codes = as.factor(c("1", "2", "3")),
        commidity = c("Apples", "Oranges", "Bananas"),
        units = c("tonnes", "tonnes", "tonnes"),
        `2023` = c(1000, 2000, 1500)
      )
    }
  )
  
  result <- read_abs_horticulture_data(year = "latest", x = NULL)
  
  expect_s3_class(result, "data.table")
  expect_true("region" %in% names(result))
  expect_true("commidity" %in% names(result))
  expect_equal(nrow(result), 3)
})

test_that("read_abs_horticulture_data works with specific year", {
  local_mocked_bindings(
    .find_years = function(data_set) {
      c("2023-24", "2022-23", "2021-22")
    },
    .retry_download = function(url, .f) {
      expect_true(grepl("2022-23", url))
      writeLines("mock excel content", .f)
      return(invisible(NULL))
    },
    parse_abs_production_data = function(filename) {
      data.table::data.table(
        region = "NSW",
        region_codes = as.factor("1"),
        commidity = "Apples",
        units = "tonnes",
        `2022` = 900
      )
    }
  )
  
  result <- read_abs_horticulture_data(year = "2022-23", x = NULL)
  
  expect_s3_class(result, "data.table")
  expect_equal(nrow(result), 1)
})

test_that("read_abs_horticulture_data validates year argument", {
  local_mocked_bindings(
    .find_years = function(data_set) {
      c("2023-24", "2022-23")
    }
  )
  
  expect_error(
    read_abs_horticulture_data(year = "2020-21", x = NULL),
    "arg.*must be one of"
  )
})

test_that("read_abs_horticulture_data works with user-provided file", {
  temp_file <- tempfile(fileext = ".xlsx")
  writeLines("mock file content", temp_file)
  
  local_mocked_bindings(
    parse_abs_production_data = function(filename) {
      expect_equal(filename, temp_file)
      data.table::data.table(
        region = "Custom",
        region_codes = as.factor("99"),
        commidity = "CustomCrop",
        units = "kg",
        `2023` = 500
      )
    }
  )
  
  result <- read_abs_horticulture_data(year = "latest", x = temp_file)
  
  expect_s3_class(result, "data.table")
  expect_equal(result$region, "Custom")
  
  # Clean up
  unlink(temp_file)
})

test_that("read_abs_livestock_data downloads and processes latest data", {
  local_mocked_bindings(
    .find_years = function(data_set) {
      expect_equal(data_set, "livestock")
      c("2023-24", "2022-23", "2021-22")
    },
    .retry_download = function(url, .f) {
      expect_true(grepl("2023-24", url))
      expect_true(grepl("AALDC_Value.*livestock", url))
      writeLines("mock excel content", .f)
      return(invisible(NULL))
    },
    parse_abs_production_data = function(filename) {
      data.table::data.table(
        region = c("NSW", "VIC", "QLD"),
        region_codes = as.factor(c("1", "2", "3")),
        commidity = c("Cattle", "Sheep", "Pigs"),
        units = c("head", "head", "head"),
        `2023` = c(500000, 800000, 200000)
      )
    }
  )
  
  result <- read_abs_livestock_data(year = "latest", x = NULL)
  
  expect_s3_class(result, "data.table")
  expect_true("region" %in% names(result))
  expect_true("commidity" %in% names(result))
  expect_equal(nrow(result), 3)
})

test_that("read_abs_livestock_data works with specific year", {
  local_mocked_bindings(
    .find_years = function(data_set) {
      c("2023-24", "2022-23", "2021-22")
    },
    .retry_download = function(url, .f) {
      expect_true(grepl("2021-22", url))
      writeLines("mock excel content", .f)
      return(invisible(NULL))
    },
    parse_abs_production_data = function(filename) {
      data.table::data.table(
        region = "WA",
        region_codes = as.factor("5"),
        commidity = "Sheep",
        units = "head",
        `2021` = 750000
      )
    }
  )
  
  result <- read_abs_livestock_data(year = "2021-22", x = NULL)
  
  expect_s3_class(result, "data.table")
  expect_equal(result$commidity, "Sheep")
})

test_that("read_abs_livestock_data validates year argument", {
  local_mocked_bindings(
    .find_years = function(data_set) {
      c("2023-24", "2022-23")
    }
  )
  
  expect_error(
    read_abs_livestock_data(year = "2019-20", x = NULL),
    "arg.*must be one of"
  )
})

test_that("read_abs_livestock_data works with user-provided file", {
  temp_file <- tempfile(fileext = ".xlsx")
  writeLines("mock file content", temp_file)
  
  local_mocked_bindings(
    parse_abs_production_data = function(filename) {
      expect_equal(filename, temp_file)
      data.table::data.table(
        region = "Custom",
        region_codes = as.factor("99"),
        commidity = "CustomLivestock",
        units = "head",
        `2023` = 1000
      )
    }
  )
  
  result <- read_abs_livestock_data(year = "latest", x = temp_file)
  
  expect_s3_class(result, "data.table")
  expect_equal(result$commidity, "CustomLivestock")
  
  # Clean up
  unlink(temp_file)
})