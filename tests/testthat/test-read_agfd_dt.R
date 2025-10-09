test_that("read_agfd_dt validates yyyy bounds", {
  skip_if_offline()
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
  skip_if_offline()

  files <- file.path(tempdir(), c("x_c2020.nc", "x_c2021.nc"))

  # Mock the tidync package bindings in the tidync namespace
  with_mocked_bindings(
    tidync = function(p) list(src = p),
    hyper_tibble = function(obj) {
      id <- basename(obj$src)
      if (grepl("2020", id)) {
        data.frame(
          lat = c("1", "2"), # characters to test coercion
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
      # Mock .get_agfd inside read.abares
      with_mocked_bindings(
        .get_agfd = function(.fixed_prices, .yyyy, .x) {
          expect_true(.fixed_prices)
          expect_equal(.yyyy, 2020:2021)
          expect_null(.x)
          files
        },
        {
          dat <- read.abares::read_agfd_dt(
            fixed_prices = TRUE,
            yyyy = 2020:2021,
            x = NULL
          )

          expect_s3_class(dat, "data.table")
          expect_setequal(unique(dat$id), basename(files))
          expect_true(is.numeric(dat$lat))
          expect_true(is.numeric(dat$lon))
          expect_equal(nrow(dat), 3L)
          expect_equal(sort(dat$lat), c(1, 2, 3))
          expect_equal(sort(dat$lon), c(10, 20, 30))
        },
        .package = "read.abares"
      )
    },
    .package = "tidync"
  )
})

test_that("read_agfd_dt forwards fixed_prices = FALSE to .get_agfd (historical prices path)", {
  skip_if_offline()

  files <- file.path(tempdir(), c("y_c1995.nc", "y_c1996.nc"))

  with_mocked_bindings(
    tidync = function(p) list(src = p),
    hyper_tibble = function(obj) {
      data.frame(
        lat = c("4"),
        lon = c("40"),
        value = c(0.4),
        stringsAsFactors = FALSE
      )
    },
    {
      with_mocked_bindings(
        .get_agfd = function(.fixed_prices, .yyyy, .x) {
          expect_false(.fixed_prices)
          expect_equal(.yyyy, 1995:1996)
          expect_null(.x)
          files
        },
        {
          dat <- read.abares::read_agfd_dt(
            fixed_prices = FALSE,
            yyyy = 1995:1996,
            x = NULL
          )

          expect_s3_class(dat, "data.table")
          expect_setequal(unique(dat$id), basename(files))
          expect_true(is.numeric(dat$lat))
          expect_true(is.numeric(dat$lon))
          expect_equal(nrow(dat), 2L)
        },
        .package = "read.abares"
      )
    },
    .package = "tidync"
  )
})

test_that("read_agfd_dt forwards x to .get_agfd when supplied", {
  skip_if_offline()

  fake_zip <- file.path(tempdir(), "some_agfd.zip")
  files <- file.path(tempdir(), c("z_c2022.nc"))

  with_mocked_bindings(
    tidync = function(p) list(src = p),
    hyper_tibble = function(obj) {
      # Return 0-row payload but with expected columns; pipeline should still run
      data.frame(lat = character(), lon = character(), stringsAsFactors = FALSE)
    },
    {
      with_mocked_bindings(
        .get_agfd = function(.fixed_prices, .yyyy, .x) {
          expect_true(.fixed_prices)
          expect_equal(.yyyy, 2022)
          expect_identical(.x, fake_zip)
          files
        },
        {
          dat <- read.abares::read_agfd_dt(
            fixed_prices = TRUE,
            yyyy = 2022,
            x = fake_zip
          )

          expect_s3_class(dat, "data.table")
          # Depending on data.table version, id may or may not be present for 0-row bind.
          # Determine expected behavior dynamically using an equivalent 0-row example:
          example_zero <- data.table::as.data.table(
            data.frame(lat = character(), lon = character())
          )
          expected_zero <- data.table::rbindlist(
            list(example_zero),
            idcol = "id"
          )
          if ("id" %in% names(expected_zero)) {
            expect_true("id" %in% names(dat))
          }
          # If any rows, id must match basenames
          if (nrow(dat) > 0L) {
            expect_setequal(unique(dat$id), basename(files))
          }
        },
        .package = "read.abares"
      )
    },
    .package = "tidync"
  )
})

test_that("read_agfd_dt returns empty data.table with lat/lon when .get_agfd returns no files", {
  skip_if_offline()

  with_mocked_bindings(
    .get_agfd = function(...) character(),
    {
      dat <- read.abares::read_agfd_dt(
        fixed_prices = TRUE,
        yyyy = 2022,
        x = NULL
      )

      expect_s3_class(dat, "data.table")
      expect_equal(nrow(dat), 0L)

      # Guaranteed by the function via coercion lines even after empty rbindlist
      expect_true(all(c("lat", "lon") %in% names(dat)))
      expect_true(is.numeric(dat$lat))
      expect_true(is.numeric(dat$lon))

      # `id` presence with an empty rbindlist(list(), idcol="id") varies by data.table version.
      # Only assert it exists if data.table would supply it in an equivalent empty case.
      empty_has_id <- "id" %in%
        names(data.table::rbindlist(list(), idcol = "id"))
      if (empty_has_id) {
        expect_true("id" %in% names(dat))
      }
    },
    .package = "read.abares"
  )
})
