test_that("read_agfd_dt validates yyyy bounds", {
  expect_error(
    read.abares::read_agfd_dt(yyyy = c(1990, 1991)),
    "must be between 1991 and 2023 inclusive"
  )
  expect_error(
    read.abares::read_agfd_dt(yyyy = c(2023, 2024)),
    "must be between 1991 and 2023 inclusive"
  )
})

test_that("read_agfd_dt integrates correctly: binds rows, sets id to basenames, coerces lat/lon (fixed prices)", {
  skip_on_cran()

  # Files that .get_agfd should 'return'
  files <- file.path(tempdir(), c("x_c2020.nc", "x_c2021.nc"))

  # Mock tidync API in its own namespace first:
  testthat::with_mocked_bindings(
    `tidync::tidync` = function(p) list(src = p),
    `tidync::hyper_tibble` = function(obj) {
      id <- basename(obj$src)
      if (grepl("2020", id)) {
        # Note lat/lon as character to test coercion to numeric
        data.frame(
          lat = c("1", "2"),
          lon = c("10", "20"),
          value = c(0.1, 0.2),
          stringsAsFactors = FALSE
        )
      } else {
        data.frame(
          lat = c("3"),
          lon = c("30"),
          value = c(0.3),
          stringsAsFactors = FALSE
        )
      }
    },
    {
      # Mock .get_agfd within read.abares namespace
      testthat::with_mocked_bindings(
        .get_agfd = function(.fixed_prices, .yyyy, .x) {
          testthat::expect_true(.fixed_prices)
          testthat::expect_equal(.yyyy, 2020:2021)
          testthat::expect_null(.x)
          files
        },
        {
          dat <- read.abares::read_agfd_dt(
            fixed_prices = TRUE,
            yyyy = 2020:2021,
            x = NULL
          )

          testthat::expect_s3_class(dat, "data.table")
          # id should be the basenames of the list elements used in rbindlist(idcol="id")
          testthat::expect_setequal(unique(dat$id), basename(files))

          # Coercions should result in numeric columns
          testthat::expect_true(is.numeric(dat$lat))
          testthat::expect_true(is.numeric(dat$lon))

          # Row count matches the synthetic payload (2 from 2020 + 1 from 2021)
          testthat::expect_equal(nrow(dat), 3L)

          # Optional: verify values
          testthat::expect_equal(sort(dat$lat), c(1, 2, 3))
          testthat::expect_equal(sort(dat$lon), c(10, 20, 30))
        },
        .package = "read.abares"
      )
    }
  )
})

test_that("read_agfd_dt forwards fixed_prices = FALSE to .get_agfd (historical prices path)", {
  skip_on_cran()

  files <- file.path(tempdir(), c("y_c1995.nc", "y_c1996.nc"))

  testthat::with_mocked_bindings(
    `tidync::tidync` = function(p) list(src = p),
    `tidync::hyper_tibble` = function(obj) {
      data.frame(
        lat = c("4"),
        lon = c("40"),
        value = c(0.4),
        stringsAsFactors = FALSE
      )
    },
    {
      testthat::with_mocked_bindings(
        .get_agfd = function(.fixed_prices, .yyyy, .x) {
          testthat::expect_false(.fixed_prices)
          testthat::expect_equal(.yyyy, 1995:1996)
          testthat::expect_null(.x)
          files
        },
        {
          dat <- read.abares::read_agfd_dt(
            fixed_prices = FALSE,
            yyyy = 1995:1996,
            x = NULL
          )
          testthat::expect_s3_class(dat, "data.table")
          testthat::expect_setequal(unique(dat$id), basename(files))
          testthat::expect_true(is.numeric(dat$lat))
          testthat::expect_true(is.numeric(dat$lon))
          testthat::expect_equal(nrow(dat), 2L)
        },
        .package = "read.abares"
      )
    }
  )
})

test_that("read_agfd_dt forwards x to .get_agfd when supplied", {
  skip_on_cran()

  fake_zip <- file.path(tempdir(), "some_agfd.zip")
  files <- file.path(tempdir(), c("z_c2022.nc"))
  # We won't use tidync in this test (0 rows), but mock it anyway for safety.
  testthat::with_mocked_bindings(
    `tidync::tidync` = function(p) list(src = p),
    `tidync::hyper_tibble` = function(obj) {
      data.frame(
        lat = character(),
        lon = character(),
        stringsAsFactors = FALSE
      )
    },
    {
      testthat::with_mocked_bindings(
        .get_agfd = function(.fixed_prices, .yyyy, .x) {
          testthat::expect_true(.fixed_prices)
          testthat::expect_equal(.yyyy, 2022)
          testthat::expect_identical(.x, fake_zip)
          files
        },
        {
          dat <- read.abares::read_agfd_dt(
            fixed_prices = TRUE,
            yyyy = 2022,
            x = fake_zip
          )
          testthat::expect_true("id" %in% names(dat))
          testthat::expect_setequal(unique(dat$id), basename(files))
        },
        .package = "read.abares"
      )
    }
  )
})

test_that("read_agfd_dt returns empty data.table with id/lat/lon when .get_agfd returns no files", {
  skip_on_cran()

  # Mock .get_agfd to return nothing; tidync should not be called.
  testthat::with_mocked_bindings(
    .get_agfd = function(...) character(),
    {
      # (No need to mock tidync; function shouldn't call it)
      dat <- read.abares::read_agfd_dt(
        fixed_prices = TRUE,
        yyyy = 2022,
        x = NULL
      )

      testthat::expect_s3_class(dat, "data.table")
      testthat::expect_equal(nrow(dat), 0L)

      # By construction: rbindlist(list(), idcol="id") + explicit lat/lon coercions
      # yield an empty DT with 'id', 'lat', 'lon' present and numeric types.
      testthat::expect_true(all(c("id", "lat", "lon") %in% names(dat)))
      testthat::expect_true(is.numeric(dat$lat))
      testthat::expect_true(is.numeric(dat$lon))
    },
    .package = "read.abares"
  )
})
