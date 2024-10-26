test_that("get_agfd, fixed = TRUE works", {
  skip_if_offline()
  x <- get_agfd()

  agfd_nc_dir <- file.path(.find_user_cache(),
                           "historical_climate_prices_fixed")
  agfd_nc <- list.files(agfd_nc_dir, full.names = TRUE)

  nc_files <- function(agfd_nc_dir) {
    cli::cli_h1("\nLocally Available ABARES AGFD NetCDF Files\n")
    cli::cli_ul(basename(list.files(agfd_nc_dir)))
    cat("\n")
  }
  print_out <- capture.output(nc_files)

  expect_s3_class(x, c("read.abares.agfd.nc.files", "character"))
  expect_identical(x |> capture_output(),
                   nc_files(agfd_nc_dir) |>
                     capture_output())
  # cache dir created
  expect_true(dir.exists(
    file.path(.find_user_cache(), "historical_climate_prices_fixed")
  ))
})

test_that("get_agfd, fixed = FALSE works", {
  skip_if_offline()
  x <- get_agfd(fixed = FALSE)

  agfd_nc_dir <- file.path(.find_user_cache(),
                           "historical_climate_prices_fixed")
  agfd_nc <- list.files(agfd_nc_dir, full.names = TRUE)

  nc_files <- function(agfd_nc_dir) {
    cli::cli_h1("\nLocally Available ABARES AGFD NetCDF Files\n")
    cli::cli_ul(basename(list.files(agfd_nc_dir)))
    cat("\n")
  }
  print_out <- capture.output(nc_files)

  expect_s3_class(x, c("read.abares.agfd.nc.files", "character"))
  expect_identical(x |> capture_output(),
                   nc_files(agfd_nc_dir) |>
                     capture_output())
  # cache dir created
  expect_true(dir.exists(
    file.path(.find_user_cache(), "historical_climate_and_prices")
  ))
})


test_that("get_agfd() cleans up on its way out, caching", {
  skip_if_offline()
  x <- get_agfd()
  expect_false(file.exists(file.path(.find_user_cache(), "agfd.zip")))
})
