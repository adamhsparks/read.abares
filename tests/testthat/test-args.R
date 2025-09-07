test_that("argument validation protects inputs", {
  expect_error(get_abares_trade_regions(level = "bogus"), "level")
  expect_error(get_estimates_by_performance_category(year = "202X"), "year")
  expect_error(get_aagis_regions(class = "sp"), "class|unsupported")
})
