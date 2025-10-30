test_that(".get_agfd() returns a list object", {
  skip_if_offline()
  vcr::use_cassette("_get_agfd", {
    agfd <- .get_agfd(.fixed_prices = TRUE, .yyyy = 2020:2021)
  })

  expect_type(agfd, "list")
})
