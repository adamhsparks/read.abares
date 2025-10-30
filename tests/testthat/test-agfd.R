test_that(".get_agfd() returns a list object", {
  vcr::use_cassette("_get_agfd", {
    agfd <- .get_agfd(.fixed_prices = TRUE, .yyyy = 2020:2021)
  })
  expect_length(agfd, 2L)
  expect_type(agfd, "character")
})
