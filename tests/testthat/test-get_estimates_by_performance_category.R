test_that("get_estimates_by_performance_category() parses CSV", {
  csv <- "aagis_code,year,category,value\n5,2022,high,0.73\n1,2022,low,0.12\n"
  fake <- mk_resp_text(csv, content_type = "text/csv; charset=utf-8")

  with_mocked_bindings({
    .perform_request <- function(req, ...) fake
    df <- get_estimates_by_performance_category(year = 2022)
  }, .package = "read.abares")

  expect_s3_class(df, "data.frame")
  expect_true(all(c("aagis_code", "year", "category", "value") %in% names(df)))
  expect_equal(nrow(df), 2)
})
