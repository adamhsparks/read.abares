test_that("verbosity option toggles .retry_download quiet (sanity)", {
  dest <- withr::local_tempfile()
  got <- new.env(parent = emptyenv())
  got$quiet <- NULL

  testthat::local_mocked_bindings(
    curl_download = function(url, destfile, quiet) {
      got$quiet <- quiet
      writeLines("ok", destfile)
      invisible(destfile)
    },
    .package = "curl"
  )

  withr::local_options(read.abares.verbosity = "minimal")
  expect_invisible(.retry_download("https://example/test.csv", dest))
  expect_false(got$quiet)

  withr::local_options(read.abares.verbosity = "verbose")
  expect_invisible(.retry_download("https://example/test.csv", dest))
  expect_true(got$quiet)
})
