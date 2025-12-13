test_that(".check_agfd_yyyy validates correctly", {
  expect_silent(.check_agfd_yyyy(1991:2023))
  expect_error(.check_agfd_yyyy(1990), "must be between 1991 and 2023")
  expect_error(.check_agfd_yyyy(2024), "must be between 1991 and 2023")
  expect_error(.check_agfd_yyyy("1991"), "must be numeric")
})

test_that("read_agfd_dt uses .get_agfd when x is NULL", {
  called <- FALSE
  fake_file <- "dummy.nc"

  fake_get <- function(.fixed_prices, .yyyy) {
    called <<- TRUE
    fake_file
  }

  fake_tidync <- function(file) "dummy_tidync"
  fake_hyper <- function(tnc) tibble::tibble(lat = 1, lon = 2)

  # patch tidync functions
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

  ns <- asNamespace("read.abares")
  with_mocked_bindings(
    {
      result <- read_agfd_dt(yyyy = 1991)
      expect_true(called)
      expect_s3_class(result, "data.table")
      expect_equal(result$lat, 1)
      expect_equal(result$lon, 2)
    },
    .get_agfd = fake_get,
    .env = ns
  )
})

test_that("read_agfd_dt uses .copy_local_agfd_zip when x is provided", {
  called <- FALSE
  fake_file <- "dummy.nc"

  fake_copy <- function(x) {
    called <<- TRUE
    fake_file
  }

  fake_tidync <- function(file) "dummy_tidync"
  fake_hyper <- function(tnc) tibble::tibble(lat = 1, lon = 2)

  # patch tidync functions
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

  ns <- asNamespace("read.abares")
  with_mocked_bindings(
    {
      result <- read_agfd_dt(x = "dummy.zip")
      expect_true(called)
      expect_s3_class(result, "data.table")
      expect_equal(result$lat, 1)
      expect_equal(result$lon, 2)
    },
    .copy_local_agfd_zip = fake_copy,
    .env = ns
  )
})
