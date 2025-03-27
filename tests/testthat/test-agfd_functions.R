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

# test read_agfd_dt() ------
test_that("read_agfd_dt returns a data.table object", {
  skip_if_offline()
  skip_on_ci()
  x <- get_agfd() |>
    read_agfd_dt()

  expect_s3_class(x, c("data.table", "data.frame"))
  expect_named(
    x,
    c(
      "id",
      "farmno",
      "R_total_hat_ha",
      "C_total_hat_ha",
      "FBP_fci_hat_ha",
      "FBP_fbp_hat_ha",
      "A_wheat_hat_ha",
      "H_wheat_dot_hat",
      "A_barley_hat_ha",
      "H_barley_dot_hat",
      "A_sorghum_hat_ha",
      "H_sorghum_dot_hat",
      "A_oilseeds_hat_ha",
      "H_oilseeds_dot_hat",
      "R_wheat_hat_ha",
      "R_sorghum_hat_ha",
      "R_oilseeds_hat_ha",
      "R_barley_hat_ha",
      "Q_wheat_hat_ha",
      "Q_barley_hat_ha",
      "Q_sorghum_hat_ha",
      "Q_oilseeds_hat_ha",
      "S_wheat_cl_hat_ha",
      "S_sheep_cl_hat_ha",
      "S_sheep_births_hat_ha",
      "S_sheep_deaths_hat_ha",
      "S_beef_cl_hat_ha",
      "S_beef_births_hat_ha",
      "S_beef_deaths_hat_ha",
      "Q_beef_hat_ha",
      "Q_sheep_hat_ha",
      "Q_lamb_hat_ha",
      "R_beef_hat_ha",
      "R_sheep_hat_ha",
      "R_lamb_hat_ha",
      "C_fodder_hat_ha",
      "C_fert_hat_ha",
      "C_fuel_hat_ha",
      "C_chem_hat_ha",
      "A_total_cropped_ha",
      "FBP_pfe_hat_ha",
      "farmland_per_cell",
      "lon",
      "lat"
    )
  )

  expect_identical(
    lapply(x, typeof),
    list(
      id = "character",
      farmno = "double",
      R_total_hat_ha = "double",
      C_total_hat_ha = "double",
      FBP_fci_hat_ha = "double",
      FBP_fbp_hat_ha = "double",
      A_wheat_hat_ha = "double",
      H_wheat_dot_hat = "double",
      A_barley_hat_ha = "double",
      H_barley_dot_hat = "double",
      A_sorghum_hat_ha = "double",
      H_sorghum_dot_hat = "double",
      A_oilseeds_hat_ha = "double",
      H_oilseeds_dot_hat = "double",
      R_wheat_hat_ha = "double",
      R_sorghum_hat_ha = "double",
      R_oilseeds_hat_ha = "double",
      R_barley_hat_ha = "double",
      Q_wheat_hat_ha = "double",
      Q_barley_hat_ha = "double",
      Q_sorghum_hat_ha = "double",
      Q_oilseeds_hat_ha = "double",
      S_wheat_cl_hat_ha = "double",
      S_sheep_cl_hat_ha = "double",
      S_sheep_births_hat_ha = "double",
      S_sheep_deaths_hat_ha = "double",
      S_beef_cl_hat_ha = "double",
      S_beef_births_hat_ha = "double",
      S_beef_deaths_hat_ha = "double",
      Q_beef_hat_ha = "double",
      Q_sheep_hat_ha = "double",
      Q_lamb_hat_ha = "double",
      R_beef_hat_ha = "double",
      R_sheep_hat_ha = "double",
      R_lamb_hat_ha = "double",
      C_fodder_hat_ha = "double",
      C_fert_hat_ha = "double",
      C_fuel_hat_ha = "double",
      C_chem_hat_ha = "double",
      A_total_cropped_ha = "double",
      FBP_pfe_hat_ha = "double",
      farmland_per_cell = "double",
      lon = "double",
      lat = "double"
    )
  )
})
test_that("read_agfd_dt() fails if the input is not a proper object", {
  expect_error(read_agfd_dt(list(fs::dir_ls(tempdir()))))
})

# test read_agfd_stars() ------

test_that("read_agfd_stars() returns a stars object", {
  skip_if_offline()
  skip_on_ci()
  x <- get_agfd() |>
    read_agfd_stars()

  expect_type(x, "list")
  expect_s3_class(x[[1]], "stars")
  expect_named(
    x,
    c(
      "f2022.c1991.p2022.t2022.nc",
      "f2022.c1992.p2022.t2022.nc",
      "f2022.c1993.p2022.t2022.nc",
      "f2022.c1994.p2022.t2022.nc",
      "f2022.c1995.p2022.t2022.nc",
      "f2022.c1996.p2022.t2022.nc",
      "f2022.c1997.p2022.t2022.nc",
      "f2022.c1998.p2022.t2022.nc",
      "f2022.c1999.p2022.t2022.nc",
      "f2022.c2000.p2022.t2022.nc",
      "f2022.c2001.p2022.t2022.nc",
      "f2022.c2002.p2022.t2022.nc",
      "f2022.c2003.p2022.t2022.nc",
      "f2022.c2004.p2022.t2022.nc",
      "f2022.c2005.p2022.t2022.nc",
      "f2022.c2006.p2022.t2022.nc",
      "f2022.c2007.p2022.t2022.nc",
      "f2022.c2008.p2022.t2022.nc",
      "f2022.c2009.p2022.t2022.nc",
      "f2022.c2010.p2022.t2022.nc",
      "f2022.c2011.p2022.t2022.nc",
      "f2022.c2012.p2022.t2022.nc",
      "f2022.c2013.p2022.t2022.nc",
      "f2022.c2014.p2022.t2022.nc",
      "f2022.c2015.p2022.t2022.nc",
      "f2022.c2016.p2022.t2022.nc",
      "f2022.c2017.p2022.t2022.nc",
      "f2022.c2018.p2022.t2022.nc",
      "f2022.c2019.p2022.t2022.nc",
      "f2022.c2020.p2022.t2022.nc",
      "f2022.c2021.p2022.t2022.nc",
      "f2022.c2022.p2022.t2022.nc",
      "f2022.c2023.p2022.t2022.nc"
    )
  )
  expect_named(
    x[[1]],
    c(
      "farmno",
      "R_total_hat_ha",
      "C_total_hat_ha",
      "FBP_fci_hat_ha",
      "FBP_fbp_hat_ha",
      "A_wheat_hat_ha",
      "H_wheat_dot_hat",
      "A_barley_hat_ha",
      "H_barley_dot_hat",
      "A_sorghum_hat_ha",
      "H_sorghum_dot_hat",
      "A_oilseeds_hat_ha",
      "H_oilseeds_dot_hat",
      "R_wheat_hat_ha",
      "R_sorghum_hat_ha",
      "R_oilseeds_hat_ha",
      "R_barley_hat_ha",
      "Q_wheat_hat_ha",
      "Q_barley_hat_ha",
      "Q_sorghum_hat_ha",
      "Q_oilseeds_hat_ha",
      "S_wheat_cl_hat_ha",
      "S_sheep_cl_hat_ha",
      "S_sheep_births_hat_ha",
      "S_sheep_deaths_hat_ha",
      "S_beef_cl_hat_ha",
      "S_beef_births_hat_ha",
      "S_beef_deaths_hat_ha",
      "Q_beef_hat_ha",
      "Q_sheep_hat_ha",
      "Q_lamb_hat_ha",
      "R_beef_hat_ha",
      "R_sheep_hat_ha",
      "R_lamb_hat_ha",
      "C_fodder_hat_ha",
      "C_fert_hat_ha",
      "C_fuel_hat_ha",
      "C_chem_hat_ha",
      "A_total_cropped_ha",
      "FBP_pfe_hat_ha",
      "farmland_per_cell"
    )
  )
})

test_that("read_agfd_stars() fails if the input is not a proper object", {
  expect_error(read_agfd_stars(list(fs::dir_ls(tempdir()))))
})

# test read_agfd_terra() -----

test_that("read_agfd_terra() returns a terra object", {
  skip_if_offline()
  skip_on_ci()
  x <- get_agfd() |>
    read_agfd_terra()

  expect_type(x, "list")
  expect_s4_class(x[[1]], "SpatRaster")
  expect_named(
    x,
    c(
      "f2022.c1991.p2022.t2022.nc",
      "f2022.c1992.p2022.t2022.nc",
      "f2022.c1993.p2022.t2022.nc",
      "f2022.c1994.p2022.t2022.nc",
      "f2022.c1995.p2022.t2022.nc",
      "f2022.c1996.p2022.t2022.nc",
      "f2022.c1997.p2022.t2022.nc",
      "f2022.c1998.p2022.t2022.nc",
      "f2022.c1999.p2022.t2022.nc",
      "f2022.c2000.p2022.t2022.nc",
      "f2022.c2001.p2022.t2022.nc",
      "f2022.c2002.p2022.t2022.nc",
      "f2022.c2003.p2022.t2022.nc",
      "f2022.c2004.p2022.t2022.nc",
      "f2022.c2005.p2022.t2022.nc",
      "f2022.c2006.p2022.t2022.nc",
      "f2022.c2007.p2022.t2022.nc",
      "f2022.c2008.p2022.t2022.nc",
      "f2022.c2009.p2022.t2022.nc",
      "f2022.c2010.p2022.t2022.nc",
      "f2022.c2011.p2022.t2022.nc",
      "f2022.c2012.p2022.t2022.nc",
      "f2022.c2013.p2022.t2022.nc",
      "f2022.c2014.p2022.t2022.nc",
      "f2022.c2015.p2022.t2022.nc",
      "f2022.c2016.p2022.t2022.nc",
      "f2022.c2017.p2022.t2022.nc",
      "f2022.c2018.p2022.t2022.nc",
      "f2022.c2019.p2022.t2022.nc",
      "f2022.c2020.p2022.t2022.nc",
      "f2022.c2021.p2022.t2022.nc",
      "f2022.c2022.p2022.t2022.nc",
      "f2022.c2023.p2022.t2022.nc"
    )
  )
  expect_named(
    x[[1]],
    c(
      "farmno",
      "R_total_hat_ha",
      "C_total_hat_ha",
      "FBP_fci_hat_ha",
      "FBP_fbp_hat_ha",
      "A_wheat_hat_ha",
      "H_wheat_dot_hat",
      "A_barley_hat_ha",
      "H_barley_dot_hat",
      "A_sorghum_hat_ha",
      "H_sorghum_dot_hat",
      "A_oilseeds_hat_ha",
      "H_oilseeds_dot_hat",
      "R_wheat_hat_ha",
      "R_sorghum_hat_ha",
      "R_oilseeds_hat_ha",
      "R_barley_hat_ha",
      "Q_wheat_hat_ha",
      "Q_barley_hat_ha",
      "Q_sorghum_hat_ha",
      "Q_oilseeds_hat_ha",
      "S_wheat_cl_hat_ha",
      "S_sheep_cl_hat_ha",
      "S_sheep_births_hat_ha",
      "S_sheep_deaths_hat_ha",
      "S_beef_cl_hat_ha",
      "S_beef_births_hat_ha",
      "S_beef_deaths_hat_ha",
      "Q_beef_hat_ha",
      "Q_sheep_hat_ha",
      "Q_lamb_hat_ha",
      "R_beef_hat_ha",
      "R_sheep_hat_ha",
      "R_lamb_hat_ha",
      "C_fodder_hat_ha",
      "C_fert_hat_ha",
      "C_fuel_hat_ha",
      "C_chem_hat_ha",
      "A_total_cropped_ha",
      "FBP_pfe_hat_ha",
      "farmland_per_cell"
    )
  )
})

test_that("read_agfd_terra() fails if the input is not a proper object", {
  expect_error(read_agfd_terra(list(fs::dir_ls(tempdir()))))
})


# test read_agfd_tidync() ------

test_that("read_agfd_tidync() returns a tidync object", {
  skip_if_offline()
  skip_on_ci()
  x <- get_agfd() |>
    read_agfd_tidync()

  expect_type(x, "list")
  expect_s3_class(x[[1]], "tidync")
  expect_named(
    x,
    c(
      "f2022.c1991.p2022.t2022.nc",
      "f2022.c1992.p2022.t2022.nc",
      "f2022.c1993.p2022.t2022.nc",
      "f2022.c1994.p2022.t2022.nc",
      "f2022.c1995.p2022.t2022.nc",
      "f2022.c1996.p2022.t2022.nc",
      "f2022.c1997.p2022.t2022.nc",
      "f2022.c1998.p2022.t2022.nc",
      "f2022.c1999.p2022.t2022.nc",
      "f2022.c2000.p2022.t2022.nc",
      "f2022.c2001.p2022.t2022.nc",
      "f2022.c2002.p2022.t2022.nc",
      "f2022.c2003.p2022.t2022.nc",
      "f2022.c2004.p2022.t2022.nc",
      "f2022.c2005.p2022.t2022.nc",
      "f2022.c2006.p2022.t2022.nc",
      "f2022.c2007.p2022.t2022.nc",
      "f2022.c2008.p2022.t2022.nc",
      "f2022.c2009.p2022.t2022.nc",
      "f2022.c2010.p2022.t2022.nc",
      "f2022.c2011.p2022.t2022.nc",
      "f2022.c2012.p2022.t2022.nc",
      "f2022.c2013.p2022.t2022.nc",
      "f2022.c2014.p2022.t2022.nc",
      "f2022.c2015.p2022.t2022.nc",
      "f2022.c2016.p2022.t2022.nc",
      "f2022.c2017.p2022.t2022.nc",
      "f2022.c2018.p2022.t2022.nc",
      "f2022.c2019.p2022.t2022.nc",
      "f2022.c2020.p2022.t2022.nc",
      "f2022.c2021.p2022.t2022.nc",
      "f2022.c2022.p2022.t2022.nc",
      "f2022.c2023.p2022.t2022.nc"
    )
  )
})

test_that("read_agfd_tidync() fails if the input is not a proper object", {
  expect_error(read_agfd_tidync(list(fs::dir_ls(tempdir()))))
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
