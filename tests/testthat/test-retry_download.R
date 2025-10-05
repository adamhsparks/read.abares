test_that(".parse_url_info handles various URLs", {
  # Valid URL
  result <- .parse_url_info("https://example.com/path/file.txt")
  expect_true(result$valid)
  expect_equal(result$hostname, "example.com")
  expect_equal(result$path, "/path/file.txt")
  expect_equal(result$filename, "file.txt")

  # Invalid URL
  result_bad <- .parse_url_info("not-a-url")
  expect_false(result_bad$valid)
  expect_equal(result_bad$path, "")

  # NULL input
  result_null <- .parse_url_info(NULL)
  expect_false(result_null$valid)
})

test_that(".has_internet works", {
  # This test checks the function exists and returns a logical
  result <- .has_internet()
  expect_type(result, "logical")
  expect_length(result, 1)
})

test_that(".get_timeouts returns sensible defaults", {
  # Test with no options set
  withr::with_options(
    list(
      read.abares.timeout_connect = NULL,
      read.abares.timeout_total = NULL,
      read.abares.timeout = NULL,
      read.abares.dataset_timeouts = NULL
    ),
    {
      result <- .get_timeouts()
      expect_equal(result$connect, 15L)
      expect_equal(result$total, 7200L)
      expect_equal(result$low_speed_time, 0L)
      expect_equal(result$low_speed_limit, 0L)
    }
  )
})

test_that(".get_timeouts respects dataset-specific overrides", {
  withr::with_options(
    list(
      read.abares.dataset_timeouts = list(
        special_dataset = list(total = 3600L, connect = 30L)
      )
    ),
    {
      result <- .get_timeouts("special_dataset")
      expect_equal(result$total, 3600L)
      expect_equal(result$connect, 30L)
      expect_equal(result$low_speed_time, 0L) # Should keep default
    }
  )
})

test_that(".should_stream identifies NetCDF files", {
  probe <- list(content_type = "", content_length = 1000)

  # By extension
  result <- .should_stream("https://example.com/data.nc", probe)
  expect_true(result$stream)
  expect_match(result$reason, "NetCDF")
})

test_that(".should_stream handles small file extensions", {
  probe <- list(content_type = "", content_length = 1000)

  result <- .should_stream("https://example.com/data.csv", probe)
  expect_false(result$stream)
  expect_match(result$reason, "Small file extension")
})

test_that(".should_stream uses size thresholds", {
  # Large file
  probe_large <- list(content_type = "", content_length = 100 * 1024^2) # 100 MB
  result_large <- .should_stream("https://example.com/data.zip", probe_large)
  expect_true(result_large$stream)

  # Small file
  probe_small <- list(content_type = "", content_length = 1024^2) # 1 MB
  result_small <- .should_stream("https://example.com/data.zip", probe_small)
  expect_false(result_small$stream)
})

test_that(".should_stream identifies DAFF endpoints", {
  probe <- list(content_type = "", content_length = NA)
  url <- "https://daff.ent.sirsidynix.net.au/asset/123/456"

  result <- .should_stream(url, probe)
  expect_true(result$stream)
  expect_match(result$reason, "DAFF.*asset")
})

test_that(".build_request creates proper httr2 request", {
  withr::with_options(list(read.abares.user_agent = "test-agent"), {
    req <- .build_request("https://example.com")
    expect_s3_class(req, "httr2_request")
  })
})

test_that(".apply_timeouts sets request timeouts", {
  req <- httr2::request("https://example.com")
  timeouts <- list(
    connect = 30L,
    total = 300L,
    low_speed_time = 60L,
    low_speed_limit = 1000L
  )

  result <- .apply_timeouts(req, timeouts)
  expect_s3_class(result, "httr2_request")
})

test_that(".safe_delete handles file operations", {
  # Test with non-existent file
  expect_false(.safe_delete("non_existent_file.txt"))

  # Test with existing file
  temp_file <- tempfile()
  writeLines("test", temp_file)
  expect_true(file.exists(temp_file))
  expect_true(.safe_delete(temp_file))
  expect_false(file.exists(temp_file))
})
