test_that("%||% returns left-hand side when not NULL", {
  expect_identical("value" %||% "fallback", "value")
  expect_identical(0 %||% 1, 0)
  expect_false(FALSE %||% TRUE)
})

test_that("%||% returns right-hand side when left is NULL", {
  expect_identical(NULL %||% "fallback", "fallback")
  expect_identical(NULL %||% 123, 123)
})

test_that(".map_verbosity returns correct mappings for 'quiet'", {
  expect_snapshot(.map_verbosity("quiet"))
})

test_that(".map_verbosity returns correct mappings for 'minimal'", {
  expect_snapshot(.map_verbosity("minimal"))
})

test_that(".map_verbosity returns correct mappings for 'verbose'", {
  expect_snapshot(.map_verbosity("verbose"))
})

test_that(".map_verbosity defaults to 'verbose' for unknown input", {
  expect_snapshot(.map_verbosity("loud"))
})

test_that(".map_verbosity handles NULL input", {
  expect_snapshot(.map_verbosity(NULL))
})

test_that(".onUnload runs deferred cleanup without error", {
  expect_invisible(.onUnload(libpath = NULL))
})

test_that(".init_read_abares_options sets expected options", {
  skip_if_offline()
  local_reproducible_output()

  # Save current options
  old_opts <- options()

  # Run the init logic
  expect_invisible(.init_read_abares_options())

  # Snapshot the relevant options (useragent is not relevant here as it's
  # different on CI and so a snapshot won't work)
  opts <- options()[c(
    "read.abares.timeout",
    "read.abares.max_tries",
    "read.abares.verbosity",
    "rlib_message_verbosity",
    "rlib_warning_verbosity",
    "warn",
    "datatable.showProgress"
  )]
  expect_snapshot(opts)

  # Restore original options
  options(old_opts)
})
