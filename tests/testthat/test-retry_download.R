# tests/testthat/test-retry_download.R

test_that(".retry_download writes a file and passes expected args", {
  dest <- withr::local_tempfile()
  wrote <- new.env(parent = emptyenv())
  wrote$url <- wrote$dest <- wrote$quiet <- NULL

  testthat::local_mocked_bindings(
    curl_download = function(url, destfile, quiet) {
      wrote$url <- url
      wrote$dest <- destfile
      wrote$quiet <- quiet
      writeLines("ok", destfile)
      invisible(destfile)
    },
    .package = "curl"
  )

  withr::local_options(read.abares.verbosity = NULL) # => quiet = TRUE
  expect_invisible(.retry_download("https://example.com/a.csv", dest))
  expect_true(file.exists(dest))
  expect_identical(readLines(dest), "ok")
  expect_identical(wrote$url, "https://example.com/a.csv")
  expect_identical(wrote$dest, dest)

  # Some environments may yield length-0 logical for quiet when option is NULL.
  # Treat that as TRUE (default quiet).
  opt <- getOption("read.abares.verbosity")
  expected_quiet <- if (is.null(opt)) TRUE else
    !(opt %in% c("quiet", "minimal"))
  expect_true(
    identical(wrote$quiet, expected_quiet) ||
      (is.null(opt) && length(wrote$quiet) == 0L)
  )
})

test_that(".retry_download quiet flag obeys read.abares.verbosity", {
  dest <- withr::local_tempfile()
  probe <- new.env(parent = emptyenv())
  probe$quiet <- NULL

  testthat::local_mocked_bindings(
    curl_download = function(url, destfile, quiet) {
      probe$quiet <- quiet
      writeLines("x", destfile)
      invisible(destfile)
    },
    .package = "curl"
  )

  withr::local_options(read.abares.verbosity = "quiet")
  expect_invisible(.retry_download("https://example.com/a", dest))
  expect_identical(probe$quiet, FALSE)

  withr::local_options(read.abares.verbosity = "minimal")
  expect_invisible(.retry_download("https://example.com/b", dest))
  expect_identical(probe$quiet, FALSE)

  withr::local_options(read.abares.verbosity = "verbose")
  expect_invisible(.retry_download("https://example.com/c", dest))
  expect_identical(probe$quiet, TRUE)
})

test_that(".retry_download propagates errors from curl", {
  dest <- withr::local_tempfile()
  testthat::local_mocked_bindings(
    curl_download = function(...) stop("curl failure"),
    .package = "curl"
  )
  expect_error(.retry_download("https://example.com/bad", dest), "curl failure")
})
