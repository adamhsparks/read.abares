test_that("read_clum_stars() retrieves catchment scale land use data", {
  skip_if_offline()
  skip_on_ci()
  x <- read_clum_stars(data_set = "clum_50m_2023_v2")
  expect_s3_class(x, c("stars_proxy", "stars"))
  expect_identical(basename(names(x)), "clum_50m_2023_v2.tif")
})


test_that("read_clum_stars() retrieves catchment scale scale and date data", {
  skip_if_offline()
  skip_on_ci()
  x <- read_clum_stars(data_set = "scale_date_update")
  expect_s3_class(x, c("stars_proxy", "stars"))
  expect_identical(basename(names(x)), "clum_50m_2023_v2.tif")
})
