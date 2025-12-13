test_that(".map_verbosity maps inputs correctly", {
  # Test "quiet"
  quiet <- .map_verbosity("quiet")
  expect_equal(quiet$rlib_message_verbosity, "quiet")
  expect_equal(quiet$warn, -1L)
  expect_false(quiet$datatable.showProgress)

  # Test "minimal"
  minimal <- .map_verbosity("minimal")
  expect_equal(minimal$rlib_message_verbosity, "minimal")
  expect_equal(minimal$warn, 0L)
  expect_false(minimal$datatable.showProgress)

  # Test "verbose"
  verbose <- .map_verbosity("verbose")
  expect_equal(verbose$rlib_message_verbosity, "verbose")
  expect_equal(verbose$warn, 0L)
  expect_true(verbose$datatable.showProgress)
})

test_that(".map_verbosity handles garbage inputs gracefully", {
  # Should default to verbose behavior for safety

  # NULL
  res <- .map_verbosity(NULL)
  expect_equal(res$rlib_message_verbosity, "verbose")
  expect_true(res$datatable.showProgress)

  # Invalid string
  res <- .map_verbosity("super_loud_mode")
  expect_equal(res$rlib_message_verbosity, "verbose")

  # NA
  res <- .map_verbosity(NA)
  expect_equal(res$rlib_message_verbosity, "verbose")
})
