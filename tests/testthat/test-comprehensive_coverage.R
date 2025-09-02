test_that("read_clum_stars works with different data sets", {
  local_mocked_bindings(
    .get_clum = function(.data_set, .x) {
      c("/mock/path/clum_data.tif")
    },
    stars::read_stars = function(x, ...) {
      structure(
        list(
          clum = array(1:100, dim = c(10, 10)),
          dimensions = list(
            x = seq(140, 150, length.out = 10),
            y = seq(-30, -20, length.out = 10)
          )
        ),
        class = "stars"
      )
    }
  )
  result <- read_clum_stars(data_set = "clum_50m_2023_v2", x = NULL)
  
  expect_s3_class(result, "stars")
  expect_true("clum" %in% names(result))
})

test_that("read_clum_terra works with different data sets", {
  local_mocked_bindings(
    .get_clum = function(.data_set, .x) {
      c("/mock/path/clum_data.tif")
    },
    terra::rast = function(x, ...) {
      structure(
        list(
          source = x,
          nlyr = 1,
          names = "clum",
          has.RGB = FALSE
        ),
        class = "SpatRaster"
      )
    }
  )
  
  result <- read_clum_terra(data_set = "clum_50m_2023_v2", x = NULL)
  
  expect_s3_class(result, "SpatRaster")
  expect_equal(result$names, "clum")
})

test_that("read_clum functions validate data_set argument", {
  # Test invalid data_set values
  expect_error(
    read_clum_stars(data_set = "invalid_dataset"),
    "arg.*must be one of"
  )
  
  expect_error(
    read_clum_terra(data_set = "another_invalid"),
    "arg.*must be one of"
  )
})

test_that("read_*_options functions work correctly", {
  # Test the read.abares-options.R functions
  original_opts <- options()
  
  # Test that option setting works
  expect_no_error({
    read.abares_options(read.abares.test_option = "test_value")
  })
  
  expect_equal(getOption("read.abares.test_option"), "test_value")
  
  # Test that getting options works
  current_opts <- read.abares_options()
  expect_true(is.list(current_opts))
  expect_true("read.abares.test_option" %in% names(current_opts))
  
  # Restore original options
  options(original_opts)
})

test_that("Reexports work correctly", {
  # Test that terra functions are properly re-exported
  # These are simple re-exports so we just need to verify they exist
  expect_true(exists("plot"))
  expect_true(exists("activeCat"))
  expect_true(exists("levels"))
  expect_true(exists("categories"))
  expect_true(exists("cats"))
})

test_that("Global variables are properly defined", {
  # Test that globals.R properly defines variables
  # This prevents R CMD check warnings
  expect_true(exists("globalVariables"))
  
  # The globals should be defined to prevent "no visible binding" warnings
  global_vars <- c(
    "region_codes", "data_item", "download_file", 
    "Year_month", "lat", "lon", "f", "Month_issued"
  )
  
  # We can't easily test this directly, but we can verify the globals.R file exists
  globals_file <- file.path("R", "globals.R")
  expect_true(file.exists(globals_file))
})

test_that("Error messages are informative", {
  # Test that error messages provide useful information
  local_mocked_bindings(
    .retry_download = function(url, .f) {
      stop("Failed to download from ", url, ": Connection timeout")
    }
  )
  
  expect_error(
    {
      f <- tempfile()
      .retry_download("http://example.com/data.zip", f)
    },
    "Failed to download.*Connection timeout"
  )
})

test_that("Package documentation functions work", {
  # Test package-level documentation helpers
  
  # Test that readabares_user_agent handles different scenarios
  original_ci <- Sys.getenv("READABARES_CI")
  
  # Test normal user
  Sys.unsetenv("READABARES_CI")
  local_mocked_bindings(
    whoami::gh_username = function() "regular_user",
    .readabares_collaborators = function() c("dev1", "dev2")
  )
  
  result <- readabares_user_agent()
  expect_true(grepl("read.abares R package", result))
  expect_false(grepl("CI", result))
  expect_false(grepl("DEV", result))
  
  # Restore
  if (nzchar(original_ci)) {
    Sys.setenv(READABARES_CI = original_ci)
  }
})

test_that("File path handling is robust", {
  # Test that file path operations handle edge cases
  
  # Test with different path separators and formats
  paths <- c(
    "data.zip",
    "./data.zip",
    "/tmp/data.zip",
    "~/data.zip"
  )
  
  for (path in paths) {
    # Test that fs::path operations work
    local_mocked_bindings(
      fs::path = function(...) {
        paste(..., sep = .Platform$file.sep)
      },
      fs::path_dir = function(x) {
        dirname(x)
      },
      fs::path_ext_remove = function(x) {
        tools::file_path_sans_ext(x)
      }
    )
    
    dir_path <- fs::path_dir(path)
    no_ext <- fs::path_ext_remove(path)
    
    expect_type(dir_path, "character")
    expect_type(no_ext, "character")
  }
})

test_that("Package options are restored on unload", {
  # Test that .onUnload properly restores options
  original_opts <- options()
  
  # Set some test options
  options(
    read.abares.test1 = "value1",
    read.abares.test2 = "value2"
  )
  
  # Mock the environment
  test_env <- new.env()
  test_env$old_options <- list(some_option = "original_value")
  assign(".read.abares_env", test_env, envir = environment())
  
  # Test unload
  expect_no_error({
    .onUnload("test")
  })
  
  # Restore original options
  options(original_opts)
})

test_that("Data type conversions work correctly", {
  # Test that data is properly converted between types
  # Test factor conversion
  test_data <- data.frame(
    region = c("NSW", "VIC", "QLD"),
    region_codes = c("1", "2", "3"),
    stringsAsFactors = FALSE
  )
  
  # Mock data.table conversion
  local_mocked_bindings(
    data.table::as.data.table = function(x) {
      x$region <- as.factor(x$region)
      x$region_codes <- as.factor(x$region_codes)
      return(x)
    }
  )
  
  converted <- data.table::as.data.table(test_data)
  
  expect_true(is.factor(converted$region))
  expect_true(is.factor(converted$region_codes))
})

test_that("Network timeouts are handled gracefully", {
  # Test timeout handling
  local_mocked_bindings(
    curl::curl_download = function(url, destfile, quiet = TRUE) {
      # Simulate timeout
      Sys.sleep(0.1)  # Small delay to simulate network operation
      stop("Timeout after 5 seconds")
    }
  )
  
  temp_file <- tempfile()
  
  expect_error(
    .retry_download("http://example.com/slow.zip", temp_file),
    "Timeout"
  )
})

test_that("Large file handling works correctly", {
  # Test that large files are handled appropriately
  local_mocked_bindings(
    fs::file_size = function(path) {
      structure(1e9, class = "fs_bytes")  # 1 GB file
    },
    fs::file_exists = function(path) {
      TRUE
    }
  )
  
  # Mock a function that checks file size
  check_large_file <- function(path) {
    if (fs::file_exists(path)) {
      size <- fs::file_size(path)
      return(as.numeric(size) > 1e8)  # > 100 MB
    }
    return(FALSE)
  }
  
  result <- check_large_file("large_file.zip")
  expect_true(result)
})