test_that("read.abares_options retrieves only package-specific options", {
  # Set a mix of package and non-package options
  withr::local_options(list(
    read.abares.test_A = "A",
    read.abares.test_B = "B",
    other_package.option = "C"
  ))

  opts <- read.abares_options()

  # Check structure
  expect_type(opts, "list")

  # Should find our specific options
  expect_identical(opts$read.abares.test_A, "A")
  expect_identical(opts$read.abares.test_B, "B")

  # Should NOT find unrelated options
  expect_false("other_package.option" %in% names(opts))

  # Should match the grep logic (keys start with read.abares.)
  expect_true(all(grepl("^read\\.abares\\.", names(opts))))
})

test_that("read.abares_options sets options correctly", {
  # Capture original state to restore later (manual cleanup needed since we are testing the setter)
  old_val <- getOption("read.abares.verbosity")
  on.exit(options(read.abares.verbosity = old_val))

  # Set a new value
  read.abares_options(read.abares.verbosity = "quiet")

  # Verify it changed globally
  expect_identical(getOption("read.abares.verbosity"), "quiet")
})

test_that("read.abares_options sets multiple options at once", {
  # Save state
  old_v <- getOption("read.abares.verbosity")
  old_t <- getOption("read.abares.timeout")

  on.exit(options(
    read.abares.verbosity = old_v,
    read.abares.timeout = old_t
  ))

  # Set multiple
  read.abares_options(
    read.abares.verbosity = "minimal",
    read.abares.timeout = 999
  )

  expect_identical(getOption("read.abares.verbosity"), "minimal")
  expect_identical(getOption("read.abares.timeout"), 999)
})

test_that("read.abares_options returns old values when setting (standard R behavior)", {
  # Ensure we have a known starting state
  withr::local_options(list(read.abares.temp_test = "old_value"))

  # When options() is called to set a value, it returns a list of the OLD values.
  # read.abares_options simply passes this return value through.
  result <- read.abares_options(read.abares.temp_test = "new_value")

  expect_type(result, "list")
  expect_named(result, "read.abares.temp_test")
  expect_identical(result$read.abares.temp_test, "old_value")
})
