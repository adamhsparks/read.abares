
with_mock_dir("test_retry_download", {
  test_that(".retry_download works properly", {
    f <- file.path(tempdir(), "CITATION")
    url <- "https://raw.githubusercontent.com/adamhsparks/read.abares/refs/heads/main/inst/CITATION"
    .retry_download(url = url, .f = f)
    expect_no_condition(file.exists(f))
  })
})

without_internet({
  test_that(".retry_download provides an error if no connection", {
    f <- file.path(tempdir(), "CITATION")
    url <- "https://raw.githubusercontent.com/adamhsparks/read.abares/refs/heads/main/inst/CITATION"
    expect_error(.retry_download(url = url, .f = f, .max_tries = 2L),
                 regexp = "There was an error with this download, please retry.")
    expect_no_condition(file.exists(f))
  })
})
