withr::local_envvar(R_USER_CACHE_DIR = tempdir())

test_that("get_agfd, fixed = TRUE, cache = TRUE, works", {
  skip_if_offline()
  skip_on_ci()
  x <- get_agfd()

  agfd_nc_dir <- fs::path(
    .find_user_cache(),
    "historical_climate_prices_fixed"
  )

  nc_files <- function(agfd_nc_dir) {
    cli::cli_h1("Locally Available ABARES AGFD NetCDF Files")
    cli::cli_ul(basename(fs::dir_ls(agfd_nc_dir)))
    cli::cat_line()
  }
  print_out <- capture.output(nc_files)

  expect_s3_class(x, c("read.abares.agfd.nc.files", "character"))
  expect_identical(
    x |> capture_output(),
    nc_files(agfd_nc_dir) |>
      capture_output()
  )
  # cache fs::dir_created
  expect_true(fs::dir_exists(agfd_nc_dir))
})

test_that("get_agfd, fixed = FALSE, cache = TRUE, works", {
  skip_if_offline()
  skip_on_ci()
  x <- get_agfd(fixed_prices = FALSE)

  agfd_nc_dir <- fs::path(
    .find_user_cache(),
    "historical_climate_prices_fixed"
  )

  nc_files <- function(agfd_nc_dir) {
    cli::cli_h1("Locally Available ABARES AGFD NetCDF Files")
    cli::cli_ul(basename(fs::dir_ls(agfd_nc_dir)))
    cli::cat_line()
  }
  print_out <- capture.output(nc_files)

  expect_s3_class(x, c("read.abares.agfd.nc.files", "character"))
  expect_identical(
    x |> capture_output(),
    nc_files(agfd_nc_dir) |>
      capture_output()
  )
  # cache fs::dir_created
  expect_true(fs::dir_exists(agfd_nc_dir))

  expect_false(fs::file_exists(fs::path(.find_user_cache(), "agfd.zip")))
})

test_that("print.read.abares.agfd.nc.files returns a properly formatted list", {
  skip_if_offline()
  skip_on_ci()
  print_out <- function(x) {
    cli::cli_h1("Locally Available ABARES AGFD NetCDF Files")
    cli::cli_ul(basename(x))
    cli::cat_line()
  }

  x <- get_agfd(cache = TRUE)

  expect_identical(
    x |>
      capture.output(),
    print_out(x) |>
      capture_output()
  )
})

test_that("print_agfd_nc_files prints a proper message", {
  x <- function() {
    cli::cat_rule()
    cli::cli_text(
      "Each of the layers in simulation output data is represented as
  a 2D raster in NETCDF files, with the following grid format:"
    )
    cli::cat_line()
    cli::cli_dl(
      c(
        "{.strong CRS}" = "EPSG:4326 - WGS 84 - Geographic",
        "{.strong Extent}" = "111.975 -44.525 156.275 -9.975",
        "{.strong Unit}" = "Degrees",
        "{.strong Width}" = "886",
        "{.strong Height}" = "691",
        "{.strong Cell size}" = "0.05 degree x 0.05 degree"
      )
    )
    cli::cat_rule()
    cli::cli_text(
      "For further details, see the ABARES website,
                {.url https://www.agriculture.gov.au/abares/research-topics/surveys/farm-survey-data/australian-gridded-farm-data}"
    )
  }
  y <- print_agfd_nc_file_format()
  expect_identical(capture_output(y), capture_output(x))
})

clear_cache()

test_that("get_agfd, fixed = TRUE, cache = FALSE, works", {
  skip_on_ci()
  skip_if_offline()
  x <- get_agfd(cache = FALSE)

  agfd_nc_dir <- fs::path(
    tempdir(),
    "historical_climate_prices_fixed"
  )

  nc_files <- function(agfd_nc_dir) {
    cli::cli_h1("\nLocally Available ABARES AGFD NetCDF Files\n")
    cli::cli_ul(basename(fs::dir_ls(agfd_nc_dir)))
    cat("\n")
  }
  print_out <- capture.output(nc_files)

  expect_s3_class(x, c("read.abares.agfd.nc.files", "character"))
  expect_identical(
    x |> capture_output(),
    nc_files(agfd_nc_dir) |>
      capture_output()
  )
  # cache fs::dir_created
  expect_false(fs::dir_exists(fs::path(
    .find_user_cache(),
    "historical_climate_prices_fixed"
  )))
})

withr::deferred_run()
