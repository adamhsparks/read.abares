test_that(".get_clum downloads and processes clum_50m_2023_v2 data", {
  # Mock dependencies
  local_mocked_bindings(
    .retry_download = function(url, .f) {
      # Verify correct URL is used
      expect_true(grepl("clum_50m_2023_v2.zip", url))
      writeLines("mock zip content", .f)
      return(invisible(NULL))
    },
    .unzip_file = function(.x) {
      # Create mock directory structure
      mock_dir <- fs::path(fs::path_dir(.x), "clum_50m_2023_v2")
      fs::dir_create(mock_dir, recurse = TRUE)
      # Create mock tif files
      mock_files <- c(
        fs::path(mock_dir, "clum_data.tif"),
        fs::path(mock_dir, "subdir", "additional.tif")
      )
      fs::dir_create(dirname(mock_files[2]), recurse = TRUE)
      for (f in mock_files) {
        writeLines("mock tif content", f)
      }
      return(invisible(NULL))
    }
  )
  
  # Mock fs::dir_ls to return mock tif files
  local_mocked_bindings(
    fs::dir_ls = function(path, recurse = TRUE, glob = "*.tif") {
      if (grepl("clum_50m_2023_v2", path)) {
        c(
          fs::path(path, "clum_data.tif"),
          fs::path(path, "subdir", "additional.tif")
        )
      } else {
        character(0)
      }
    }
  )
  
  result <- .get_clum(.data_set = "clum_50m_2023_v2", .x = NULL)
  
  expect_type(result, "character")
  expect_length(result, 2)
  expect_true(all(grepl("\\.tif$", result)))
  expect_true(any(grepl("clum_data.tif", result)))
})

test_that(".get_clum downloads and processes scale_date_update data", {
  # Mock dependencies
  local_mocked_bindings(
    .retry_download = function(url, .f) {
      expect_true(grepl("scale_date_update.zip", url))
      writeLines("mock zip content", .f)
      return(invisible(NULL))
    },
    .unzip_file = function(.x) {
      mock_dir <- fs::path(fs::path_dir(.x), "scale_date_update")
      fs::dir_create(mock_dir, recurse = TRUE)
      mock_files <- c(
        fs::path(mock_dir, "scale_mapping.tif"),
        fs::path(mock_dir, "date_mapping.tif")
      )
      for (f in mock_files) {
        writeLines("mock tif content", f)
      }
      return(invisible(NULL))
    }
  )
  
  local_mocked_bindings(
    fs::dir_ls = function(path, recurse = TRUE, glob = "*.tif") {
      if (grepl("scale_date_update", path)) {
        c(
          fs::path(path, "scale_mapping.tif"),
          fs::path(path, "date_mapping.tif")
        )
      } else {
        character(0)
      }
    }
  )
  
  result <- .get_clum(.data_set = "scale_date_update", .x = NULL)
  
  expect_type(result, "character")
  expect_length(result, 2)
  expect_true(all(grepl("\\.tif$", result)))
})

test_that(".get_clum works with user-specified local file", {
  temp_dir <- tempdir()
  user_zip <- fs::path(temp_dir, "custom_clum.zip")
  
  # Create mock zip file
  writeLines("mock content", user_zip)
  
  # Mock dependencies
  local_mocked_bindings(
    .unzip_file = function(.x) {
      mock_dir <- fs::path(fs::path_dir(.x), "clum_50m_2023_v2")
      fs::dir_create(mock_dir, recurse = TRUE)
      mock_file <- fs::path(mock_dir, "user_data.tif")
      writeLines("mock tif content", mock_file)
      return(invisible(NULL))
    }
  )
  
  local_mocked_bindings(
    fs::dir_ls = function(path, recurse = TRUE, glob = "*.tif") {
      c(fs::path(path, "user_data.tif"))
    }
  )
  
  result <- .get_clum(.data_set = "clum_50m_2023_v2", .x = user_zip)
  
  expect_type(result, "character")
  expect_length(result, 1)
  expect_true(grepl("\\.tif$", result))
  
  # Clean up
  fs::file_delete(user_zip)
})

test_that(".get_clum skips download if file already exists", {
  temp_dir <- tempdir()
  existing_zip <- fs::path(temp_dir, "clum_50m_2023_v2.zip")
  
  # Create existing zip file
  writeLines("existing content", existing_zip)
  
  download_called <- FALSE
  
  local_mocked_bindings(
    fs::file_exists = function(path) {
      if (basename(path) == "clum_50m_2023_v2.zip") {
        return(TRUE)  # File exists
      }
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
  
  local_mocked_bindings(
    fs::dir_ls = function(path, recurse = TRUE, glob = "*.tif") {
      character(0)  # Return empty for simplicity
    }
  )
  
  result <- .get_clum(.data_set = "clum_50m_2023_v2", .x = NULL)
  
  # Should not have called download since file exists
  expect_false(download_called)
  
  # Clean up
  fs::file_delete(existing_zip)
})