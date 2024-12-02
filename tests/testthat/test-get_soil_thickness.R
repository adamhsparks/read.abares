
# There are two files for this function due to caching tests

# sets up a custom cache environment in `tempdir()` just for testing
withr::local_envvar(R_USER_CACHE_DIR = file.path(tempdir(), "abares.cache.1"))

# without caching enabled ----

test_that("get_soil_thickness doesn't cache", {
  skip_if_offline()
  skip_on_ci()
  x <- get_soil_thickness(cache = FALSE)
  expect_s3_class(x, c("read.abares.soil.thickness", "list"))
  expect_false(dir.exists(file.path(
    .find_user_cache(), "soil_thickness_dir"
  )))
})

withr::deferred_run()

# with caching enabled after is was not initially enabled ----

withr::local_envvar(R_USER_CACHE_DIR = file.path(tempdir(), "abares.cache.2"))

test_that("get_soil_thickness caches", {
  skip_if_offline()
  skip_on_ci()
  x <- get_soil_thickness(cache = TRUE)
  expect_s3_class(x, c("read.abares.soil.thickness", "list"))
  expect_true(file.exists(file.path(
    .find_user_cache(), "soil_thickness_dir"
  )))
})

test_that("get_soil_thickness does cache", {
  skip_if_offline()
  skip_on_ci()
  x <- get_soil_thickness(cache = TRUE)
  expect_s3_class(x, c("read.abares.soil.thickness", "list"))
  expect_true(file.exists(file.path(
    .find_user_cache(), "soil_thickness_dir"
  )))
  expect_true(dir.exists(file.path(
    .find_user_cache(), "soil_thickness_dir"
  )))
})

test_that("print.read.abares.thickness.files prints metadata", {
  skip_if_offline()
  skip_on_ci()
  out_text <- function() {
    cli::cli_h1(
      "Soil Thickness for Australian areas of intensive agriculture of Layer 1 (A Horizon - top-soil)"
    )
    cli::cli_h2("Dataset ANZLIC ID ANZCW1202000149")
    cli::cli_text(
      "Feature attribute definition Predicted average Thickness (mm) of soil layer
    1 in the 0.01 X 0.01 degree quadrat.\n\n
    {.strong Custodian:} CSIRO Land & Water\n\n
    {.strong Jurisdiction} Australia\n\n
    {.strong Short Description} The digital map data is provided in geographical
    coordinates based on the World Geodetic System 1984 (WGS84) datum. This
    raster data set has a grid resolution of 0.001 degrees  (approximately
    equivalent to 1.1 km).\n\n
    The data set is a product of the National Land and Water Resources Audit
    (NLWRA) as a base dataset.\n\n
    {.strong Data Type:} Spatial representation type RASTER\n\n
    {.strong Projection Map:} projection GEOGRAPHIC\n\n
    {.strong Datum:} WGS84\n\n
    {.strong Map Units:} DECIMAL DEGREES\n\n
    {.strong Scale:} Scale/ resolution 1:1 000 000\n\n
    Usage Purpose Estimates of soil depths are needed to calculate the amount of
    any soil constituent in either volume or mass terms (bulk density is also
    needed) - for example, the volume of water stored in the rooting zone
    potentially available for plant use, to assess total stores of soil carbon
    for greenhouse inventory or to assess total stores of nutrients.\n\n
    Provide indications of probable thickness soil layer 1 in agricultural areas
    where soil thickness testing has not been carried out.\n\n
    Use Limitation: This dataset is bound by the requirements set down by the
    National Land & Water Resources Audit"
    )
    cli::cli_text("To see the full metadata, call
    {.fn print_soil_thickness_metadata} on a soil thickness object in your R
                session.")
    cat("\n")
  }
  print_out <- capture.output(out_text())

  x <- get_soil_thickness(cache = TRUE)
  expect_identical(x |>  capture.output(), print_out)
})

test_that("print_soil_thickness_metadata prints full metadata", {
  skip_if_offline()
  skip_on_ci()
  out_text <- function(x) {
    loc <- stringr::str_locate(x$metadata, "Custodian")
    metadata <- stringr::str_sub(x$metadata, loc[, "start"] - 1, nchar(x$metadata))
    cli::cli_h1(
      "Soil Thickness for Australian areas of intensive agriculture of Layer 1 (A Horizon - top-soil)\n"
    )
    cli::cli_h2("Dataset ANZLIC ID ANZCW1202000149")
    cli::cli_text(x$metadata)
    cat("\n")
  }

  x <- get_soil_thickness(cache = TRUE)
  print_out <- capture.output(out_text(x))

  expect_identical(print_soil_thickness_metadata(x) |>
                     capture.output(),
                   print_out)
})

withr::deferred_run()
