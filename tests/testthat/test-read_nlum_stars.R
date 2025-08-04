test_that("read_nlum_stars() retrieves 2010-11 land use data", {
  skip_if_offline()
  skip_on_ci()
  x <- read_nlum_stars(data_set = "Y201011")
  expect_s3_class(x, c("stars_proxy", "stars"))
  expect_identical(basename(names(x)), "NLUM_v7_250_ALUMV8_2010_11_alb.tif")
})

test_that("read_nlum_stars() retrieves 2015-16 land use data", {
  skip_if_offline()
  skip_on_ci()
  x <- read_nlum_stars(data_set = "Y201516")
  expect_s3_class(x, c("stars_proxy", "stars"))
  expect_identical(basename(names(x)), "NLUM_v7_250_ALUMV8_2015_16_alb.tif")
})

test_that("read_nlum_stars() retrieves 2020-21 land use data", {
  skip_if_offline()
  skip_on_ci()
  x <- read_nlum_stars(data_set = "Y202021")
  expect_s3_class(x, c("stars_proxy", "stars"))
  expect_identical(basename(names(x)), "NLUM_v7_250_ALUMV8_2020_21_alb.tif")
})

test_that("read_nlum_stars() retrieves change use change data", {
  skip_if_offline()
  skip_on_ci()
  x <- read_nlum_stars(data_set = "C201121")
  expect_s3_class(x, c("stars_proxy", "stars"))
  expect_identical(
    basename(names(x)),
    c(
      "NLUM_v7_250_SIMP_CHANGE_DETAIL_2011_to_2021_alb.tif",
      "NLUM_v7_250_SIMP_CHANGE_SUMMARY_2011_to_2021_alb.tif"
    )
  )
})

test_that("read_nlum_stars() retrieves thematic 2010-11 land use layers", {
  skip_if_offline()
  skip_on_ci()
  x <- read_nlum_stars(data_set = "T201011")
  expect_s3_class(x, c("stars_proxy", "stars"))
  expect_identical(basename(names(x)), "NLUM_v7_250_INPUTS_2010_11_geo.tif")
})

test_that("read_nlum_stars() retrieves thematic 2015-16 land use layers", {
  skip_if_offline()
  skip_on_ci()
  x <- read_nlum_stars(data_set = "T201516")
  expect_s3_class(x, c("stars_proxy", "stars"))
  expect_identical(basename(names(x)), "NLUM_v7_250_INPUTS_2015_16_geo.tif")
})

test_that("read_nlum_stars() retrieves thematic 2020-21 land use layers", {
  skip_if_offline()
  skip_on_ci()
  x <- read_nlum_stars(data_set = "T202021")
  expect_s3_class(x, c("stars_proxy", "stars"))
  expect_identical(basename(names(x)), "NLUM_v7_250_INPUTS_2020_21_geo.tif")
})

test_that("read_nlum_stars() retrieves 2010-11 probability grids", {
  skip_if_offline()
  skip_on_ci()
  x <- read_nlum_stars(data_set = "P201011")
  expect_s3_class(x, c("stars_proxy", "stars"))
  expect_length(x, 23L)
})

test_that("read_nlum_stars() retrieves 2015-16 probability grids", {
  skip_if_offline()
  skip_on_ci()
  x <- read_nlum_stars(data_set = "P201516")
  expect_s3_class(x, c("stars_proxy", "stars"))
  expect_length(x, 23L)
})

test_that("read_nlum_stars() retrieves 2020-21 probability grids", {
  skip_if_offline()
  skip_on_ci()
  x <- read_nlum_stars(data_set = "P202021")
  expect_s3_class(x, c("stars_proxy", "stars"))
  expect_length(x, 23L)
})
