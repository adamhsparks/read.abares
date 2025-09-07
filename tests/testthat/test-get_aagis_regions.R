test_that("get_aagis_regions() returns an sf with expected fields", {
  # Minimal GeoJSON to keep tests tiny and offline
  gj <- '{"type":"FeatureCollection","features":[{"type":"Feature",
         "properties":{"aagis_code":"05","aagis_name":"Western Australia"},
         "geometry":{"type":"Point","coordinates":[115.8575,-31.9505]}}]}'
  fake <- mk_resp_text(gj, content_type = "application/geo+json")

  with_mocked_bindings({
    .perform_request <- function(req, ...) fake
    x <- get_aagis_regions(class = "sf")
  }, .package = "read.abares")

  expect_s3_class(x, "sf")
  expect_true(all(c("aagis_code", "aagis_name") %in% names(x)))
  expect_equal(nrow(x), 1)
})
