test_that("get_abares_trade_regions() returns expected columns", {
  fake <- mk_resp_json(list(
    items = list(
      list(state = "WA",  code = "5"),
      list(state = "NSW", code = "1")
    )
  ))

  with_mocked_bindings({
    .perform_request <- function(req, ...) fake
    out <- get_abares_trade_regions(level = "state")
  }, .package = "read.abares")

  expect_s3_class(out, "data.frame")
  expect_true(all(c("state", "code") %in% names(out)))
  expect_true(nrow(out) >= 2)
})
