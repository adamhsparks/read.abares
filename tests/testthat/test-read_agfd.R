test_that(".check_agfd_yyyy validates correctly", {
  expect_silent(.check_agfd_yyyy(1991:2023))
  expect_error(.check_agfd_yyyy(1990), "must be between 1991 and 2023")
  expect_error(.check_agfd_yyyy(2024), "must be between 1991 and 2023")
  expect_error(.check_agfd_yyyy("1991"), "must be numeric")
})

# ---- read_agfd_dt ----
test_that("read_agfd_dt works with .get_agfd and .copy_local_agfd_zip", {
  ns <- asNamespace("read.abares")

  fake_file <- "dummy_dt.nc"
  fake_get <- function(.fixed_prices, .yyyy) fake_file
  fake_copy <- function(x) fake_file
  fake_tidync <- function(file) "dummy_tidync"
  fake_hyper <- function(tnc) tibble::tibble(lat = 1, lon = 2)

  old_tidync <- tidync::tidync
  old_hyper <- tidync::hyper_tibble
  assignInNamespace("tidync", fake_tidync, ns = "tidync")
  assignInNamespace("hyper_tibble", fake_hyper, ns = "tidync")
  on.exit(
    {
      assignInNamespace("tidync", old_tidync, ns = "tidync")
      assignInNamespace("hyper_tibble", old_hyper, ns = "tidync")
    },
    add = TRUE
  )

  with_mocked_bindings(
    {
      result <- read_agfd_dt(yyyy = 1991)
      expect_s3_class(result, "data.table")
      expect_identical(result$lat, 1)
      expect_identical(result$lon, 2)
    },
    .get_agfd = fake_get,
    .env = ns
  )

  with_mocked_bindings(
    {
      result <- read_agfd_dt(x = "dummy.zip")
      expect_s3_class(result, "data.table")
      expect_identical(result$lat, 1)
      expect_identical(result$lon, 2)
    },
    .copy_local_agfd_zip = fake_copy,
    .env = ns
  )
})

# ---- read_agfd_stars ----
test_that("read_agfd_stars works with .get_agfd and .copy_local_agfd_zip", {
  ns <- asNamespace("read.abares")

  fake_file <- "dummy_stars.nc"
  fake_get <- function(.fixed_prices, .yyyy) fake_file
  fake_copy <- function(x) fake_file
  fake_read <- function(path) stars::st_as_stars(matrix(1:4, ncol = 2))

  old_read <- stars::read_ncdf
  assignInNamespace("read_ncdf", fake_read, ns = "stars")
  on.exit(assignInNamespace("read_ncdf", old_read, ns = "stars"), add = TRUE)

  with_mocked_bindings(
    {
      result <- read_agfd_stars(yyyy = 1991)
      expect_type(result, "list")
      expect_s3_class(result[[1]], "stars")
      expect_named(result, fs::path_file(fake_file))
    },
    .get_agfd = fake_get,
    .env = ns
  )

  with_mocked_bindings(
    {
      result <- read_agfd_stars(x = "dummy.zip")
      expect_type(result, "list")
      expect_s3_class(result[[1]], "stars")
      expect_named(result, fs::path_file(fake_file))
    },
    .copy_local_agfd_zip = fake_copy,
    .env = ns
  )
})

# ---- read_agfd_terra ----
test_that("read_agfd_terra works with .get_agfd and .copy_local_agfd_zip", {
  ns <- asNamespace("read.abares")

  fake_file <- "dummy_terra.nc"
  fake_get <- function(.fixed_prices, .yyyy) fake_file
  fake_copy <- function(x) fake_file

  # capture the original terra::rast before overriding
  orig_rast <- terra::rast
  dummy_rast <- orig_rast(matrix(1:4, ncol = 2))

  fake_rast <- function(path) dummy_rast

  assignInNamespace("rast", fake_rast, ns = "terra")
  on.exit(assignInNamespace("rast", orig_rast, ns = "terra"), add = TRUE)

  with_mocked_bindings(
    {
      result <- read_agfd_terra(yyyy = 1991)
      expect_type(result, "list")
      expect_s4_class(result[[1]], "SpatRaster")
      expect_named(result, fs::path_file(fake_file))
    },
    .get_agfd = fake_get,
    .env = ns
  )

  with_mocked_bindings(
    {
      result <- read_agfd_terra(x = "dummy.zip")
      expect_type(result, "list")
      expect_s4_class(result[[1]], "SpatRaster")
      expect_named(result, fs::path_file(fake_file))
    },
    .copy_local_agfd_zip = fake_copy,
    .env = ns
  )
})

# ---- read_agfd_tidync ----
test_that("read_agfd_tidync works with .get_agfd and .copy_local_agfd_zip", {
  ns <- asNamespace("read.abares")

  fake_file <- "dummy_tidync.nc"
  fake_get <- function(.fixed_prices, .yyyy) fake_file
  fake_copy <- function(x) fake_file
  fake_tidync <- function(path) "dummy_tidync_obj"

  old_tidync <- tidync::tidync
  assignInNamespace("tidync", fake_tidync, ns = "tidync")
  on.exit(assignInNamespace("tidync", old_tidync, ns = "tidync"), add = TRUE)

  with_mocked_bindings(
    {
      result <- read_agfd_tidync(yyyy = 1991)
      expect_type(result, "list")
      expect_identical(result[[1]], "dummy_tidync_obj")
      expect_named(result, fs::path_file(fake_file))
    },
    .get_agfd = fake_get,
    .env = ns
  )

  with_mocked_bindings(
    {
      result <- read_agfd_tidync(x = "dummy.zip")
      expect_type(result, "list")
      expect_identical(result[[1]], "dummy_tidync_obj")
      expect_named(result, fs::path_file(fake_file))
    },
    .copy_local_agfd_zip = fake_copy,
    .env = ns
  )
})
