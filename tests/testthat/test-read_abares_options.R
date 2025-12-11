test_that("read.abares_options returns all read.abares.* options when called with no args", {
  # Set some known options
  old <- options(
    read.abares.timeout = 123L,
    read.abares.verbosity = "quiet"
  )
  on.exit(options(old), add = TRUE)

  res <- read.abares_options()
  # Should be a named list of options starting with "read.abares."
  expect_type(res, "list")
  expect_true(all(grepl("^read.abares\\.", names(res))))
  expect_equal(res$read.abares.timeout, 123L)
  expect_equal(res$read.abares.verbosity, "quiet")
})

test_that("read.abares_options sets options when called with args", {
  old <- options(read.abares.timeout = 5000L)
  on.exit(options(old), add = TRUE)

  # Change the option
  read.abares_options(read.abares.timeout = 42L)
  expect_equal(getOption("read.abares.timeout"), 42L)

  # Change multiple options
  read.abares_options(
    read.abares.timeout = 99L,
    read.abares.verbosity = "minimal"
  )
  expect_equal(getOption("read.abares.timeout"), 99L)
  expect_equal(getOption("read.abares.verbosity"), "minimal")
})

test_that("read.abares_options returns invisibly when setting options", {
  val <- read.abares_options(read.abares.timeout = 77L)
  # options() returns the previous values invisibly
  expect_true(is.list(val))
  expect_true("read.abares.timeout" %in% names(val))
})
