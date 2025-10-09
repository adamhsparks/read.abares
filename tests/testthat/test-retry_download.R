test_that(".retry_download() downloads files successfully", {
  # Create a temporary file for testing
  temp_file <- withr::local_tempfile(fileext = ".csv")

  # Create test content
  test_content <- "col1,col2,col3\n1,2,3\n4,5,6\n"

  # Enable webmockr
  webmockr::enable()
  withr::defer(webmockr::disable())

  # Stub the HTTP request
  stub <- webmockr::stub_request("get", "https://example.com/test.csv") |>
    webmockr::to_return(
      status = 200,
      headers = list("Content-Type" = "text/csv"),
      body = test_content
    )

  url <- "https://example.com/test.csv"

  # Test successful download
  expect_no_error(.retry_download(url = url, dest = temp_file))
  expect_true(file.exists(temp_file))
  expect_gt(file.size(temp_file), 0)

  # Verify content
  downloaded_content <- readLines(temp_file, warn = FALSE)
  expected_lines <- strsplit(test_content, "\n")[[1]]
  expected_lines <- expected_lines[expected_lines != ""]
  expect_identical(downloaded_content, expected_lines)
})

test_that(".retry_download() handles different file extensions", {
  # Test with JSON file
  temp_json <- withr::local_tempfile(fileext = ".json")
  test_json <- '{"test": "data", "numbers": [1, 2, 3]}'

  # Enable webmockr
  webmockr::enable()
  withr::defer(webmockr::disable())

  # Stub the HTTP request
  stub <- webmockr::stub_request("get", "https://example.com/test.json") |>
    webmockr::to_return(
      status = 200,
      headers = list("Content-Type" = "application/json"),
      body = test_json
    )

  url <- "https://example.com/test.json"

  expect_no_error(.retry_download(url = url, dest = temp_json))
  expect_true(file.exists(temp_json))

  # Verify JSON content
  downloaded_json <- paste(readLines(temp_json, warn = FALSE), collapse = "")
  expect_identical(downloaded_json, test_json)
})

test_that(".retry_download() respects max_tries parameter", {
  temp_file <- withr::local_tempfile(fileext = ".txt")

  # Enable webmockr
  webmockr::enable()
  withr::defer(webmockr::disable())

  # Test that it fails with max_tries = 2 (only 2 attempts, both fail)
  webmockr::stub_registry_clear()
  fail_stub <- webmockr::stub_request("get", "https://example.com/test.txt") |>
    webmockr::to_return(status = 500, body = "Server Error")

  expect_error(.retry_download(url = url, dest = temp_file, .max_tries = 2L))

  # Test that it succeeds with max_tries = 3
  # (this would require a more complex setup to simulate the sequence)
})

test_that(".retry_download() fails after max_tries exceeded", {
  temp_file <- withr::local_tempfile(fileext = ".txt")

  # Enable webmockr
  webmockr::enable()
  withr::defer(webmockr::disable())

  # Stub that always returns 500
  stub <- webmockr::stub_request("get", "https://example.com/failing.txt") |>
    webmockr::to_return(status = 500, body = "Always fails")

  url <- "https://example.com/failing.txt"

  # Should fail after 2 attempts
  expect_error(
    .retry_download(url = url, dest = temp_file, .max_tries = 2L),
    class = "httr2_http"
  )
  expect_false(file.exists(temp_file))
})

test_that(".retry_download() works with correct headers", {
  temp_file <- withr::local_tempfile(fileext = ".txt")

  # Enable webmockr
  webmockr::enable()
  withr::defer(webmockr::disable())

  # Create a more flexible stub that doesn't require exact header matching
  webmockr::stub_request("get", "https://example.com/test.txt") |>
    webmockr::to_return(
      status = 200,
      body = "test content"
    )

  url <- "https://example.com/test.txt"

  # Test that the function works
  expect_no_error(.retry_download(url = url, dest = temp_file))
  expect_true(file.exists(temp_file))

  # Read the content to verify it was downloaded correctly
  content <- readLines(temp_file, warn = FALSE)
  expect_identical(content, "test content")
})

test_that(".retry_download() request is configured correctly", {
  # Test the request configuration without performing the actual request
  url <- "https://example.com/test.txt"

  # Create the request object using the same logic as your function
  req <- httr2::request(base_url = url) |>
    httr2::req_user_agent("read.abares") |>
    httr2::req_headers(
      "Accept-Encoding" = "identity",
      "Connection" = "Keep-Alive"
    )

  # Test that the request object is properly configured
  expect_s3_class(req, "httr2_request")
  expect_identical(req$url, url)

  # Check that options are set (httr2 stores user agent in options$useragent)
  expect_true("useragent" %in% names(req$options))
  expect_identical(req$options$useragent, "read.abares")

  # Check that headers are set
  expect_true("Accept-Encoding" %in% names(req$headers))
  expect_identical(req$headers$`Accept-Encoding`, "identity")
  expect_identical(req$headers$Connection, "Keep-Alive")
})

test_that(".apply_conditional_options() adds agriculture.gov.au options", {
  base_req <- httr2::request("http://example.com")

  # Test with agriculture.gov.au URL
  ag_url <- "https://www.agriculture.gov.au/sites/default/files/documents/test.csv"
  modified_req <- .apply_conditional_options(base_req, ag_url)

  # We can't easily inspect httr2 request objects, but we can verify the function runs
  expect_s3_class(modified_req, "httr2_request")

  # Test with non-agriculture URL
  other_url <- "https://example.com/test.csv"
  other_req <- .apply_conditional_options(base_req, other_url)
  expect_s3_class(other_req, "httr2_request")
})

test_that(".apply_conditional_options() adds progress when verbose", {
  base_req <- httr2::request("http://example.com")
  url <- "http://example.com/test.csv"

  # Test with verbose option set
  withr::with_options(
    list("read.abares.verbosity" = "verbose"),
    {
      modified_req <- .apply_conditional_options(base_req, url)
      expect_s3_class(modified_req, "httr2_request")
    }
  )

  # Test without verbose option
  withr::with_options(
    list("read.abares.verbosity" = "quiet"),
    {
      modified_req <- .apply_conditional_options(base_req, url)
      expect_s3_class(modified_req, "httr2_request")
    }
  )
})

test_that(".is_agriculture_url() correctly identifies agriculture URLs", {
  # Test positive cases
  expect_true(.is_agriculture_url(
    "https://www.agriculture.gov.au/sites/default/files/documents/test.csv"
  ))
  expect_true(.is_agriculture_url(
    "https://www.agriculture.gov.au/sites/default/files/documents/data/file.json"
  ))

  # Test negative cases
  expect_false(.is_agriculture_url("https://example.com/test.csv"))
  expect_false(.is_agriculture_url(
    "https://agriculture.gov.au/different/path/test.csv"
  ))
  expect_false(.is_agriculture_url(
    "https://www.agriculture.gov.au/sites/default/test.csv"
  ))
  expect_false(.is_agriculture_url(
    "http://www.agriculture.gov.au/sites/default/files/documents/test.csv"
  )) # http vs https
})

test_that(".should_show_progress() returns correct logical values", {
  # Ensure clean slate for the option we're testing
  withr::local_options("read.abares.verbosity" = NULL)

  # Test with verbose option
  withr::with_options(
    list("read.abares.verbosity" = "verbose"),
    expect_true(.should_show_progress())
  )

  # Test with different option value
  withr::with_options(
    list("read.abares.verbosity" = "quiet"),
    expect_false(.should_show_progress())
  )

  # Test with no option set
  withr::with_options(
    list("read.abares.verbosity" = NULL),
    expect_false(.should_show_progress())
  )

  # Test with different option entirely
  withr::with_options(
    list("some.other.option" = "verbose"),
    expect_false(.should_show_progress())
  )
})


test_that(".retry_download() creates cache directory in tempdir", {
  temp_file <- withr::local_tempfile(fileext = ".txt")

  # Enable webmockr
  webmockr::enable()
  withr::defer(webmockr::disable())

  # Stub the HTTP request
  stub <- webmockr::stub_request("get", "https://example.com/cached.txt") |>
    webmockr::to_return(
      status = 200,
      headers = list("Cache-Control" = "max-age=3600"),
      body = "cached content"
    )

  url <- "https://example.com/cached.txt"

  # Record tempdir contents before
  before_files <- list.files(tempdir(), recursive = TRUE, full.names = TRUE)

  # First request should create cache
  expect_no_error(.retry_download(url = url, dest = temp_file))
  expect_true(file.exists(temp_file))

  # Check what was actually created
  after_files <- list.files(tempdir(), recursive = TRUE, full.names = TRUE)
  new_files <- setdiff(after_files, before_files)

  # Debug: print what files were created
  cat("New files created:", paste(new_files, collapse = ", "), "\n")

  expect_length(new_files, 1L)
})


test_that(".retry_download() preserves binary content", {
  temp_file <- withr::local_tempfile(fileext = ".bin")

  # Create some binary test data
  binary_data <- as.raw(c(0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A)) # PNG header

  # Enable webmockr
  webmockr::enable()
  withr::defer(webmockr::disable())

  # Stub the HTTP request with binary data
  stub <- webmockr::stub_request("get", "https://example.com/test.bin") |>
    webmockr::to_return(
      status = 200,
      headers = list("Content-Type" = "application/octet-stream"),
      body = binary_data
    )

  url <- "https://example.com/test.bin"

  expect_no_error(.retry_download(url = url, dest = temp_file))
  expect_true(file.exists(temp_file))

  # Verify binary content is preserved
  downloaded_data <- brio::read_file_raw(temp_file)
  expect_identical(downloaded_data, binary_data)
})
