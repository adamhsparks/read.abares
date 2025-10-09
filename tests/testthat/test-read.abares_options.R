test_that("read.abares_options() returns current read.abares.* options", {
  skip_if_offline()

  # Ensure a clean baseline
  withr::local_options(list(
    read.abares.quiet = FALSE,
    read.abares.verbose = TRUE
  ))

  opts <- read.abares_options()
  expect_type(opts, "list")
  expect_true(all(grepl("^read\\.abares\\.", names(opts))))
  expect_false(opts$read.abares.quiet)
  expect_true(opts$read.abares.verbose)
})

test_that("read.abares_options() sets a single option and persists", {
  skip_if_offline()

  withr::local_options(list(read.abares.quiet = FALSE))

  # Set to TRUE
  read.abares_options(read.abares.quiet = TRUE)
  expect_true(getOption("read.abares.quiet"))

  # Confirm function returns updated value
  opts <- read.abares_options()
  expect_true(opts$read.abares.quiet)
})

test_that("read.abares_options() sets multiple options at once", {
  skip_if_offline()

  withr::local_options(list(
    read.abares.quiet = FALSE,
    read.abares.verbose = FALSE
  ))

  read.abares_options(read.abares.quiet = TRUE, read.abares.verbose = TRUE)

  expect_true(getOption("read.abares.quiet"))
  expect_true(getOption("read.abares.verbose"))

  opts <- read.abares_options()
  expect_true(opts$read.abares.quiet)
  expect_true(opts$read.abares.verbose)
})

test_that("read.abares_options() does not affect unrelated options", {
  skip_if_offline()

  withr::local_options(list(
    custom.option = "keepme",
    read.abares.quiet = FALSE
  ))

  read.abares_options(read.abares.quiet = TRUE)

  expect_identical(getOption("custom.option"), "keepme")
})

test_that("read.abares_options() snapshot of selected options", {
  skip_if_offline()

  # Keep snapshot output stable across environments
  local_reproducible_output(width = 80L)

  # Set deterministic option values for the snapshot
  withr::local_options(list(
    read.abares.quiet = TRUE,
    read.abares.verbose = FALSE
  ))

  # Only snapshot the keys we care about (stable and deterministic)
  opts <- read.abares_options()
  sel <- opts[c("read.abares.quiet", "read.abares.verbose")]
  sel <- sel[order(names(sel))]

  expect_snapshot_value(sel, style = "json2")
})
