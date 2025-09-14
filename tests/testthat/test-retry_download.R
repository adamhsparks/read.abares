test_that(".retry_download works with real download", {
  skip_if_offline()
  temp_file <- tempfile()
  url <- "https://httpbin.org/bytes/5" # small, safe test file

  options(read.abares.verbosity = "quiet")
  .retry_download(url, temp_file)

  expect_true(file.exists(temp_file))
  expect_equal(fs::file_info(temp_file)$size, 5L)
})
