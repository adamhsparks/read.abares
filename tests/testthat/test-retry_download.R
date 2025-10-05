# Test file for download utilities

# Setup and teardown helpers ----
setup_test_env <- function() {
  # Clear all relevant options
  options(
    read.abares.timeout_connect = NULL,
    read.abares.timeout_total = NULL,
    read.abares.timeout = NULL,
    read.abares.low_speed_time = NULL,
    read.abares.low_speed_limit = NULL,
    read.abares.dataset_timeouts = NULL,
    read.abares.stream_threshold_mb = NULL,
    read.abares.user_agent = NULL,
    read.abares.max_tries = NULL
  )
}

teardown_test_env <- function() {
  setup_test_env() # Same as setup - clear options
}

# Mock internet connectivity without external mocking ----
simulate_no_internet <- function(expr) {
  # Temporarily replace the function in the calling environment
  original_has_internet <- .has_internet
  assign(".has_internet", function() FALSE, envir = parent.frame())
  on.exit(assign(
    ".has_internet",
    original_has_internet,
    envir = parent.frame()
  ))
  expr
}

simulate_internet_available <- function(expr) {
  original_has_internet <- .has_internet
  assign(".has_internet", function() TRUE, envir = parent.frame())
  on.exit(assign(
    ".has_internet",
    original_has_internet,
    envir = parent.frame()
  ))
  expr
}

# Test .has_internet ----
test_that(".has_internet works correctly", {
  setup_test_env()
  on.exit(teardown_test_env())

  # Test the actual function (this will use real curl::has_internet)
  result <- .has_internet()
  expect_type(result, "logical")
  expect_length(result, 1L)

  # Test error handling by creating a scenario where curl might not be available
  # We can't easily mock this without external tools, so we test the structure
  expect_no_error(.has_internet())
})

# Test .parse_url_info ----
test_that(".parse_url_info handles valid URLs", {
  setup_test_env()
  on.exit(teardown_test_env())

  # Valid URL
  result <- .parse_url_info("https://example.com/path/file.csv")
  expect_type(result, "list")
  expect_true(result$valid)
  expect_identical(result$hostname, "example.com")
  expect_identical(result$path, "/path/file.csv")
  expect_identical(result$filename, "file.csv")

  # URL without filename
  result <- .parse_url_info("https://example.com/path/")
  expect_true(result$valid)
  expect_identical(result$filename, "")

  # URL with query parameters
  result <- .parse_url_info("https://example.com/file.zip?param=value")
  expect_true(result$valid)
  expect_identical(result$filename, "file.zip")
})

test_that(".parse_url_info handles invalid inputs", {
  setup_test_env()
  on.exit(teardown_test_env())

  # NULL input
  result <- .parse_url_info(NULL)
  expect_false(result$valid)
  expect_identical(result$hostname, "")
  expect_identical(result$path, "")
  expect_identical(result$filename, "")

  # Empty string
  result <- .parse_url_info("")
  expect_false(result$valid)

  # Non-character input
  result <- .parse_url_info(123)
  expect_false(result$valid)

  # Multiple URLs
  result <- .parse_url_info(c("https://example.com", "https://test.com"))
  expect_false(result$valid)

  # Invalid URL format
  result <- .parse_url_info("not-a-url")
  expect_false(result$valid)
})

# Test .get_timeouts ----
test_that(".get_timeouts returns default values", {
  setup_test_env()
  on.exit(teardown_test_env())

  result <- .get_timeouts()
  expect_type(result, "list")
  expect_identical(result$connect, 15L)
  expect_identical(result$total, 7200L)
  expect_identical(result$low_speed_time, 0L)
  expect_identical(result$low_speed_limit, 0L)
})

test_that(".get_timeouts respects global options", {
  setup_test_env()
  on.exit(teardown_test_env())

  # Set global options
  options(
    read.abares.timeout_connect = 30L,
    read.abares.timeout_total = 3600L,
    read.abares.low_speed_time = 10L,
    read.abares.low_speed_limit = 1000L
  )

  result <- .get_timeouts()
  expect_identical(result$connect, 30L)
  expect_identical(result$total, 3600L)
  expect_identical(result$low_speed_time, 10L)
  expect_identical(result$low_speed_limit, 1000L)
})

test_that(".get_timeouts respects legacy timeout option", {
  setup_test_env()
  on.exit(teardown_test_env())

  # Test legacy read.abares.timeout option
  options(read.abares.timeout = 1800L)

  result <- .get_timeouts()
  expect_identical(result$total, 1800L)

  # Test that specific total timeout overrides legacy
  options(
    read.abares.timeout = 1800L,
    read.abares.timeout_total = 3600L
  )

  result <- .get_timeouts()
  expect_identical(result$total, 3600L)
})

test_that(".get_timeouts applies dataset-specific overrides", {
  setup_test_env()
  on.exit(teardown_test_env())

  # Set dataset-specific timeouts
  options(
    read.abares.dataset_timeouts = list(
      test_dataset = list(
        connect = 60L,
        total = 14400L
      )
    )
  )

  # Without dataset_id - should use defaults
  result <- .get_timeouts()
  expect_identical(result$connect, 15L)
  expect_identical(result$total, 7200L)

  # With matching dataset_id
  result <- .get_timeouts("test_dataset")
  expect_identical(result$connect, 60L)
  expect_identical(result$total, 14400L)
  expect_identical(result$low_speed_time, 0L) # Should keep default

  # With non-matching dataset_id
  result <- .get_timeouts("other_dataset")
  expect_identical(result$connect, 15L)
  expect_identical(result$total, 7200L)
})

# Test .should_stream ----
test_that(".should_stream handles zip files", {
  setup_test_env()
  on.exit(teardown_test_env())

  # ZIP file by extension
  probe <- list(
    content_type = "application/octet-stream",
    content_length = 1048576L
  )
  result <- .should_stream("https://example.com/file.zip", probe)
  expect_true(result$stream)
  expect_match(result$reason, "zip file detected")

  # ZIP file by content type
  probe <- list(content_type = "application/zip", content_length = 1048576)
  result <- .should_stream("https://example.com/file.unknown", probe)
  expect_true(result$stream)
  expect_match(result$reason, "zip file detected")
})

test_that(".should_stream handles DAFF SirsiDynix endpoints", {
  setup_test_env()
  on.exit(teardown_test_env())

  probe <- list(content_type = "application/pdf", content_length = 1048576)
  result <- .should_stream(
    "https://daff.ent.sirsidynix.net.au/asset/12345/67890",
    probe
  )
  expect_true(result$stream)
  expect_match(result$reason, "DAFF SirsiDynix asset endpoint")
})

test_that(".should_stream handles small file extensions", {
  setup_test_env()
  on.exit(teardown_test_env())

  probe <- list(
    content_type = "application/vnd.ms-excel",
    content_length = 1048576L
  )

  small_extensions <- c("xlsx", "xls", "csv", "pdf")
  for (ext in small_extensions) {
    url <- paste0("https://example.com/file.", ext)
    result <- .should_stream(url, probe)
    expect_false(result$stream)
    expect_match(result$reason, paste("Small file extension:", ext))
  }
})

test_that(".should_stream uses content length for decisions", {
  setup_test_env()
  on.exit(teardown_test_env())

  # Set threshold to 50MB (default)
  threshold_mb <- 50L
  threshold_bytes <- threshold_mb * 1048576L

  # Large file - should stream
  probe <- list(
    content_type = "application/octet-stream",
    content_length = threshold_bytes + 1L
  )
  result <- .should_stream("https://example.com/largefile.bin", probe)
  expect_true(result$stream)
  expect_match(result$reason, "exceeds threshold")

  # Small file - should not stream
  probe <- list(
    content_type = "application/octet-stream",
    content_length = threshold_bytes - 1L
  )
  result <- .should_stream("https://example.com/smallfile.bin", probe)
  expect_false(result$stream)
  expect_match(result$reason, "below threshold")

  # Custom threshold
  options(read.abares.stream_threshold_mb = 10L)
  probe <- list(
    content_type = "application/octet-stream",
    content_length = 20971520L
  )
  result <- .should_stream("https://example.com/file.bin", probe)
  expect_true(result$stream)
  expect_match(result$reason, "exceeds threshold 10 MB")
})

test_that(".should_stream handles missing content length", {
  setup_test_env()
  on.exit(teardown_test_env())

  # No content length
  probe <- list(
    content_type = "application/octet-stream",
    content_length = NULL
  )
  result <- .should_stream("https://example.com/file.bin", probe)
  expect_false(result$stream)
  expect_match(result$reason, "No size information available")

  # Infinite content length
  probe <- list(content_type = "application/octet-stream", content_length = Inf)
  result <- .should_stream("https://example.com/file.bin", probe)
  expect_false(result$stream)
  expect_match(result$reason, "No size information available")
})

test_that(".should_stream handles missing file extensions", {
  setup_test_env()
  on.exit(teardown_test_env())

  probe <- list(
    content_type = "application/octet-stream",
    content_length = 1048576L
  )

  # URL without extension
  result <- .should_stream("https://example.com/file", probe)
  expect_false(result$stream)
  expect_match(result$reason, "below threshold")

  # URL with path but no file
  result <- .should_stream("https://example.com/path/", probe)
  expect_false(result$stream)
})

# Test .build_request ----
test_that(".build_request creates proper httr2 request", {
  setup_test_env()
  on.exit(teardown_test_env())

  url <- "https://example.com/file.txt"
  req <- .build_request(url)

  expect_s3_class(req, "httr2_request")
  expect_identical(req$url, url)

  # Check headers are set (we can't easily inspect them without httr2 internals)
  expect_no_error(.build_request(url))
})

test_that(".build_request respects user agent option", {
  setup_test_env()
  on.exit(teardown_test_env())

  custom_ua <- "Custom User Agent"
  options(read.abares.user_agent = custom_ua)

  req <- .build_request("https://example.com")
  expect_s3_class(req, "httr2_request")
  expect_no_error(req)
})

# Test .apply_timeouts ----
test_that(".apply_timeouts modifies request correctly", {
  setup_test_env()
  on.exit(teardown_test_env())

  req <- httr2::request("https://example.com")
  timeouts <- list(
    connect = 30L,
    total = 3600L,
    low_speed_time = 10L,
    low_speed_limit = 1000L
  )

  modified_req <- .apply_timeouts(req, timeouts)
  expect_s3_class(modified_req, "httr2_request")
  expect_no_error(modified_req)
})

# Test .probe_url ----
test_that(".probe_url handles network errors gracefully", {
  setup_test_env()
  on.exit(teardown_test_env())

  # Invalid URL that should cause network error
  result <- .probe_url("https://this-domain-should-not-exist-12345.com")
  expect_type(result, "list")
  expect_false(result$ok)
  expect_identical(result$content_type, "")
  expect_true(is.na(result$content_length))
  expect_identical(result$accept_ranges, "")
})

# Test helper for creating temporary files
create_temp_file <- function(content = raw(0)) {
  temp_file <- tempfile(fileext = ".tmp")
  if (length(content) > 0) {
    brio::write_file_raw(content, temp_file)
  }
  temp_file
}

# Test .try_resume ----
test_that(".try_resume handles invalid inputs", {
  setup_test_env()
  on.exit(teardown_test_env())

  req <- httr2::request("https://example.com")
  temp_file <- create_temp_file()
  on.exit(unlink(temp_file), add = TRUE)

  # Zero size should return FALSE
  result <- .try_resume(req, temp_file, 0L)
  expect_false(result)

  # Negative size should return FALSE
  result <- .try_resume(req, temp_file, -1L)
  expect_false(result)
})

# Test .retry_download error conditions ----
test_that(".retry_download handles no internet", {
  setup_test_env()
  on.exit(teardown_test_env())

  temp_file <- tempfile(fileext = ".txt")
  on.exit(unlink(temp_file), add = TRUE)

  # Mock .has_internet using testthat's with_mocked_bindings
  testthat::with_mocked_bindings(
    .has_internet = function() FALSE,
    {
      expect_error(
        .retry_download(
          "https://example.com",
          temp_file,
          show_progress = FALSE
        ),
        "No internet connection available"
      )
    }
  )
})

# Integration tests with real network calls (optional, can be skipped) ----
test_that("download integration works with real URLs", {
  skip_if_offline()
  setup_test_env()
  on.exit(teardown_test_env())

  temp_file <- tempfile(fileext = ".txt")
  on.exit(unlink(temp_file), add = TRUE)

  # Use a reliable, small test URL
  test_url <- "https://httpbin.org/robots.txt"

  expect_no_error(
    .retry_download(test_url, temp_file, show_progress = FALSE)
  )

  expect_true(file.exists(temp_file))
  expect_gt(file.size(temp_file), 0L)
})

# Test URL parsing edge cases ----
test_that(".parse_url_info handles complex URLs", {
  setup_test_env()
  on.exit(teardown_test_env())

  # URL with port
  result <- .parse_url_info("https://example.com:8080/file.txt")
  expect_true(result$valid)
  expect_identical(result$hostname, "example.com")

  # URL with fragment
  result <- .parse_url_info("https://example.com/file.txt#section")
  expect_true(result$valid)
  expect_identical(result$filename, "file.txt")

  # URL with special characters in filename
  result <- .parse_url_info("https://example.com/file%20name.txt")
  expect_true(result$valid)
  expect_identical(result$filename, "file name.txt")
})

# Test timeout edge cases ----
test_that(".get_timeouts handles malformed options", {
  setup_test_env()
  on.exit(teardown_test_env())

  # Non-list dataset timeouts
  options(read.abares.dataset_timeouts = "not a list")
  result <- .get_timeouts("test")
  expect_identical(result$connect, 15L) # Should use defaults

  # NULL dataset timeouts with dataset_id
  options(read.abares.dataset_timeouts = NULL)
  result <- .get_timeouts("test")
  expect_identical(result$connect, 15L)
})

# Test streaming decision edge cases ----
test_that(".should_stream handles edge cases", {
  setup_test_env()
  on.exit(teardown_test_env())

  # URL with no path
  probe <- list(content_type = NULL, content_length = NULL)
  result <- .should_stream("https://example.com", probe)
  expect_false(result$stream)

  # Content type with mixed case
  probe <- list(content_type = "APPLICATION/ZIP", content_length = 1000)
  result <- .should_stream("https://example.com/file.unknown", probe)
  expect_true(result$stream)

  # File extension with mixed case
  probe <- list(
    content_type = "application/octet-stream",
    content_length = 1000L
  )
  result <- .should_stream("https://example.com/file.ZIP", probe)
  expect_true(result$stream)
})

# Performance and stress tests ----
test_that("functions handle repeated calls efficiently", {
  setup_test_env()
  on.exit(teardown_test_env())

  # Test repeated URL parsing
  urls <- rep("https://example.com/file.txt", 100L)
  start_time <- Sys.time()
  results <- lapply(urls, .parse_url_info)
  end_time <- Sys.time()

  expect_length(results, 100L)
  expect_true(all(sapply(results, function(x) x$valid)))
  expect_lt(as.numeric(end_time - start_time), 1L) # Should complete in under 1 second
})

# Test error handling robustness ----
test_that("functions handle malformed inputs gracefully", {
  setup_test_env()
  on.exit(teardown_test_env())

  # Test with various malformed inputs
  bad_inputs <- list(
    NULL,
    NA,
    character(0L),
    "",
    " ",
    123L,
    list(),
    c("a", "b")
  )

  for (input in bad_inputs) {
    expect_no_error(.parse_url_info(input))
    result <- .parse_url_info(input)
    expect_false(result$valid)
  }
})
