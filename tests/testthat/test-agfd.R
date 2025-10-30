test_that(".get_agfd() returns a list object", {
  vcr::use_cassette("_get_agfd", {
    agfd <- .get_agfd(.fixed_prices = TRUE, .yyyy = 2020:2021)
  })
  expect_length(agfd, 2L)
  expect_type(agfd, "character")
})

test_that("read_agfd_dt returns a data.table object", {
  vcr::use_cassette("_get_agfd", {
    agfd <- read_agfd_dt(fixed_prices = TRUE, yyyy = 2020:2021)
  })
  expect_identical(nrow(agfd), 336654L)
  expect_identical(ncol(agfd), 44L)
  expect_s3_class(agfd, "data.table")
})


test_that("read_agfd_stars returns a list of stars objects", {
  vcr::use_cassette("_get_agfd", {
    agfd <- read_agfd_stars(fixed_prices = TRUE, yyyy = 2020:2021)
  })
  expect_length(agfd, 2L)
  expect_s3_class(agfd[[1]], "stars")
})
