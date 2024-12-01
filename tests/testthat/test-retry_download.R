
mock_dir("test_retry_download", {
  test_that(".retry_download works properly", {
    skip_if_offline()
    f <- file.path(tempdir(), "logo.svg")
    url <- "https://raw.githubusercontent.com/adamhsparks/read.abares/refs/heads/main/inst/logo.svg"
    expect_no_condition(.retry_download(url = url, .f = f))
    expect_no_condition(file.exists(f))
  })
})

without_internet({
  test_that(".retry_download provides an error if no connection", {
    f <- file.path(tempdir(), "logo.svg")
    url <- "https://raw.githubusercontent.com/adamhsparks/read.abares/refs/heads/main/inst/logo.svg"
    expect_error(.retry_download(url = url, .f = f, .max_tries = 2L),
                 regexp = "Download failed after 2 attempts.")
    expect_no_condition(file.exists(f))
  })
})
