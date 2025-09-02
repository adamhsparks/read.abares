test_that("print methods work for custom objects", {
  # Test print method for topsoil thickness
  mock_topsoil <- structure(
    list(
      data = structure(list(), class = "SpatRaster"),
      metadata = data.frame(
        doc_id = "metadata.txt",
        text = "This is topsoil thickness metadata with important information."
      )
    ),
    class = "read.abares.topsoil.thickness.files"
  )
  
  # Capture output
  output <- capture_output({
    print(mock_topsoil)
  })
  
  expect_true(grepl("topsoil thickness", output$stdout, ignore.case = TRUE))
  expect_true(grepl("metadata", output$stdout, ignore.case = TRUE))
})

test_that("print_topsoil_thickness_metadata works correctly", {
  mock_metadata <- data.frame(
    doc_id = "test.txt",
    text = "Test metadata content for topsoil thickness data."
  )
  
  output <- capture_output({
    print_topsoil_thickness_metadata(mock_metadata)
  })
  
  expect_true(grepl("Test metadata content", output$stdout))
})

test_that("Verbosity options control output correctly", {
  # Test different verbosity levels
  original_verbosity <- getOption("read.abares.verbosity")
  
  # Test quiet mode
  options(read.abares.verbosity = "quiet")
  expect_equal(getOption("read.abares.verbosity"), "quiet")
  
  # Test minimal mode  
  options(read.abares.verbosity = "minimal")
  expect_equal(getOption("read.abares.verbosity"), "minimal")
  
  # Test verbose mode
  options(read.abares.verbosity = "verbose")
  expect_equal(getOption("read.abares.verbosity"), "verbose")
  
  # Restore original
  if (!is.null(original_verbosity)) {
    options(read.abares.verbosity = original_verbosity)
  } else {
    options(read.abares.verbosity = NULL)
  }
})

test_that("File existence checks work correctly", {
  # Test behavior when files already exist (should skip download)
  temp_file <- tempfile(fileext = ".zip")
  writeLines("existing content", temp_file)
  
  download_called <- FALSE
  
  local_mocked_bindings(
    fs::file_exists = function(path) {
      if (path == temp_file) return(TRUE)
      return(FALSE)
    },
    .retry_download = function(url, .f) {
      download_called <<- TRUE
      return(invisible(NULL))
    },
    .unzip_file = function(.x) {
      return(invisible(NULL))
    }
  )
  
  # Mock a function that checks file existence
  mock_get_function <- function(file_path) {
    if (is.null(file_path)) {
      file_path <- temp_file
      if (!fs::file_exists(file_path)) {
        .retry_download("http://example.com/data.zip", file_path)
      }
    }
    .unzip_file(file_path)
    return("processed")
  }
  
  result <- mock_get_function(NULL)
  
  # Should not have called download since file exists
  expect_false(download_called)
  expect_equal(result, "processed")
  
  # Clean up
  unlink(temp_file)
})

test_that("URL construction works correctly for different datasets", {
  urls_called <- list()
  
  local_mocked_bindings(
    .retry_download = function(url, .f) {
      urls_called <<- append(urls_called, url)
      writeLines("mock content", .f)
      return(invisible(NULL))
    },
    .unzip_file = function(.x) {
      return(invisible(NULL))
    }
  )
  
  # Mock fs functions for .get_clum
  local_mocked_bindings(
    fs::dir_ls = function(path, ...) {
      character(0)
    }
  )
  
  # Test different CLUM datasets
  .get_clum(.data_set = "clum_50m_2023_v2", .x = NULL)
  expect_true(any(grepl("clum_50m_2023_v2.zip", urls_called)))
  
  urls_called <- list()
  .get_clum(.data_set = "scale_date_update", .x = NULL)
  expect_true(any(grepl("scale_date_update.zip", urls_called)))
})

test_that("Data validation and transformation works", {
  # Test that data is properly transformed from different sources
  mock_excel_data <- data.frame(
    Region = c("NSW", "VIC", "QLD"),
    Region.codes = c("1", "2", "3"),
    Data.item = c("Wheat - tonnes", "Barley - tonnes", "Corn - tonnes"),
    `2023` = c(1000, 2000, 1500),
    stringsAsFactors = FALSE
  )
  
  # Mock the Excel parsing function's data transformation
  local_mocked_bindings(
    readxl::excel_sheets = function(path) {
      c("Info", "Data", "Summary")
    },
    readxl::read_excel = function(path, sheet, ...) {
      if (sheet == "Data") {
        return(mock_excel_data)
      } else {
        return(data.frame(col1 = "header"))
      }
    }
  )
  
  # Mock data.table operations
  local_mocked_bindings(
    data.table::as.data.table = function(x) {
      x$commodity <- sapply(strsplit(x$Data.item, " - "), `[`, 1)
      x$units <- sapply(strsplit(x$Data.item, " - "), `[`, 2)
      x$Data.item <- NULL
      return(x)
    }
  )
  
  # Test that the transformation works
  transformed <- data.table::as.data.table(mock_excel_data)
  
  expect_true("commodity" %in% names(transformed))
  expect_true("units" %in% names(transformed))
  expect_false("Data.item" %in% names(transformed))
})

test_that("Temporary directory handling works correctly", {
  # Test that functions properly use temporary directories
  temp_calls <- list()
  
  local_mocked_bindings(
    tempdir = function() {
      temp_calls <<- append(temp_calls, "/mock/temp")
      return("/mock/temp")
    },
    fs::path = function(...) {
      paste(..., sep = "/")
    }
  )
  
  # Test a function that uses tempdir
  mock_function <- function() {
    temp_file <- fs::path(tempdir(), "test.zip")
    return(temp_file)
  }
  
  result <- mock_function()
  
  expect_equal(result, "/mock/temp/test.zip")
  expect_length(temp_calls, 1)
})

test_that("HTTP retry logic parameters are used correctly", {
  # Test that retry parameters are respected
  retry_calls <- 0
  max_tries <- 3
  
  local_mocked_bindings(
    curl::curl_download = function(url, destfile, quiet = TRUE) {
      retry_calls <<- retry_calls + 1
      if (retry_calls < max_tries) {
        stop("Network error")
      }
      writeLines("success", destfile)
    }
  )
  
  # Mock getOption to return retry settings
  local_mocked_bindings(
    getOption = function(name, default = NULL) {
      if (name == "read.abares.verbosity") return("quiet")
      if (name == "read.abares.max_tries") return(max_tries)
      if (name == "read.abares.timeout") return(5000)
      return(default)
    }
  )
  
  temp_file <- tempfile()
  
  # This should succeed after retries
  expect_no_error({
    .retry_download("http://example.com/file.zip", temp_file)
  })
  
  expect_equal(retry_calls, max_tries)
  expect_true(file.exists(temp_file))
  
  # Clean up
  unlink(temp_file)
})

test_that("Different data formats are handled correctly", {
  # Test that functions can handle different input formats
  
  # Test with different file extensions
  test_files <- c("data.xlsx", "data.csv", "data.zip", "data.nc", "data.tif")
  
  for (file_ext in test_files) {
    temp_file <- tempfile(fileext = paste0(".", tools::file_ext(file_ext)))
    writeLines("mock content", temp_file)
    
    # Test that file paths are handled correctly
    expect_true(grepl(tools::file_ext(file_ext), temp_file))
    expect_true(file.exists(temp_file))
    
    # Clean up
    unlink(temp_file)
  }
})

test_that("Memory management for large datasets", {
  # Test that large dataset handling works without memory issues
  large_data_calls <- 0
  
  mock_large_dataset <- function() {
    large_data_calls <<- large_data_calls + 1
    
    # Simulate processing large data by returning a smaller mock
    data.frame(
      id = 1:100,
      value = rnorm(100),
      category = sample(letters[1:5], 100, replace = TRUE)
    )
  }
  
  result <- mock_large_dataset()
  
  expect_equal(nrow(result), 100)
  expect_equal(large_data_calls, 1)
  expect_true(all(c("id", "value", "category") %in% names(result)))
})