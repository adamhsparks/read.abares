test_that("read_clum_commodities downloads and processes data when x is NULL", {
  skip_if_offline()
  # Mock data to return from sf::st_read
  mock_sf_data <- data.frame(
    id = 1:3,
    name = c("A", "B", "C"),
    stringsAsFactors = FALSE
  )
  class(mock_sf_data) <- c("sf", "data.frame")

  local_mocked_bindings(
    tempdir = function() "/tmp/test",
    .package = "base"
  )

  # Mock the internal functions - these need to be mocked at the package level
  local_mocked_bindings(
    .retry_download = function(url, dest) {
      expect_identical(
        url,
        "https://data.gov.au/data/dataset/8af26be3-da5d-4255-b554-f615e950e46d/resource/b216cf90-f4f0-4d88-980f-af7d1ad746cb/download/clum_commodities_2023.zip"
      )
      expect_identical(dest, "/tmp/test/clum_commodities.zip")
    },
    .unzip_file = function(x) {
      expect_identical(x, "/tmp/test/clum_commodities.zip")
    }
  )

  # Mock sf functions
  local_mocked_bindings(
    st_read = function(dsn, quiet) {
      expect_identical(dsn, "/tmp/test/clum_commodities/CLUM_Commodities_2023")
      expect_false(quiet)
      return(mock_sf_data)
    },
    st_make_valid = function(x) {
      expect_identical(x, mock_sf_data)
      return(x)
    },
    .package = "sf"
  )

  # Mock fs::path
  local_mocked_bindings(
    path = function(...) {
      args <- list(...)
      if (
        length(args) == 2 &&
          args[[1]] == "/tmp/test" &&
          args[[2]] == "clum_commodities.zip"
      ) {
        return("/tmp/test/clum_commodities.zip")
      }
      if (
        length(args) == 2 &&
          args[[1]] == "/tmp/test" &&
          args[[2]] == "CLUM_Commodities_2023"
      ) {
        return("/tmp/test/clum_commodities/CLUM_Commodities_2023")
      }
      return(paste(args, collapse = "/"))
    },
    .package = "fs"
  )

  result <- read_clum_commodities()

  expect_s3_class(result, "sf")
  expect_identical(result, mock_sf_data)
})

test_that("read_clum_commodities respects verbosity options", {
  skip_if_offline()
  # Test quiet option
  withr::local_options(list("read.abares.verbosity" = "quiet"))

  mock_sf_data <- data.frame(id = 1, name = "test")
  class(mock_sf_data) <- c("sf", "data.frame")

  local_mocked_bindings(
    tempdir = function() "/tmp/test",
    .package = "base"
  )

  local_mocked_bindings(
    .retry_download = function(url, dest) {},
    .unzip_file = function(x) {}
  )

  local_mocked_bindings(
    st_read = function(dsn, quiet) {
      expect_true(quiet) # Should be TRUE when verbosity is quiet
      return(mock_sf_data)
    },
    st_make_valid = function(x) x,
    .package = "sf"
  )

  local_mocked_bindings(
    path = function(...) paste(list(...), collapse = "/"),
    .package = "fs"
  )

  result <- read_clum_commodities()
  expect_s3_class(result, "sf")

  # Test verbose option
  withr::local_options(list("read.abares.verbosity" = "verbose"))

  local_mocked_bindings(
    st_read = function(dsn, quiet) {
      expect_false(quiet) # Should be FALSE when verbosity is verbose
      return(mock_sf_data)
    },
    st_make_valid = function(x) x,
    .package = "sf"
  )

  result <- read_clum_commodities()
  expect_s3_class(result, "sf")
})

test_that("read_clum_commodities uses provided file path when x is not NULL", {
  skip_if_offline()
  mock_sf_data <- data.frame(
    id = 1:2,
    commodity = c("Wheat", "Barley"),
    stringsAsFactors = FALSE
  )
  class(mock_sf_data) <- c("sf", "data.frame")

  local_mocked_bindings(
    st_read = function(dsn, quiet) {
      expect_equal(dsn, "/custom/path/to/data")
      return(mock_sf_data)
    },
    st_make_valid = function(x) {
      expect_identical(x, mock_sf_data)
      return(x)
    },
    .package = "sf"
  )

  result <- read_clum_commodities(x = "/custom/path/to/data")

  expect_s3_class(result, "sf")
  expect_identical(result, mock_sf_data)
})

test_that("read_clum_commodities handles sf::st_make_valid correctly", {
  skip_if_offline()
  mock_invalid_data <- data.frame(id = 1, name = "invalid")
  class(mock_invalid_data) <- c("sf", "data.frame")

  mock_valid_data <- data.frame(id = 1, name = "valid")
  class(mock_valid_data) <- c("sf", "data.frame")

  local_mocked_bindings(
    tempdir = function() "/tmp/test",
    .package = "base"
  )

  local_mocked_bindings(
    .retry_download = function(url, dest) {},
    .unzip_file = function(x) {}
  )

  local_mocked_bindings(
    st_read = function(dsn, quiet) {
      return(mock_invalid_data)
    },
    st_make_valid = function(x) {
      expect_identical(x, mock_invalid_data)
      return(mock_valid_data)
    },
    .package = "sf"
  )

  local_mocked_bindings(
    path = function(...) paste(list(...), collapse = "/"),
    .package = "fs"
  )

  result <- read_clum_commodities()

  expect_s3_class(result, "sf")
  expect_identical(result, mock_valid_data)
})

test_that("read_clum_commodities handles download errors gracefully", {
  skip_if_offline()
  local_mocked_bindings(
    tempdir = function() "/tmp/test",
    .package = "base"
  )

  local_mocked_bindings(
    .retry_download = function(url, dest) {
      stop("Download failed")
    }
  )

  local_mocked_bindings(
    path = function(...) paste(list(...), collapse = "/"),
    .package = "fs"
  )

  expect_error(
    read_clum_commodities(),
    "Download failed"
  )
})

test_that("read_clum_commodities handles sf::st_read errors gracefully", {
  skip_if_offline()
  local_mocked_bindings(
    tempdir = function() "/tmp/test",
    .package = "base"
  )

  local_mocked_bindings(
    .retry_download = function(url, dest) {},
    .unzip_file = function(x) {}
  )

  local_mocked_bindings(
    st_read = function(dsn, quiet) {
      stop("Cannot read shapefile")
    },
    st_make_valid = function(x) x,
    .package = "sf"
  )

  local_mocked_bindings(
    path = function(...) paste(list(...), collapse = "/"),
    .package = "fs"
  )

  expect_error(
    read_clum_commodities(),
    "Cannot read shapefile"
  )
})

test_that("read_clum_commodities constructs correct file paths", {
  skip_if_offline()
  mock_sf_data <- data.frame(id = 1)
  class(mock_sf_data) <- c("sf", "data.frame")

  local_mocked_bindings(
    tempdir = function() "/tmp/test_dir",
    .package = "base"
  )

  local_mocked_bindings(
    .retry_download = function(url, dest) {},
    .unzip_file = function(x) {}
  )

  # Track the paths being constructed
  paths_created <- character()

  local_mocked_bindings(
    path = function(...) {
      result <- paste(list(...), collapse = "/")
      paths_created <<- c(paths_created, result)
      return(result)
    },
    .package = "fs"
  )

  local_mocked_bindings(
    st_read = function(dsn, quiet) {
      expect_identical(
        dsn,
        "/tmp/test_dir/clum_commodities/CLUM_Commodities_2023"
      )
      return(mock_sf_data)
    },
    st_make_valid = function(x) x,
    .package = "sf"
  )

  result <- read_clum_commodities()

  expect_true("/tmp/test_dir/clum_commodities.zip" %in% paths_created)
  expect_true(
    "/tmp/test_dir/clum_commodities/CLUM_Commodities_2023" %in% paths_created
  )
  expect_s3_class(result, "sf")
})

test_that("read_clum_commodities returns sf object with expected structure", {
  skip_if_offline()
  # Create mock data that mimics expected CLUM structure
  mock_sf_data <- data.frame(
    OBJECTID = 1:3,
    TERTIARY_C = c("A", "B", "C"),
    COMMODITY = c("Wheat", "Barley", "Corn"),
    stringsAsFactors = FALSE
  )
  class(mock_sf_data) <- c("sf", "data.frame")

  local_mocked_bindings(
    tempdir = function() "/tmp/test",
    .package = "base"
  )

  local_mocked_bindings(
    .retry_download = function(url, dest) {},
    .unzip_file = function(x) {}
  )

  local_mocked_bindings(
    st_read = function(dsn, quiet) {
      return(mock_sf_data)
    },
    st_make_valid = function(x) {
      return(x)
    },
    .package = "sf"
  )

  local_mocked_bindings(
    path = function(...) paste(list(...), collapse = "/"),
    .package = "fs"
  )

  result <- read_clum_commodities()

  expect_s3_class(result, "sf")
  expect_s3_class(result, "data.frame")
  expect_gt(nrow(result), 0L)
  expect_identical(result, mock_sf_data)
})
