test_that("functions surface HTTP errors from .perform_request()", {
  fake_404 <- mk_resp_error(status = 404)

  with_mocked_bindings({
    .perform_request <- function(req, ...) fake_404
    expect_error(get_aagis_regions(class = "sf"), "404|Not Found|HTTP")
  }, .package = "read.abares")
})
