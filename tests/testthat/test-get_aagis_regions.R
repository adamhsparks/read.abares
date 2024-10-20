test_that("get_aagis_regions works", {
  x <- get_aagis_regions(cache = FALSE)
  expect_type(x, "sf")
})
