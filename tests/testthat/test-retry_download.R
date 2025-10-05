# Test file for download utilities
# Tests for read.abares package download functions

test_that(".parse_url_info handles valid URLs correctly", {
  # Test valid HTTP URL
  result <- .parse_url_info("https://example.com/path/to/file.csv")
  expect_true(result$valid)
  expect_equal(result$hostname, "example.com")
  expect_equal(result$path, "/path/to/file.csv")
  expect_equal(result$filename, "file.csv")

  # Test URL with no file extension
  result <- .parse_url_info("https://api.example.com/data")
  expect_true(result$valid)
  expect_equal(result$hostname, "api.example.com")
  expect_equal(result$path, "/data")
  expect_equal(result$filename, "data")

  # Test URL with query parameters
  result <- .parse_url_info("https://example.com/file.xlsx?version=1")
  expect_true(result$valid)
  expect_equal(result$hostname, "example.com")
  expect_true(grepl("file.xlsx", result$path))
  expect_equal(result$filename, "file.xlsx")
})

test_that(".parse_url_info handles invalid URLs correctly", {
  # Test NULL input
  result <- .parse_url_info(NULL)
  expect_false(result$valid)
  expect_equal(result$hostname, "")
  expect_equal(result$path, "")
  expect_equal(result$filename, "")

  # Test empty string
  result <- .parse_url_info("")
  expect_false(result$valid)

  # Test non-character input
  result <- .parse_url_info(123)
  expect_false(result$valid)

  # Test vector of length > 1
  result <- .parse_url_info(c("http://example.com", "http://test.com"))
  expect_false(result$valid)

  # Test malformed URL (this should trigger the error handler)
  result <- .parse_url_info("not-a-url")
  expect_false(result$valid)
})

test_that(".get_timeouts returns default values", {
  # Clear any existing options first
  old_opts <- options()
  on.exit(options(old_opts))

  options(
    read.abares.timeout_connect = NULL,
    read.abares.timeout_total = NULL,
    read.abares.timeout = NULL,
    read.abares.low_speed_time = NULL,
    read.abares.low_speed_limit = NULL,
    read.abares.dataset_timeouts = NULL
  )

  result <- .get_timeouts()
  expect_type(result, "list")
  expect_equal(result$connect, 15L)
  expect_equal(result$total, 7200L)
  expect_equal(result$low_speed_time, 0L)
  expect_equal(result$low_speed_limit, 0L)
})

test_that(".get_timeouts respects global options", {
  old_opts <- options()
  on.exit(options(old_opts))

  # Set custom global options
  options(
    read.abares.timeout_connect = 30L,
    read.abares.timeout_total = 3600L,
    read.abares.low_speed_time = 10L,
    read.abares.low_speed_limit = 1000L
  )

  result <- .get_timeouts()
  expect_equal(result$connect, 30L)
  expect_equal(result$total, 3600L)
  expect_equal(result$low_speed_time, 10L)
  expect_equal(result$low_speed_limit, 1000L)
})

test_that(".get_timeouts handles legacy timeout option", {
  old_opts <- options()
  on.exit(options(old_opts))

  # Test legacy read.abares.timeout option
  options(
    read.abares.timeout_total = NULL,
    read.abares.timeout = 1800L
  )

  result <- .get_timeouts()
  expect_equal(result$total, 1800L)
})

test_that(".get_timeouts applies dataset-specific overrides", {
  old_opts <- options()
  on.exit(options(old_opts))

  # Set dataset-specific timeouts
  options(
    read.abares.dataset_timeouts = list(
      "dataset1" = list(connect = 60L, total = 9000L),
      "dataset2" = list(connect = 45L)
    )
  )

  # Test dataset1 overrides
  result <- .get_timeouts("dataset1")
  expect_equal(result$connect, 60L)
  expect_equal(result$total, 9000L)
  expect_equal(result$low_speed_time, 0L) # Should keep default

  # Test dataset2 partial override
  result <- .get_timeouts("dataset2")
  expect_equal(result$connect, 45L)
  expect_equal(result$total, 7200L) # Should keep default

  # Test non-existent dataset
  result <- .get_timeouts("nonexistent")
  expect_equal(result$connect, 15L) # Should use defaults
})

test_that(".should_stream identifies zip files correctly", {
  # Create mock probe result
  probe <- list(content_type = "application/zip", content_length = 1000000)

  # Test zip file extension
  result <- .should_stream("https://example.com/data.zip", probe)
  expect_true(result$stream)
  expect_true(grepl("zip file", result$reason))

  # Test zip content type
  probe$content_type <- "application/zip"
  result <- .should_stream("https://example.com/data", probe)
  expect_true(result$stream)
  expect_true(grepl("zip file", result$reason))
})

test_that(".should_stream identifies DAFF SirsiDynix endpoints", {
  probe <- list(content_type = "application/pdf", content_length = 1000000)

  result <- .should_stream(
    "https://daff.ent.sirsidynix.net.au/asset/123/456",
    probe
  )
  expect_true(result$stream)
  expect_true(grepl("DAFF SirsiDynix", result$reason))
})

test_that(".should_stream handles small file extensions", {
  probe <- list(
    content_type = "application/vnd.ms-excel",
    content_length = 1000000
  )

  # Test Excel file
  result <- .should_stream("https://example.com/data.xlsx", probe)
  expect_false(result$stream)
  expect_true(grepl("Small file extension", result$reason))

  # Test CSV file
  result <- .should_stream("https://example.com/data.csv", probe)
  expect_false(result$stream)

  # Test PDF file
  result <- .should_stream("https://example.com/document.pdf", probe)
  expect_false(result$stream)
})

test_that(".should_stream uses content length for decision", {
  old_opts <- options()
  on.exit(options(old_opts))

  # Set threshold to 50MB (default)
  options(read.abares.stream_threshold_mb = 50L)

  # Test large file (should stream)
  probe <- list(
    content_type = "application/octet-stream",
    content_length = 60 * 1048576
  ) # 60MB
  result <- .should_stream("https://example.com/largefile.dat", probe)
  expect_true(result$stream)
  expect_true(grepl("exceeds threshold", result$reason))

  # Test small file (should not stream)
  probe$content_length <- 30 * 1048576 # 30MB
  result <- .should_stream("https://example.com/smallfile.dat", probe)
  expect_false(result$stream)
  expect_true(grepl("below threshold", result$reason))
})

test_that(".should_stream handles missing content length", {
  # Test with NULL content length
  probe <- list(
    content_type = "application/octet-stream",
    content_length = NULL
  )
  result <- .should_stream("https://example.com/unknown.dat", probe)
  expect_false(result$stream)
  expect_true(grepl("No size information", result$reason))

  # Test with NA content length
  probe$content_length <- NA_real_
  result <- .should_stream("https://example.com/unknown.dat", probe)
  expect_false(result$stream)
})

test_that(".should_stream handles URLs without filenames", {
  probe <- list(content_type = "application/json", content_length = 1000)

  result <- .should_stream("https://api.example.com/data", probe)
  expect_false(result$stream) # No extension, small size
})

test_that(".build_request creates proper httr2 request", {
  old_opts <- options()
  on.exit(options(old_opts))

  # Test with custom user agent
  options(read.abares.user_agent = "test-agent/1.0")

  req <- .build_request("https://example.com/file.csv")

  # Check that it's an httr2_request object
  expect_s3_class(req, "httr2_request")

  # Check URL is set correctly
  expect_equal(req$url, "https://example.com/file.csv")
})

test_that(".build_request uses default user agent when option not set", {
  old_opts <- options()
  on.exit(options(old_opts))

  options(read.abares.user_agent = NULL)

  req <- .build_request("https://example.com/file.csv")
  expect_s3_class(req, "httr2_request")
})

test_that(".apply_timeouts modifies request correctly", {
  req <- httr2::request("https://example.com")
  timeouts <- list(
    connect = 30L,
    total = 1800L,
    low_speed_time = 60L,
    low_speed_limit = 1024L
  )

  modified_req <- .apply_timeouts(req, timeouts)
  expect_s3_class(modified_req, "httr2_request")

  # Check that timeouts are applied (structure should be modified)
  expect_false(identical(req, modified_req))
})

test_that(".has_internet handles errors gracefully", {
  # This test doesn't mock - it tests the actual error handling
  # The function should return FALSE on any error, TRUE if curl::has_internet() works

  result <- .has_internet()
  expect_type(result, "logical")
  expect_length(result, 1)

  # The result should be either TRUE or FALSE, never NA or error
  expect_true(is.logical(result) && !is.na(result))
})

# Integration-style tests that don't require mocking

test_that("timeout configuration chain works correctly", {
  old_opts <- options()
  on.exit(options(old_opts))

  # Test complete configuration chain
  options(
    read.abares.timeout_connect = 25L,
    read.abares.dataset_timeouts = list(
      "test_dataset" = list(total = 5400L)
    )
  )

  timeouts <- .get_timeouts("test_dataset")
  req <- httr2::request("https://httpbin.org/get")
  configured_req <- .apply_timeouts(req, timeouts)

  expect_s3_class(configured_req, "httr2_request")
  expect_equal(timeouts$connect, 25L)
  expect_equal(timeouts$total, 5400L)
})

test_that("URL parsing and streaming decision work together", {
  # Test the interaction between URL parsing and streaming decisions
  test_cases <- list(
    list(
      url = "https://example.com/large.zip",
      probe = list(content_type = "application/zip", content_length = 1000),
      expected_stream = TRUE,
      reason_pattern = "zip"
    ),
    list(
      url = "https://example.com/small.csv",
      probe = list(content_type = "text/csv", content_length = 1000),
      expected_stream = FALSE,
      reason_pattern = "Small file"
    ),
    list(
      url = "https://daff.ent.sirsidynix.net.au/asset/123/456",
      probe = list(content_type = "application/pdf", content_length = 1000),
      expected_stream = TRUE,
      reason_pattern = "DAFF"
    )
  )

  for (case in test_cases) {
    url_info <- .parse_url_info(case$url)
    expect_true(url_info$valid)

    stream_info <- .should_stream(case$url, case$probe)
    expect_equal(stream_info$stream, case$expected_stream)
    expect_true(grepl(
      case$reason_pattern,
      stream_info$reason,
      ignore.case = TRUE
    ))
  }
})

test_that("error handling in .parse_url_info is robust", {
  # Test various edge cases that might cause errors

  # Test with extremely long URL
  long_url <- paste0(
    "https://example.com/",
    paste(rep("a", 10000), collapse = "")
  )
  result <- .parse_url_info(long_url)
  expect_type(result, "list")
  expect_true("valid" %in% names(result))

  # Test with special characters
  special_url <- "https://example.com/file%20with%20spaces.csv"
  result <- .parse_url_info(special_url)
  expect_type(result, "list")

  # Test with international domain
  intl_url <- "https://xn--nxasmq6b.xn--o3cw4h/file.csv" # internationalized domain
  result <- .parse_url_info(intl_url)
  expect_type(result, "list")
})

test_that("streaming threshold option is respected", {
  old_opts <- options()
  on.exit(options(old_opts))

  # Test custom threshold
  options(read.abares.stream_threshold_mb = 10L)

  probe_small <- list(content_length = 5 * 1048576) # 5MB
  probe_large <- list(content_length = 15 * 1048576) # 15MB

  result_small <- .should_stream("https://example.com/file.dat", probe_small)
  expect_false(result_small$stream)

  result_large <- .should_stream("https://example.com/file.dat", probe_large)
  expect_true(result_large$stream)
})

test_that("file extension handling is case insensitive", {
  probe <- list(
    content_type = "application/octet-stream",
    content_length = 1000
  )

  # Test uppercase extensions
  result_upper <- .should_stream("https://example.com/FILE.CSV", probe)
  expect_false(result_upper$stream)

  # Test mixed case
  result_mixed <- .should_stream("https://example.com/file.XlSx", probe)
  expect_false(result_mixed$stream)
})

# Performance and edge case tests

test_that("functions handle NA and unusual inputs gracefully", {
  # Test .parse_url_info with NA
  expect_type(.parse_url_info(NA_character_), "list")

  # Test .get_timeouts with unusual dataset_id
  expect_type(.get_timeouts(NA_character_), "list")
  expect_type(.get_timeouts(123), "list")
  expect_type(.get_timeouts(c("a", "b")), "list")

  # Test .should_stream with minimal probe
  minimal_probe <- list()
  result <- .should_stream("https://example.com", minimal_probe)
  expect_type(result, "list")
  expect_true("stream" %in% names(result))
  expect_true("reason" %in% names(result))
})

test_that("option handling is type-safe", {
  old_opts <- options()
  on.exit(options(old_opts))

  # Test with non-numeric timeout options (should not crash)
  options(
    read.abares.timeout_connect = "invalid",
    read.abares.stream_threshold_mb = "also_invalid"
  )

  # Functions should handle invalid options gracefully
  expect_type(.get_timeouts(), "list")

  # Reset and test with valid options
  options(
    read.abares.timeout_connect = 30, # numeric instead of integer
    read.abares.stream_threshold_mb = 25.5 # non-integer
  )

  timeouts <- .get_timeouts()
  expect_type(timeouts, "list")
})

test_that("request building handles various URL formats", {
  # Test different URL schemes and formats
  urls <- c(
    "https://example.com/file.csv",
    "http://api.example.com/data?param=value",
    "https://subdomain.example.com:8080/path/to/file",
    "https://example.com/file%20with%20spaces.txt"
  )

  for (url in urls) {
    req <- .build_request(url)
    expect_s3_class(req, "httr2_request")
    expect_equal(req$url, url)
  }
})
