test_that(".get_agfd() returns a vector object for fixed prices", {
  vcr::use_cassette("_get_agfd_fixed_prices", {
    agfd <- .get_agfd(.fixed_prices = TRUE, .yyyy = 2020:2021)
  })
  expect_length(agfd, 2L)
  expect_type(agfd, "character")
})

test_that("read_agfd_dt returns a data.table object", {
  vcr::use_cassette("_get_agfd_fixed_prices", {
    agfd <- read_agfd_dt(fixed_prices = TRUE, yyyy = 2020:2021)
  })
  expect_identical(nrow(agfd), 336654L)
  expect_identical(ncol(agfd), 44L)
  expect_s3_class(agfd, "data.table")
})

test_that("read_agfd_stars returns a vector of stars objects", {
  vcr::use_cassette("_get_agfd_fixed_prices", {
    agfd <- read_agfd_stars(fixed_prices = TRUE, yyyy = 2020:2021)
  })
  expect_length(agfd, 2L)
  expect_s3_class(agfd[[1L]], "stars")
})

test_that("read_agfd_terra returns a vector of terra objects", {
  vcr::use_cassette("_get_agfd_fixed_prices", {
    agfd <- read_agfd_terra(fixed_prices = TRUE, yyyy = 2020:2021)
  })
  expect_length(agfd, 2L)
  expect_s4_class(agfd[[1L]], "SpatRaster")
})

test_that("read_agfd_tidync returns a vector of tidync objects", {
  vcr::use_cassette("_get_agfd_fixed_prices", {
    agfd <- read_agfd_tidync(fixed_prices = TRUE, yyyy = 2020:2021)
  })
  expect_length(agfd, 2L)
  expect_s3_class(agfd[[1L]], "tidync")
})

test_that(".get_agfd() returns a vector object for nonfixed prices", {
  vcr::use_cassette("_get_agfd_nonfixed_prices", {
    agfd <- .get_agfd(.fixed_prices = FALSE, .yyyy = 2020:2021)
  })
  expect_length(agfd, 2L)
  expect_type(agfd, "character")
})
