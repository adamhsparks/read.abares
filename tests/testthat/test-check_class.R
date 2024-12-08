test_that("class checking works properly", {
  expect_error(.check_class(x = 1, "read.abares"),
    regexp = "You must provide a*"
  )
  expect_silent(.check_class(x = 1, "numeric"))
})
