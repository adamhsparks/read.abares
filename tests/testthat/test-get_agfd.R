# tests/testthat/test-get_agfd.R

#' Create a fake AGFD tree in tempdir()
#'
#' @param root Directory where to place fixtures (use tempdir()).
#' @param ds Dataset folder name (e.g., "historical_climate_prices_fixed").
#' @param years Integer vector of years to create files for.
#' @return A list with paths to the created dir and zip file.
create_agfd_fixture <- function(root, ds, years) {
  stopifnot(is.character(root), length(root) == 1L)
  stopifnot(is.character(ds), length(ds) == 1L)
  stopifnot(is.numeric(years) || is.integer(years))

  # Directory where .get_agfd() will look for NetCDFs
  data_dir <- fs::path(root, ds)
  fs::dir_create(data_dir, recurse = TRUE)

  # Fake NetCDF filenames that include 'cYYYY', since .get_agfd greps on that
  for (y in years) {
    fn <- sprintf("agfd_%s_c%d.nc", ds, as.integer(y))
    fs::file_touch(fs::path(data_dir, fn))
  }

  # Dummy zip that causes .get_agfd to skip the download branch
  zip_file <- fs::path(root, paste0(ds, ".zip"))
  fs::file_touch(zip_file)

  list(dir = data_dir, zip = zip_file)
}


test_that("when .x is provided, ds is derived from zip basename and years are filtered", {
  skip_on_os("solaris") # optional
  tmp <- tempdir()

  # Use a custom dataset name to ensure ds is taken from .x
  ds <- "my_custom_ds"
  years <- 2018L:2022L
  fix <- create_agfd_fixture(tmp, ds, years = years)

  # Mock .unzip_file to a no-op since .get_agfd(.x=...) will always call it
  res <- testthat::with_mocked_bindings(
    .unzip_file = function(.x) NULL,
    .env = environment(.get_agfd),
    {
      .get_agfd(
        .fixed_prices = TRUE, # irrelevant when .x is provided
        .yyyy = 2020L:2021L,
        .x = fix$zip # pass the local zip path
      )
    }
  )

  expect_type(res, "character")
  expect_true(all(grepl("c(2020|2021)\\b", res)))
  expect_false(any(grepl("c2018|c2019|c2022", res)))
  expect_true(all(fs::path_has_parent(res, fs::path(tmp, ds))))
})

test_that("when .x is NULL and .fixed_prices = TRUE, it uses fixed-prices ds and filters years", {
  tmp <- tempdir()
  ds <- "historical_climate_prices_fixed"
  years <- 1991L:1995L

  # Pre-create zip and unzipped tree so the download/unzip branch is skipped
  create_agfd_fixture(tmp, ds, years = years)

  res <- .get_agfd(
    .fixed_prices = TRUE,
    .yyyy = 1992L:1993L,
    .x = NULL
  )

  expect_type(res, "character")
  expect_true(all(grepl("c(1992|1993)\\b", res)))
  expect_false(any(grepl("c(1991|1994|1995)", res)))
  expect_true(all(fs::path_has_parent(res, fs::path(tmp, ds))))
})

test_that("when .x is NULL and .fixed_prices = FALSE, it uses historical-prices ds and filters years", {
  tmp <- tempdir()
  ds <- "historical_climate_prices"
  years <- 2000L:2002L
  create_agfd_fixture(tmp, ds, years = years)

  res <- .get_agfd(
    .fixed_prices = FALSE,
    .yyyy = 2001L,
    .x = NULL
  )

  expect_type(res, "character")
  expect_length(res, 1L)
  expect_match(res, "c2001\\b")
  expect_true(all(fs::path_has_parent(res, fs::path(tmp, ds))))
})

test_that("returns empty when requested years don't exist in fixture", {
  tmp <- tempdir()
  ds <- "historical_climate_prices_fixed"
  create_agfd_fixture(tmp, ds, years = 1991L:1992L)

  res <- .get_agfd(
    .fixed_prices = TRUE,
    .yyyy = 2020L:2021L,
    .x = NULL
  )

  expect_type(res, "character")
  expect_length(res, 0L)
})


test_that("errors cleanly when .x points to a non-existent zip", {
  tmp <- tempdir()
  bogus_zip <- fs::path(tmp, "missing_ds.zip")
  expect_false(fs::file_exists(bogus_zip))

  expect_error(
    testthat::with_mocked_bindings(
      # Make unzip produce a deterministic, user-friendly error
      .unzip_file = function(.x) {
        stop(sprintf("File does not exist: %s", .x), call. = FALSE)
      },
      .env = environment(.get_agfd),
      {
        .get_agfd(
          .fixed_prices = TRUE,
          .yyyy = 2000L,
          .x = bogus_zip
        )
      }
    ),
    regexp = "File does not exist:"
  )
})
