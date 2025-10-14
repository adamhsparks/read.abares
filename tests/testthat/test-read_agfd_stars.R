test_that("read_agfd_stars validates yyyy bounds", {
  expect_error(
    read.abares::read_agfd_stars(yyyy = c(1990, 1991)),
    "must be between 1991 and 2023 inclusive"
  )
  expect_error(
    read.abares::read_agfd_stars(yyyy = c(2023, 2024)),
    "must be between 1991 and 2023 inclusive"
  )
})

test_that("read_agfd_stars integrates: calls .get_agfd, passes var, returns named list of stars (fixed prices)", {
  skip_if_offline()

  files <- file.path(tempdir(), c("x_c2020.nc", "x_c2021.nc"))

  # Expected var vector as defined inside read_agfd_stars()
  expected_var <- c(
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

  # Counter to ensure read_ncdf is called once per file
  calls <- 0L

  # Mock stars::read_ncdf to:
  #  - assert 'var' is passed correctly
  #  - return a lightweight object with class 'stars'
  with_mocked_bindings(
    read_ncdf = function(filename, var) {
      calls <<- calls + 1L
      expect_true(filename %in% files)
      expect_setequal(var, expected_var)
      structure(
        list(filename = filename, var = var),
        class = "stars"
      )
    },
    {
      # Mock .get_agfd in read.abares to return our files
      with_mocked_bindings(
        .get_agfd = function(.fixed_prices, .yyyy, .x) {
          expect_true(.fixed_prices)
          expect_identical(.yyyy, 2020:2021)
          expect_null(.x)
          files
        },
        {
          s <- read.abares::read_agfd_stars(
            fixed_prices = TRUE,
            yyyy = 2020:2021,
            x = NULL
          )

          # Structure: named list of length = number of files
          expect_type(s, "list")
          expect_length(s, length(files))
          expect_setequal(names(s), basename(files))

          # Elements should be 'stars' (from our mock) and carry the filenames we returned
          expect_true(all(vapply(s, inherits, logical(1), "stars")))
          expect_setequal(
            vapply(s, function(e) e$filename, character(1)),
            files
          )

          # read_ncdf should be called once per file (first normally, rest via quietly)
          expect_length(files, calls)
        },
        .package = "read.abares"
      )
    },
    .package = "stars"
  )
})

test_that("read_agfd_stars forwards fixed_prices = FALSE to .get_agfd (historical prices path)", {
  skip_if_offline()

  files <- file.path(tempdir(), c("y_c1995.nc", "y_c1996.nc"))

  calls <- 0L

  with_mocked_bindings(
    read_ncdf = function(filename, var) {
      calls <<- calls + 1L
      structure(list(filename = filename, var = var), class = "stars")
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
          s <- read.abares::read_agfd_stars(
            fixed_prices = FALSE,
            yyyy = 1995:1996,
            x = NULL
          )

          expect_type(s, "list")
          expect_length(s, length(files))
          expect_setequal(names(s), basename(files))
          expect_true(all(vapply(s, inherits, logical(1), "stars")))
          expect_length(files, calls)
        },
        .package = "read.abares"
      )
    },
    .package = "stars"
  )
})

test_that("read_agfd_stars forwards x to .get_agfd", {
  skip_if_offline()

  fake_zip <- file.path(tempdir(), "some_agfd.zip")
  files <- file.path(tempdir(), "z_c2022.nc")

  with_mocked_bindings(
    read_ncdf = function(filename, var) {
      structure(list(filename = filename, var = var), class = "stars")
    },
    {
      with_mocked_bindings(
        .get_agfd = function(.fixed_prices, .yyyy, .x) {
          expect_true(.fixed_prices)
          expect_identical(.yyyy, 2022)
          expect_identical(.x, fake_zip)
          files
        },
        {
          s <- read.abares::read_agfd_stars(
            fixed_prices = TRUE,
            yyyy = 2022,
            x = fake_zip
          )

          expect_type(s, "list")
          expect_length(s, 1L)
          expect_named(s, basename(files))
          expect_true(inherits(s[[1]], "stars"))
          expect_identical(s[[1]]$filename, files)
        },
        .package = "read.abares"
      )
    },
    .package = "stars"
  )
})

test_that("read_agfd_stars errors when .get_agfd returns no files (document current behavior)", {
  skip_if_offline()

  # When .get_agfd returns character(0), the function tries to access files[1L],
  # leading to an error. We document this current behavior here.
  with_mocked_bindings(
    .get_agfd = function(...) character(),
    {
      expect_error(
        read.abares::read_agfd_stars(
          fixed_prices = TRUE,
          yyyy = 2022,
          x = NULL
        )
      )
    },
    .package = "read.abares"
  )
})
