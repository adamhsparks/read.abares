test_that("read_clum_commodities downloads and reads shapefile", {
  local_mocked_bindings(
    .retry_download = function(url, .f) {
      expect_true(grepl("clum_commodities_2023.zip", url))
      writeLines("mock zip content", .f)
      return(invisible(NULL))
    },
    .unzip_file = function(.x) {
      mock_dir <- fs::path(tempdir(), "CLUM_Commodities_2023")
      fs::dir_create(mock_dir)
      return(invisible(NULL))
    },
    sf::st_read = function(dsn, quiet = TRUE) {
      # Mock sf object
      data.frame(
        commodity = c("Wheat", "Barley", "Corn"),
        area_ha = c(1000, 800, 600),
        geometry = I(list(
          structure(list(), class = "POLYGON"),
          structure(list(), class = "POLYGON"),
          structure(list(), class = "POLYGON")
        ))
      ) %>%
        structure(class = c("sf", "data.frame"))
    },
    sf::st_make_valid = function(x) {
      return(x)  # Return the same object as "valid"
    }
  )
  
  result <- read_clum_commodities(x = NULL)
  
  expect_s3_class(result, "sf")
  expect_true("commodity" %in% names(result))
  expect_equal(nrow(result), 3)
})

test_that("read_clum_commodities works with user-provided file", {
  temp_zip <- tempfile(fileext = ".zip")
  writeLines("mock content", temp_zip)
  
  local_mocked_bindings(
    sf::st_read = function(dsn, quiet = TRUE) {
      data.frame(
        commodity = c("User_Commodity"),
        area_ha = c(500),
        geometry = I(list(structure(list(), class = "POLYGON")))
      ) %>%
        structure(class = c("sf", "data.frame"))
    },
    sf::st_make_valid = function(x) {
      return(x)
    }
  )
  
  result <- read_clum_commodities(x = temp_zip)
  
  expect_s3_class(result, "sf")
  expect_equal(result$commodity, "User_Commodity")
  
  # Clean up
  unlink(temp_zip)
})

test_that("read_clum_commodities respects verbosity options", {
  # Test with quiet option
  options(read.abares.verbosity = "quiet")
  
  quiet_calls <- list()
  
  local_mocked_bindings(
    .retry_download = function(url, .f) {
      writeLines("mock content", .f)
      return(invisible(NULL))
    },
    .unzip_file = function(.x) {
      return(invisible(NULL))
    },
    sf::st_read = function(dsn, quiet = TRUE) {
      quiet_calls <<- append(quiet_calls, quiet)
      data.frame(
        commodity = c("Test"),
        geometry = I(list(structure(list(), class = "POLYGON")))
      ) %>%
        structure(class = c("sf", "data.frame"))
    },
    sf::st_make_valid = function(x) x
  )
  
  result <- read_clum_commodities()
  
  expect_true(quiet_calls[[1]])  # Should be TRUE for quiet mode
  
  # Reset option
  options(read.abares.verbosity = "verbose")
})

test_that("Network error handling works across functions", {
  # Test error propagation from .retry_download
  local_mocked_bindings(
    .retry_download = function(url, .f) {
      stop("Network error: Could not connect to server")
    }
  )
  
  expect_error(
    read_clum_commodities(x = NULL),
    "Network error"
  )
})

test_that("File system error handling works", {
  # Test error when unzip fails
  local_mocked_bindings(
    .retry_download = function(url, .f) {
      writeLines("corrupted zip", .f)
      return(invisible(NULL))
    },
    .unzip_file = function(.x) {
      stop("Error extracting zip file")
    }
  )
  
  expect_error(
    read_clum_commodities(x = NULL),
    "Error extracting zip file"
  )
})

test_that("Invalid geometry handling in shapefile reading", {
  local_mocked_bindings(
    .retry_download = function(url, .f) {
      writeLines("mock content", .f)
      return(invisible(NULL))
    },
    .unzip_file = function(.x) {
      return(invisible(NULL))
    },
    sf::st_read = function(dsn, quiet = TRUE) {
      # Mock sf object with invalid geometry
      data.frame(
        commodity = c("InvalidGeom"),
        geometry = I(list(structure(list(), class = "INVALID_POLYGON")))
      ) %>%
        structure(class = c("sf", "data.frame"))
    },
    sf::st_make_valid = function(x) {
      # Simulate fixing invalid geometries
      x$geometry <- I(list(structure(list(), class = "POLYGON")))
      return(x)
    }
  )
  
  result <- read_clum_commodities()
  
  expect_s3_class(result, "sf")
  expect_true(any(class(result$geometry[[1]]) == "POLYGON"))
})

test_that("Edge case: Empty shapefile handling", {
  local_mocked_bindings(
    .retry_download = function(url, .f) {
      writeLines("mock content", .f)
      return(invisible(NULL))
    },
    .unzip_file = function(.x) {
      return(invisible(NULL))
    },
    sf::st_read = function(dsn, quiet = TRUE) {
      # Mock empty sf object
      data.frame(
        commodity = character(0),
        geometry = I(list())
      ) %>%
        structure(class = c("sf", "data.frame"))
    },
    sf::st_make_valid = function(x) x
  )
  
  result <- read_clum_commodities()
  
  expect_s3_class(result, "sf")
  expect_equal(nrow(result), 0)
})

test_that("Package loading and unloading works correctly", {
  # Test .onLoad function
  original_options <- options()
  
  # Mock environment setup
  test_env <- new.env()
  assign(".read.abares_env", test_env, envir = environment())
  
  # Mock the collaborators function and user agent
  local_mocked_bindings(
    readabares_user_agent = function() "test_user_agent"
  )
  
  # Simulate package loading
  expect_no_error({
    .onLoad("testlib", "read.abares")
  })
  
  # Check that options were set
  expect_true("read.abares.user_agent" %in% names(options()))
  expect_true("read.abares.timeout" %in% names(options()))
  expect_true("read.abares.max_tries" %in% names(options()))
  expect_true("read.abares.verbosity" %in% names(options()))
  
  # Test .onUnload function
  expect_no_error({
    .onUnload("testlib")
  })
  
  # Restore original options
  options(original_options)
})

test_that("User agent environment detection works", {
  # Test CI environment detection with corrected environment variable
  original_ci <- Sys.getenv("READABARES_CI")
  Sys.setenv(READABARES_CI = "true")
  
  result <- readabares_user_agent()
  expect_true(grepl("CI", result))
  
  # Restore original
  if (nzchar(original_ci)) {
    Sys.setenv(READABARES_CI = original_ci)
  } else {
    Sys.unsetenv("READABARES_CI")
  }
})

test_that("Argument validation works in main functions", {
  # Test invalid year argument
  local_mocked_bindings(
    .find_years = function(data_set) {
      c("2022-23", "2021-22")
    }
  )
  
  expect_error(
    read_abs_horticulture_data(year = "invalid-year"),
    "arg.*must be one of"
  )
  
  expect_error(
    read_abs_livestock_data(year = "2019-20"),  # Not in available years
    "arg.*must be one of"
  )
})