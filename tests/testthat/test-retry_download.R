test_that(".retry_download() retries on 5xx and then succeeds", {
  calls <- 0L
with_mocked_bindings(
  {
    .perform_request <- function(req, ...) {
      calls <<- calls + 1L
      if (calls == 1L) mk_resp_error(status = 503) else mk_resp_json(list(ok = TRUE))
    }
    resp <- .retry_download(httr2::request("https://example.test"),
                            max_tries = 3, backoff = 0)
  },
  .perform_request = function(req, ...) fake,
  }, .package = "read.abares")

  expect_equal(calls, 2L)
  expect_s3_class(resp, "httr2_response")
  expect_equal(httr2::resp_status(resp), 200L)
})

test_that(".retry_download() errors after exhausting retries", {
  calls <- 0L
with_mocked_bindings(
  {
    .perform_request <- function(req, ...) {
      calls <<- calls + 1L
      mk_resp_error(status = 500)
    }
    expect_error(
      .retry_download(httr2::request("https://example.test"),
                      max_tries = 3, backoff = 0),
      "HTTP|500|retry"
    )
  },
  .perform_request = function(req, ...) fake,
  }, .package = "read.abares")

  expect_gte(calls, 3L)
})
