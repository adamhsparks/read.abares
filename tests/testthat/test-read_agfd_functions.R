test_that("read_agfd_dt reads AGFD data with fixed prices", {
  # Mock .get_agfd to return mock NetCDF file paths
  local_mocked_bindings(
    .get_agfd = function(.fixed_prices, .yyyy, .x) {
      expect_true(.fixed_prices)
      expect_equal(.yyyy, 2020:2021)
      c(
        "/mock/path/c2020_data.nc",
        "/mock/path/c2021_data.nc"
      )
    },
    tidync::tidync = function(file) {
      # Mock tidync object
      list(
        file = file,
        transforms = list(list(vars = c("profit", "revenue", "costs")))
      )
    },
    tidync::hyper_tibble = function(x, select_var = NULL) {
      # Mock tibble data
      tibble::tibble(
        lat = c(-25.0, -25.0, -26.0, -26.0),
        lon = c(150.0, 151.0, 150.0, 151.0),
        profit = c(50000, 60000, 45000, 55000),
        revenue = c(200000, 220000, 180000, 210000),
        costs = c(150000, 160000, 135000, 155000),
        year = rep(2020, 4)
      )
    }
  )
  
  result <- read_agfd_dt(fixed_prices = TRUE, yyyy = 2020:2021, x = NULL)
  
  expect_s3_class(result, "data.table")
  expect_true(all(c("lat", "lon", "profit", "revenue", "costs") %in% names(result)))
  expect_equal(nrow(result), 8)  # 4 rows × 2 years
})

test_that("read_agfd_dt handles user-provided file", {
  temp_file <- tempfile(fileext = ".zip")
  writeLines("mock zip content", temp_file)
  
  local_mocked_bindings(
    .get_agfd = function(.fixed_prices, .yyyy, .x) {
      expect_equal(.x, temp_file)
      c("/mock/path/user_data.nc")
    },
    tidync::tidync = function(file) {
      list(file = file, transforms = list(list(vars = c("profit"))))
    },
    tidync::hyper_tibble = function(x, select_var = NULL) {
      tibble::tibble(
        lat = -25.0,
        lon = 150.0,
        profit = 40000,
        year = 2020
      )
    }
  )
  
  result <- read_agfd_dt(fixed_prices = FALSE, yyyy = 2020, x = temp_file)
  
  expect_s3_class(result, "data.table")
  expect_equal(nrow(result), 1)
  
  # Clean up
  unlink(temp_file)
})

test_that("read_agfd_dt processes multiple NetCDF files correctly", {
  local_mocked_bindings(
    .get_agfd = function(.fixed_prices, .yyyy, .x) {
      c(
        "/mock/path/c2019_data.nc",
        "/mock/path/c2020_data.nc",
        "/mock/path/c2021_data.nc"
      )
    },
    tidync::tidync = function(file) {
      list(file = file, transforms = list(list(vars = c("profit", "revenue"))))
    },
    tidync::hyper_tibble = function(x, select_var = NULL) {
      year <- as.numeric(substr(basename(x$file), 2, 5))
      tibble::tibble(
        lat = c(-25.0, -26.0),
        lon = c(150.0, 151.0),
        profit = c(year * 1000, year * 1100),
        revenue = c(year * 5000, year * 5500),
        year = rep(year, 2)
      )
    }
  )
  
  result <- read_agfd_dt(fixed_prices = TRUE, yyyy = 2019:2021, x = NULL)
  
  expect_s3_class(result, "data.table")
  expect_equal(nrow(result), 6)  # 2 rows × 3 years
  expect_equal(sort(unique(result$year)), c(2019, 2020, 2021))
})

test_that("read_agfd_stars creates stars object", {
  local_mocked_bindings(
    .get_agfd = function(.fixed_prices, .yyyy, .x) {
      c("/mock/path/c2020_data.nc")
    },
    stars::read_ncdf = function(filename, var = NULL, ...) {
      # Mock stars object
      structure(
        list(
          profit = array(1:100, dim = c(10, 10, 1)),
          dimensions = list(
            lon = seq(140, 150, length.out = 10),
            lat = seq(-30, -20, length.out = 10),
            time = 1
          )
        ),
        class = "stars"
      )
    }
  )
  
  result <- read_agfd_stars(fixed_prices = TRUE, yyyy = 2020, x = NULL)
  
  expect_s3_class(result, "stars")
})

test_that("read_agfd_terra creates SpatRaster object", {
  local_mocked_bindings(
    .get_agfd = function(.fixed_prices, .yyyy, .x) {
      c("/mock/path/c2020_data.nc")
    },
    terra::rast = function(x, ...) {
      # Mock SpatRaster object
      structure(
        list(
          file = x,
          nlyr = 1,
          names = "profit"
        ),
        class = "SpatRaster"
      )
    }
  )
  
  result <- read_agfd_terra(fixed_prices = TRUE, yyyy = 2020, x = NULL)
  
  expect_s3_class(result, "SpatRaster")
})

test_that("read_agfd_tidync creates tidync object", {
  local_mocked_bindings(
    .get_agfd = function(.fixed_prices, .yyyy, .x) {
      c("/mock/path/c2020_data.nc")
    },
    tidync::tidync = function(x) {
      structure(
        list(
          source = list(source = x),
          dimension = data.frame(
            name = c("lon", "lat", "time"),
            length = c(100, 100, 1)
          ),
          variable = data.frame(
            name = c("profit", "revenue"),
            ndims = c(3, 3)
          )
        ),
        class = "tidync"
      )
    }
  )
  
  result <- read_agfd_tidync(fixed_prices = TRUE, yyyy = 2020, x = NULL)
  
  expect_s3_class(result, "tidync")
  expect_true("source" %in% names(result))
  expect_true("dimension" %in% names(result))
  expect_true("variable" %in% names(result))
})