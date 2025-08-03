test_that("read.abares creates a proper useragent", {
  expect_identical(
    readabares_user_agent(),
    "read.abares R package 2.0.0 DEV https://github.com/adamhsparks/read.abares"
  )
})
