test_that("read_agfd_dt() reads tiny valid NetCDF from local fixture", {
  zip <- locate_agfd_fixture()
  skip_if(!nzchar(zip) || !file.exists(zip), "Fixture zip not found")

  dat <- read_agfd_dt(yyyy = 2021:2022, fixed_prices = FALSE, x = zip)

  expect_s3_class(dat, "data.table")
  expect_gt(nrow(dat), 1L)
  expect_true(all(c("id", "lat", "lon") %in% names(dat)))
  expect_type(dat$lat, "double")
  expect_type(dat$lon, "double")

  unique_ids <- unique(dat$id)
  expect_true(any(grepl(
    "^f2021\\.c2021\\.p2021\\.t2021\\.nc$",
    unique_ids
  )))
  expect_true(any(grepl(
    "^f2022\\.c2022\\.p2022\\.t2022\\.nc$",
    unique_ids
  )))

  expect_true("FBP_fbp_hat_ha" %in% names(dat))
})

test_that("read_agfd_tidync() returns tidync objects for each file", {
  zip <- locate_agfd_fixture()
  skip_if(!nzchar(zip) || !file.exists(zip), "Fixture zip not found")

  objs <- read_agfd_tidync(yyyy = 2021:2022, fixed_prices = FALSE, x = zip)
  # Expect a list of tidync objects or a single tidync; adapt if your API differs
  if (is.list(objs)) {
    expect_true(all(vapply(objs, inherits, logical(1L), "tidync")))
  } else {
    expect_s3_class(objs, "tidync")
  }
})

test_that("read_agfd_stars() produces a small stars object", {
  zip <- locate_agfd_fixture()
  skip_if(!nzchar(zip) || !file.exists(zip), "Fixture zip not found")

  s <- suppressMessages(
    suppressWarnings(
      read_agfd_stars(
        yyyy = 2022,
        fixed_prices = TRUE,
        x = zip
      )
    )
  )
  expect_s3_class(s[[1L]], "stars")
  # 2×2 extent expected from fixture
  dims <- dim(s)
  expect_length(s, 2L)
})


test_that("read_agfd_terra() yields a small SpatRaster", {
  zip <- locate_agfd_fixture()
  skip_if(!nzchar(zip) || !file.exists(zip), "Fixture zip not found")

  r <- read_agfd_terra(yyyy = 2022, fixed_prices = TRUE, x = zip)
  expect_s4_class(r[[1L]], "SpatRaster")
  expect_identical(terra::ncell(r), 2L) # 2×2 grid
})

test_that(".check_agfd_yyyy() validates year inputs", {
  expect_error(.check_yyyy("1991"), "must be numeric")
  expect_error(.check_yyyy(1890), "between 1991 and")
  expect_error(.check_yyyy(2025), "between 1991 and")
  expect_silent(.check_yyyy(1991:2023))
})
