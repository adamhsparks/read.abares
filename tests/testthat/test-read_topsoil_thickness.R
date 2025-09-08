# Test file: tests/testthat/test-read_topsoil_thickness.R

test_that("read_topsoil_thickness_terra works with mocked data", {
  # Create a mock SpatRaster object for testing
  create_mock_spatraster <- function() {
    # Create a simple raster with some test data
    r <- terra::rast(
      nrows = 10,
      ncols = 10,
      xmin = 113,
      xmax = 154,
      ymin = -44,
      ymax = -10,
      crs = "EPSG:4326"
    )
    terra::values(r) <- runif(100, min = 0, max = 100) # Random thickness values
    names(r) <- "topsoil_thickness_cm"
    return(r)
  }

  # Mock the internal download/read functions
  local_mocked_bindings(
    .data_source = "mocked_data_source",
    download.file = function(url, destfile, ...) {
      # Mock successful download
      return(0)
    },
    terra::rast = function(x) {
      # Return our mock SpatRaster
      create_mock_spatraster()
    },
    .call_env = current_env()
  )

  # Test the function
  result <- read_topsoil_thickness_terra()

  # Verify the result
  expect_s4_class(result, "SpatRaster")
  expect_true(terra::nlyr(result) >= 1)
  expect_true(terra::ncell(result) > 0)
  expect_equal(names(result), "topsoil_thickness_cm")

  # Test that values are within expected range (0-100 cm)
  vals <- terra::values(result, na.rm = TRUE)
  expect_true(all(vals >= 0 & vals <= 100, na.rm = TRUE))
})

test_that("read_topsoil_thickness_stars works with mocked data", {
  # Create a mock stars object for testing
  create_mock_stars <- function() {
    # Create dimensions
    dims <- stars::st_dimensions(
      x = seq(113, 154, length.out = 10),
      y = seq(-44, -10, length.out = 10)
    )

    # Create stars object with random thickness values
    values <- array(runif(100, min = 0, max = 100), dim = c(10, 10))
    dimnames(values) <- list(x = NULL, y = NULL)

    s <- stars::st_as_stars(
      list(topsoil_thickness_cm = values),
      dimensions = dims
    )
    stars::st_crs(s) <- "EPSG:4326"

    return(s)
  }

  # Mock the internal download/read functions
  local_mocked_bindings(
    .data_source = "mocked_data_source",
    download.file = function(url, destfile, ...) {
      # Mock successful download
      return(0)
    },
    stars::read_stars = function(x, ...) {
      # Return our mock stars object
      create_mock_stars()
    },
    .call_env = current_env()
  )

  # Test the function
  result <- read_topsoil_thickness_stars()

  # Verify the result
  expect_s3_class(result, "stars")
  expect_true(length(dim(result)) >= 2)
  expect_true("topsoil_thickness_cm" %in% names(result))

  # Test that CRS is set
  expect_false(is.na(stars::st_crs(result)))

  # Test that values are within expected range
  vals <- as.vector(result[[1]])
  expect_true(all(vals >= 0 & vals <= 100, na.rm = TRUE))
})

test_that("read_topsoil_thickness_terra handles download failures gracefully", {
  # Mock a failed download
  local_mocked_bindings(
    download.file = function(url, destfile, ...) {
      # Return non-zero status (failure)
      return(1)
    },
    .call_env = current_env()
  )

  # Test that the function handles download failure appropriately
  expect_error(
    read_topsoil_thickness_terra(),
    regexp = "download|failed|error",
    ignore.case = TRUE
  )
})

test_that("read_topsoil_thickness_stars handles download failures gracefully", {
  # Mock a failed download
  local_mocked_bindings(
    download.file = function(url, destfile, ...) {
      # Return non-zero status (failure)
      return(1)
    },
    .call_env = current_env()
  )

  # Test that the function handles download failure appropriately
  expect_error(
    read_topsoil_thickness_stars(),
    regexp = "download|failed|error",
    ignore.case = TRUE
  )
})

test_that("read_topsoil_thickness_terra handles corrupt/invalid files", {
  # Mock successful download but corrupt file reading
  local_mocked_bindings(
    download.file = function(url, destfile, ...) {
      return(0) # Successful download
    },
    terra::rast = function(x) {
      stop("Cannot read file: corrupt or invalid format")
    },
    .call_env = current_env()
  )

  # Test that the function handles file reading errors
  expect_error(
    read_topsoil_thickness_terra(),
    regexp = "corrupt|invalid|Cannot read",
    ignore.case = TRUE
  )
})

test_that("read_topsoil_thickness_stars handles corrupt/invalid files", {
  # Mock successful download but corrupt file reading
  local_mocked_bindings(
    download.file = function(url, destfile, ...) {
      return(0) # Successful download
    },
    stars::read_stars = function(x, ...) {
      stop("Cannot read file: corrupt or invalid format")
    },
    .call_env = current_env()
  )

  # Test that the function handles file reading errors
  expect_error(
    read_topsoil_thickness_stars(),
    regexp = "corrupt|invalid|Cannot read",
    ignore.case = TRUE
  )
})

test_that("read_topsoil_thickness_terra respects cache settings", {
  # Test with cache enabled (default behavior)
  cache_checked <- FALSE

  local_mocked_bindings(
    file.exists = function(x) {
      cache_checked <<- TRUE
      return(FALSE) # File doesn't exist, should download
    },
    download.file = function(url, destfile, ...) {
      return(0)
    },
    terra::rast = function(x) {
      r <- terra::rast(nrows = 5, ncols = 5)
      terra::values(r) <- 1:25
      return(r)
    },
    .call_env = current_env()
  )

  result <- read_topsoil_thickness_terra()

  # Verify cache was checked
  expect_true(cache_checked)
  expect_s4_class(result, "SpatRaster")
})

test_that("read_topsoil_thickness_stars respects cache settings", {
  # Test with cache enabled (default behavior)
  cache_checked <- FALSE

  local_mocked_bindings(
    file.exists = function(x) {
      cache_checked <<- TRUE
      return(FALSE) # File doesn't exist, should download
    },
    download.file = function(url, destfile, ...) {
      return(0)
    },
    stars::read_stars = function(x, ...) {
      dims <- stars::st_dimensions(x = 1:5, y = 1:5)
      values <- array(1:25, dim = c(5, 5))
      return(stars::st_as_stars(list(data = values), dimensions = dims))
    },
    .call_env = current_env()
  )

  result <- read_topsoil_thickness_stars()

  # Verify cache was checked
  expect_true(cache_checked)
  expect_s3_class(result, "stars")
})

test_that("read_topsoil_thickness functions handle network timeouts", {
  # Mock network timeout
  local_mocked_bindings(
    download.file = function(url, destfile, ...) {
      stop("Timeout was reached")
    },
    .call_env = current_env()
  )

  # Test terra function
  expect_error(
    read_topsoil_thickness_terra(),
    regexp = "timeout|network|connection",
    ignore.case = TRUE
  )

  # Test stars function
  expect_error(
    read_topsoil_thickness_stars(),
    regexp = "timeout|network|connection",
    ignore.case = TRUE
  )
})

test_that("read_topsoil_thickness functions validate output data quality", {
  # Create mock data with known properties for validation
  create_validated_spatraster <- function() {
    r <- terra::rast(
      nrows = 100,
      ncols = 100,
      xmin = 113,
      xmax = 154,
      ymin = -44,
      ymax = -10,
      crs = "EPSG:4326"
    )
    # Realistic topsoil thickness values (0-200 cm)
    terra::values(r) <- runif(10000, min = 0, max = 200)
    names(r) <- "topsoil_thickness_cm"
    return(r)
  }

  create_validated_stars <- function() {
    dims <- stars::st_dimensions(
      x = seq(113, 154, length.out = 100),
      y = seq(-44, -10, length.out = 100)
    )
    values <- array(runif(10000, min = 0, max = 200), dim = c(100, 100))
    s <- stars::st_as_stars(
      list(topsoil_thickness_cm = values),
      dimensions = dims
    )
    stars::st_crs(s) <- "EPSG:4326"
    return(s)
  }

  # Test terra function with validated data
  local_mocked_bindings(
    download.file = function(url, destfile, ...) return(0),
    terra::rast = function(x) create_validated_spatraster(),
    .call_env = current_env()
  )

  result_terra <- read_topsoil_thickness_terra()

  # Validate terra output
  expect_true(terra::global(result_terra, "min", na.rm = TRUE)[[1]] >= 0)
  expect_true(terra::global(result_terra, "max", na.rm = TRUE)[[1]] <= 200)
  expect_equal(terra::crs(result_terra, describe = TRUE)$name, "WGS 84")

  # Test stars function with validated data
  local_mocked_bindings(
    download.file = function(url, destfile, ...) return(0),
    stars::read_stars = function(x, ...) create_validated_stars(),
    .call_env = current_env()
  )

  result_stars <- read_topsoil_thickness_stars()

  # Validate stars output
  vals_stars <- as.vector(result_stars[[1]])
  expect_true(min(vals_stars, na.rm = TRUE) >= 0)
  expect_true(max(vals_stars, na.rm = TRUE) <= 200)
  expect_equal(as.character(stars::st_crs(result_stars)), "EPSG:4326")
})
