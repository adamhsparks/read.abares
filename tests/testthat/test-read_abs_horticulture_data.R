test_that("read_abs_horticulture_data reads horticulture data for a specific year", {
  # Mock the behavior of .find_years and .retry_download
  testthat::with_mocked_bindings(
    .find_years = function(data_set) c("2021-22", "2022-23", "2023-24"),
    .retry_download = function(url, dest) {
      # Mimic the downloaded file by creating a temporary file
      tmpfile <- fs::file_temp(ext = ".xlsx")
      sheet1 <- data.frame(a = character(), b = character())
      sheet2 <- data.frame(
        V1 = c("Region", "NSW", "VIC"),
        V2 = c("Region codes", "0", "1"),
        V3 = c("Data item", "Wheat - tonnes", "Barley - tonnes"),
        stringsAsFactors = FALSE
      )
      sheet3 <- data.frame(a = character(), b = character())

      openxlsx::write.xlsx(
        list(Empty1 = sheet1, Crops = sheet2, Empty2 = sheet3),
        tmpfile,
        rowNames = FALSE
      )
      fs::file_copy(tmpfile, dest, overwrite = TRUE)
    },
    {
      result <- read_abs_horticulture_data("2023-24")
      testthat::expect_s3_class(result, "data.table")
    }
  )
})

test_that("read_abs_horticulture_data reads the latest horticulture data", {
  # Mock the behavior of .find_years and .retry_download
  testthat::with_mocked_bindings(
    .find_years = function(data_set) c("2021-22", "2022-23", "2023-24"),
    .retry_download = function(url, dest) {
      # Mimic the downloaded file by creating a temporary file
      tmpfile <- fs::file_temp(ext = ".xlsx")
      sheet1 <- data.frame(a = character(), b = character())
      sheet2 <- data.frame(
        V1 = c("Region", "NSW", "VIC"),
        V2 = c("Region codes", "0", "1"),
        V3 = c("Data item", "Wheat - tonnes", "Barley - tonnes"),
        stringsAsFactors = FALSE
      )
      sheet3 <- data.frame(a = character(), b = character())

      openxlsx::write.xlsx(
        list(Empty1 = sheet1, Crops = sheet2, Empty2 = sheet3),
        tmpfile,
        rowNames = FALSE
      )
      fs::file_copy(tmpfile, dest, overwrite = TRUE)
    },
    {
      result <- read_abs_horticulture_data("latest")
      testthat::expect_s3_class(result, "data.table")
    }
  )
})

test_that("read_abs_horticulture_data handles invalid years", {
  # Mock the behavior of .find_years
  testthat::with_mocked_bindings(
    .find_years = function(data_set) c("2021-22", "2022-23", "2023-24"),
    {
      testthat::expect_error(
        read_abs_horticulture_data("2019-20"),
        "`year` must be one of \"latest\", \"2021-22\", \"2022-23\", or \"2023-24\", not \"2019-20\"\\."
      ) # Note: Must escape backslashes to handle the regex pattern for exact matching
    }
  )
})

test_that("read_abs_horticulture_data reads from provided file", {
  # Create a temporary Excel file
  tmpfile <- fs::file_temp(ext = ".xlsx")
  sheet1 <- data.frame(a = character(), b = character())
  sheet2 <- data.frame(
    V1 = c("Region", "NSW", "VIC"),
    V2 = c("Region codes", "0", "1"),
    V3 = c("Data item", "Wheat - tonnes", "Barley - tonnes"),
    stringsAsFactors = FALSE
  )
  sheet3 <- data.frame(a = character(), b = character())

  openxlsx::write.xlsx(
    list(Empty1 = sheet1, Crops = sheet2, Empty2 = sheet3),
    tmpfile,
    rowNames = FALSE
  )

  # Run the function with the pre-existing file
  result <- read_abs_horticulture_data(x = tmpfile)

  testthat::expect_s3_class(result, "data.table")
})
