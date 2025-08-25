test_that("read_aagis_regions returns an sf object", {
  skip_if_offline()
  skip_on_ci()
  x <- read_aagis_regions()
  expect_s3_class(x, "sf")
})
