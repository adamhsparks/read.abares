## -----------------------------
## Tests for .map_verbosity
test_that(".map_verbosity maps quiet correctly", {
  res <- .map_verbosity("quiet")
  expect_identical(res$rlib_message_verbosity, "quiet")
  expect_identical(res$rlib_warning_verbosity, "quiet")
  expect_identical(res$warn, -1L)
  expect_false(res$datatable.showProgress)
})

test_that(".map_verbosity maps minimal correctly", {
  res <- .map_verbosity("minimal")
  expect_identical(res$rlib_message_verbosity, "minimal")
  expect_identical(res$rlib_warning_verbosity, "verbose")
  expect_identical(res$warn, 0L)
  expect_false(res$datatable.showProgress)
})

test_that(".map_verbosity maps verbose correctly", {
  res <- .map_verbosity("verbose")
  expect_identical(res$rlib_message_verbosity, "verbose")
  expect_identical(res$rlib_warning_verbosity, "verbose")
  expect_identical(res$warn, 0L)
  expect_true(res$datatable.showProgress)
})

test_that(".map_verbosity defaults to verbose for invalid input", {
  res <- .map_verbosity("invalid")
  expect_identical(res$rlib_message_verbosity, "verbose")
  expect_identical(res$rlib_warning_verbosity, "verbose")
  expect_identical(res$warn, 0L)
  expect_true(res$datatable.showProgress)
})

test_that(".map_verbosity defaults to verbose when NULL", {
  res <- .map_verbosity(NULL)
  expect_identical(res$rlib_message_verbosity, "verbose")
})

## -----------------------------
## Tests for .init_read_abares_options
##

test_that(".init_read_abares_options sets default options", {
  # Clear any existing options
  withr::with_options(
    list(
      read.abares.timeout = NULL,
      read.abares.timeout_connect = NULL,
      read.abares.max_tries = NULL,
      read.abares.verbosity = NULL
    ),
    {
      .init_read_abares_options()
      expect_identical(getOption("read.abares.timeout"), 5000L)
      expect_identical(getOption("read.abares.timeout_connect"), 20L)
      expect_identical(getOption("read.abares.max_tries"), 3L)
      expect_identical(getOption("read.abares.verbosity"), "verbose")
      expect_identical(getOption("rlib_message_verbosity"), "verbose")
      expect_identical(getOption("rlib_warning_verbosity"), "verbose")
      expect_identical(getOption("warn"), 0L)
      expect_true(getOption("datatable.showProgress"))
    }
  )
})

test_that(".init_read_abares_options assigns .read.abares_env", {
  .init_read_abares_options()
  ns <- asNamespace("read.abares")
  expect_true(exists(".read.abares_env", envir = ns, inherits = FALSE))
  env <- get(".read.abares_env", envir = ns)
  expect_true("old_options" %in% names(env))
})
