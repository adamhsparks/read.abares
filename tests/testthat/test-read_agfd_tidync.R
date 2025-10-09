test_that("read_agfd_tidync validates yyyy bounds", {
  expect_error(
    read.abares::read_agfd_tidync(yyyy = c(1990, 1991)),
    "must be between 1991 and 2023 inclusive"
  )
  expect_error(
    read.abares::read_agfd_tidync(yyyy = c(2023, 2024)),
    "must be between 1991 and 2023 inclusive"
  )
})

test_that("read_agfd_tidync integrates: calls .get_agfd, returns named list of tidync (fixed prices)", {
  skip_if_offline()

  files <- file.path(tempdir(), c("x_c2020.nc", "x_c2021.nc"))

  # Mock tidync::tidync to assert path and return a light tidync object
  with_mocked_bindings(
    tidync = function(p) {
      expect_true(p %in% files)
      structure(list(src = p), class = "tidync")
    },
    {
      # Mock .get_agfd in read.abares
      with_mocked_bindings(
        .get_agfd = function(.fixed_prices, .yyyy, .x) {
          expect_true(.fixed_prices)
          expect_identical(.yyyy, 2020:2021)
          expect_null(.x)
          files
        },
        {
          tnc <- read.abares::read_agfd_tidync(
            fixed_prices = TRUE,
            yyyy = 2020:2021,
            x = NULL
          )

          # Structure and naming
          expect_type(tnc, "list")
          expect_length(tnc, length(files))
          expect_named(tnc, basename(files))

          # Elements are tidync objects
          expect_true(all(vapply(
            tnc,
            inherits,
            logical(1),
            "tidync"
          )))

          # Compare the underlying file paths, ignoring names on the character vector
          actual_src <- vapply(tnc, function(e) e$src, character(1))
          expect_identical(unname(actual_src), unname(files))
        },
        .package = "read.abares"
      )
    },
    .package = "tidync"
  )
})


test_that("read_agfd_tidync forwards fixed_prices = FALSE to .get_agfd (historical prices path)", {
  skip_if_offline()

  files <- file.path(tempdir(), c("y_c1995.nc", "y_c1996.nc"))

  with_mocked_bindings(
    tidync = function(p) {
      structure(list(src = p), class = "tidync")
    },
    {
      with_mocked_bindings(
        .get_agfd = function(.fixed_prices, .yyyy, .x) {
          expect_false(.fixed_prices)
          expect_identical(.yyyy, 1995:1996)
          expect_null(.x)
          files
        },
        {
          tnc <- read.abares::read_agfd_tidync(
            fixed_prices = FALSE,
            yyyy = 1995:1996,
            x = NULL
          )

          expect_type(tnc, "list")
          expect_length(tnc, length(files))
          expect_named(tnc, basename(files))
          expect_true(all(vapply(
            tnc,
            inherits,
            logical(1L),
            "tidync"
          )))

          actual_src <- vapply(tnc, function(e) e$src, character(1L))
          expect_identical(unname(actual_src), unname(files))
        },
        .package = "read.abares"
      )
    },
    .package = "tidync"
  )
})

test_that("read_agfd_tidync forwards x to .get_agfd when supplied", {
  skip_if_offline()

  fake_zip <- file.path(tempdir(), "some_agfd.zip")
  files <- file.path(tempdir(), "z_c2022.nc")

  with_mocked_bindings(
    tidync = function(p) structure(list(src = p), class = "tidync"),
    {
      with_mocked_bindings(
        .get_agfd = function(.fixed_prices, .yyyy, .x) {
          expect_true(.fixed_prices)
          expect_identical(.yyyy, 2022)
          expect_identical(.x, fake_zip)
          files
        },
        {
          tnc <- read.abares::read_agfd_tidync(
            fixed_prices = TRUE,
            yyyy = 2022,
            x = fake_zip
          )

          expect_type(tnc, "list")
          expect_length(tnc, 1L)
          expect_named(tnc, basename(files))
          expect_s3_class(tnc[[1]], "tidync")
          expect_identical(tnc[[1]]$src, files)
        },
        .package = "read.abares"
      )
    },
    .package = "tidync"
  )
})

test_that("read_agfd_tidync returns empty list when .get_agfd returns no files (document current behavior)", {
  skip_if_offline()

  # purrr::map(character(0), ...) yields list(), and names(list()) <- character(0)
  with_mocked_bindings(
    .get_agfd = function(...) character(),
    {
      tnc <- read.abares::read_agfd_tidync(
        fixed_prices = TRUE,
        yyyy = 2022,
        x = NULL
      )

      expect_type(tnc, "list")
      expect_length(tnc, 0L)
      expect_named(tnc, character(0))
    },
    .package = "read.abares"
  )
})

test_that("read_agfd_tidync forwards defaults to .get_agfd (fixed_prices=TRUE, yyyy=1991:2023, x=NULL)", {
  skip_if_offline()

  observed <- NULL
  ret_files <- file.path(tempdir(), c("default1.nc", "default2.nc"))

  with_mocked_bindings(
    tidync = function(p) structure(list(src = p), class = "tidync"),
    {
      with_mocked_bindings(
        .get_agfd = function(.fixed_prices, .yyyy, .x) {
          observed <<- list(
            .fixed_prices = .fixed_prices,
            .yyyy = .yyyy,
            .x = .x
          )
          ret_files
        },
        {
          tnc <- read.abares::read_agfd_tidync()

          # Confirm defaults were forwarded
          expect_true(observed$.fixed_prices)
          expect_identical(observed$.yyyy, 1991:2023)
          expect_null(observed$.x)

          # Confirm structure on returned files
          expect_type(tnc, "list")
          expect_length(tnc, length(ret_files))
          expect_named(tnc, basename(ret_files))
          expect_true(all(vapply(
            tnc,
            inherits,
            logical(1),
            "tidync"
          )))
        },
        .package = "read.abares"
      )
    },
    .package = "tidync"
  )
})
