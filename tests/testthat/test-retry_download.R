library(withr)
library(fs)
library(httptest2)

test_that("retry_download succeeds with mocked download", {
  skip_on_cran()

  temp_file <- local_tempfile(fileext = ".csv")
  defer({
    if (file_exists(temp_file)) file_delete(temp_file)
  })

  with_mock_dir("_mock/download-success", {
    expect_invisible(.retry_download(
      url = "https://httpbin.org/bytes/5", # small, safe test file
      .f = temp_file
    ))
  })

  expect_true(file_exists(temp_file))
})

test_that("retry_download retries and fails with mocked errors", {
  skip_on_cran()
  skip_on_covr()

  temp_file <- local_tempfile(fileext = ".csv")
  defer({
    if (file_exists(temp_file)) file_delete(temp_file)
  })

  with_mock_dir("_mock/download-fail", {
    with_options(
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

  expect_false(file_exists(temp_file))
})
