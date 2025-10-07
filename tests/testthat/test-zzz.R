test_that("%||% returns left-hand side when not NULL", {
  expect_equal("value" %||% "fallback", "value")
  expect_equal(0 %||% 1, 0)
  expect_equal(FALSE %||% TRUE, FALSE)
})

test_that("%||% returns right-hand side when left is NULL", {
  expect_equal(NULL %||% "fallback", "fallback")
  expect_equal(NULL %||% 123, 123)
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

  # Snapshot the relevant options
  opts <- options()[c(
    "read.abares.user_agent",
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
