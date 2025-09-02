test_that(".get_agfd works with fixed prices and local file", {
  # Mock dependencies
  local_mocked_bindings(
    .retry_download = function(url, .f) {
      # Create a mock zip file
      writeLines("mock zip content", .f)
      return(invisible(NULL))
    },
    .unzip_file = function(.x) {
      # Create mock directory structure
      mock_dir <- fs::path_ext_remove(.x)
      fs::dir_create(mock_dir)
      # Create mock NetCDF files
      mock_files <- c(
        fs::path(mock_dir, "c2020_data.nc"),
        fs::path(mock_dir, "c2021_data.nc")
      )
      for (f in mock_files) {
        writeLines("mock nc content", f)
      }
      return(invisible(NULL))
    }
  )
  
  # Mock fs::dir_ls to return mock files
  mockery::stub(.get_agfd, "fs::dir_ls", function(path, ...) {
    mock_dir <- fs::path(fs::path_dir(tempfile()), "historical_climate_prices_fixed")
    c(
      fs::path(mock_dir, "c2020_data.nc"),
      fs::path(mock_dir, "c2021_data.nc")
    )
  })
  
  # Test with fixed prices and specific years
  result <- .get_agfd(.fixed_prices = TRUE, .yyyy = 2020:2021, .x = NULL)
  
  expect_type(result, "character")
  expect_length(result, 2)
  expect_true(all(grepl("c202[01]", result)))
})

test_that(".get_agfd works with user-specified local file", {
  temp_dir <- tempdir()
  user_zip <- fs::path(temp_dir, "user_data.zip")
  
  # Mock dependencies  
  local_mocked_bindings(
    .unzip_file = function(.x) {
      # Create mock directory structure
      mock_dir <- fs::path_ext_remove(.x)
      fs::dir_create(mock_dir)
      # Create mock NetCDF files
      mock_files <- c(
        fs::path(mock_dir, "c2019_data.nc"),
        fs::path(mock_dir, "c2020_data.nc")
      )
      for (f in mock_files) {
        writeLines("mock nc content", f)
      }
      return(invisible(NULL))
    }
  )
  
  # Mock fs::dir_ls
  mockery::stub(.get_agfd, "fs::dir_ls", function(path, ...) {
    mock_dir <- fs::path(fs::path_dir(user_zip), "user_data")
    c(
      fs::path(mock_dir, "c2019_data.nc"),
      fs::path(mock_dir, "c2020_data.nc")
    )
  })
  
  # Create mock zip file
  writeLines("mock content", user_zip)
  
  result <- .get_agfd(.fixed_prices = FALSE, .yyyy = 2019:2020, .x = user_zip)
  
  expect_type(result, "character")
  expect_length(result, 2)
  
  # Clean up
  fs::file_delete(user_zip)
})

test_that(".get_agfd filters years correctly", {
  # Mock dependencies
  local_mocked_bindings(
    .retry_download = function(url, .f) {
      writeLines("mock content", .f)
      return(invisible(NULL))
    },
    .unzip_file = function(.x) {
      mock_dir <- fs::path_ext_remove(.x)
      fs::dir_create(mock_dir)
      return(invisible(NULL))
    }
  )
  
  # Mock fs::dir_ls to return files for multiple years
  mockery::stub(.get_agfd, "fs::dir_ls", function(path, ...) {
    mock_dir <- fs::path(fs::path_dir(tempfile()), "historical_climate_prices")
    files <- c(
      fs::path(mock_dir, "c2018_data.nc"),
      fs::path(mock_dir, "c2019_data.nc"),
      fs::path(mock_dir, "c2020_data.nc"),
      fs::path(mock_dir, "c2021_data.nc"),
      fs::path(mock_dir, "c2022_data.nc")
    )
    # Set names for grepl to work correctly
    names(files) <- basename(files)
    return(files)
  })
  
  # Test filtering for specific years
  result <- .get_agfd(.fixed_prices = FALSE, .yyyy = c(2019, 2021), .x = NULL)
  
  expect_type(result, "character")
  expect_length(result, 2)
  expect_true(all(grepl("c201[91]", basename(result))))
  expect_false(any(grepl("c202[02]", basename(result))))
})

test_that(".get_agfd uses correct URLs for different datasets", {
  download_calls <- list()
  
  # Mock .retry_download to capture URL calls
  local_mocked_bindings(
    .retry_download = function(url, .f) {
      download_calls <<- append(download_calls, url)
      writeLines("mock content", .f)
      return(invisible(NULL))
    },
    .unzip_file = function(.x) {
      mock_dir <- fs::path_ext_remove(.x)
      fs::dir_create(mock_dir)
      return(invisible(NULL))
    }
  )
  
  mockery::stub(.get_agfd, "fs::dir_ls", function(path, ...) {
    character(0)  # Return empty for simplicity
  })
  
  # Test fixed prices URL
  .get_agfd(.fixed_prices = TRUE, .yyyy = 2020, .x = NULL)
  expect_true(any(grepl("asset/1036161/3", download_calls)))
  
  # Reset and test historical prices URL
  download_calls <- list()
  .get_agfd(.fixed_prices = FALSE, .yyyy = 2020, .x = NULL)
  expect_true(any(grepl("asset/1036161/2", download_calls)))
})