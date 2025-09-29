test_that("retry_download succeeds with mocked download", {
  skip_on_cran()

  temp_file <- withr::local_tempfile(fileext = ".csv")
  withr::defer({
    if (fs::file_exists(temp_file)) fs::file_delete(temp_file)
  })

  httptest2::with_mock_dir("_mock/download-success", {
    expect_invisible(.retry_download(
      url = "https://httpbin.org/bytes/5", # small, safe test file
      .f = temp_file
    ))
  })

  expect_true(fs::file_exists(temp_file))
})

test_that("retry_download retries and fails with mocked errors", {
  skip_on_cran()
  skip_on_covr()

  temp_file <- withr::local_tempfile(fileext = ".csv")
  withr::defer({
    if (fs::file_exists(temp_file)) fs::file_delete(temp_file)
  })

  httptest2::with_mock_dir("_mock/download-fail", {
    withr::with_options(
      list(read.abares.max_tries = 2L),
      expect_error(
        .retry_download(
          url = "https://example.com/fail.csv",
          .f = temp_file
        ),
        "All download attempts failed."
      )
    )
  })
  expect_false(fs::file_exists(temp_file))
})
