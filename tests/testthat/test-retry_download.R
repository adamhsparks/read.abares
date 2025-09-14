test_that(".retry_download sets quiet correctly based on verbosity", {
  temp_file <- tempfile()
  test_url <- "https://example.com/data.csv"

  verbosity_levels <- c("quiet", "minimal", "verbose", "debug", "silent")

  for (verbosity in verbosity_levels) {
    options(read.abares.verbosity = verbosity)

    quiet_flag <- NULL

    with_mocked_bindings(
      .download_file = function(url, destfile, quiet) {
        quiet_flag <<- quiet
        writeLines("mock content", destfile)
      },
      {
        .retry_download(test_url, temp_file)
      }
    )
  }
})
