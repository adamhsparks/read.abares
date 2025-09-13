# helper function for .retry_download tests
read_raw_file <- function(path) {
  if (!file.exists(path)) {
    stop("File does not exist: ", path)
  }
  readChar(path, nchars = file.info(path)$size, useBytes = TRUE)
}

test_that(".retry_download writes file with mocked .perform_request", {
  tmp_file <- tempfile()

  fake_response <- httr2::response(
    method = "GET",
    url = "https://example.com/file",
    status_code = 200,
    headers = list(),
    body = charToRaw("mock content")
  )

  local_mocked_bindings(
    .perform_request = function(req) fake_response,
    .env = environment(.retry_download)
  )

  result <- .retry_download("https://example.com/file", tmp_file)

  expect_true(result$success)
  expect_identical(read_raw_file(result$path), "mock content")
})

test_that(".retry_download fails after all retries", {
  tmp_file <- tempfile()

  # Mock .perform_request to always fail
  local_mocked_bindings(
    .perform_request = function(req) {
      stop("Persistent failure")
    },
    .env = environment(.retry_download)
  )

  result <- .retry_download("https://example.com/file", tmp_file)

  expect_false(result$success)
  expect_s3_class(result$error, "download_error")
  expect_false(file.exists(tmp_file))
})
