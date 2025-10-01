testthat::test_that("read.abares_options() returns current read.abares.* options", {
  testthat::skip_on_cran()

  # Ensure a clean baseline
  withr::local_options(list(
    read.abares.quiet = FALSE,
    read.abares.verbose = TRUE
  ))

  opts <- read.abares_options()
  testthat::expect_type(opts, "list")
  testthat::expect_true(all(grepl("^read\\.abares\\.", names(opts))))
  testthat::expect_false(opts$read.abares.quiet)
  testthat::expect_true(opts$read.abares.verbose)
})

testthat::test_that("read.abares_options() sets a single option and persists", {
  testthat::skip_on_cran()

  withr::local_options(list(read.abares.quiet = FALSE))

  # Set to TRUE
  read.abares_options(read.abares.quiet = TRUE)
  testthat::expect_true(getOption("read.abares.quiet"))

  # Confirm function returns updated value
  opts <- read.abares_options()
  testthat::expect_true(opts$read.abares.quiet)
})

testthat::test_that("read.abares_options() sets multiple options at once", {
  testthat::skip_on_cran()

  withr::local_options(list(
    read.abares.quiet = FALSE,
    read.abares.verbose = FALSE
  ))

  read.abares_options(read.abares.quiet = TRUE, read.abares.verbose = TRUE)

  testthat::expect_true(getOption("read.abares.quiet"))
  testthat::expect_true(getOption("read.abares.verbose"))

  opts <- read.abares_options()
  testthat::expect_true(opts$read.abares.quiet)
  testthat::expect_true(opts$read.abares.verbose)
})

testthat::test_that("read.abares_options() does not affect unrelated options", {
  testthat::skip_on_cran()

  withr::local_options(list(
    custom.option = "keepme",
    read.abares.quiet = FALSE
  ))

  read.abares_options(read.abares.quiet = TRUE)

  testthat::expect_identical(getOption("custom.option"), "keepme")
})

testthat::test_that("read.abares_options() snapshot of selected options", {
  testthat::skip_on_cran()

  # Keep snapshot output stable across environments
  testthat::local_reproducible_output(width = 80L)

  # Set deterministic option values for the snapshot
  withr::local_options(list(
    read.abares.quiet = TRUE,
    read.abares.verbose = FALSE
  ))

  # Only snapshot the keys we care about (stable and deterministic)
  opts <- read.abares_options()
  sel <- opts[c("read.abares.quiet", "read.abares.verbose")]
  sel <- sel[order(names(sel))]

  testthat::expect_snapshot_value(sel, style = "json2")
})
