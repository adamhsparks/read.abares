library(terra)
nlum_file_names <- list(
  Y202021 = "NLUM_v7_250_ALUMV8_2020_21_alb_package_20241128",
  Y201516 = "NLUM_v7_250_ALUMV8_2015_16_alb_package_20241128",
  Y201011 = "NLUM_v7_250_ALUMV8_2010_11_alb_package_20241128",
  C201121 = "NLUM_v7_250_CHANGE_SIMP_2011_to_2021_alb_package_20241128",
  T202021 = "NLUM_v7_250_INPUTS_2020_21_geo_package_20241128",
  T201516 = "NLUM_v7_250_INPUTS_2015_16_geo_package_20241128",
  T201011 = "NLUM_v7_250_INPUTS_2010_11_geo_package_20241128",
  P202021 = "NLUM_v7_250_AgProbabilitySurfaces_2020_21_geo_package_20241128",
  P201516 = "NLUM_v7_250_AgProbabilitySurfaces_2015_16_geo_package_20241128",
  P201011 = "NLUM_v7_250_AgProbabilitySurfaces_2010_11_geo_package_20241128"
)

zip_file <- fs::path_temp(names(nlum_file_names))
fs::dir_create(fs::path_temp(nlum_file_names))
nlum <- rast(system.file("ex/elev.tif", package = "terra"))
create_nlum_fixture <- function(zip_file, nlum) {
  names(nlum) <- zip_file
  writeRaster(
    nlum,
    filename = fs::path_temp(fs::path_file(zip_file), "nlum.tif"),
    overwrite = TRUE
  )
  utils::zip(
    zip_file,
    files = fs::path_temp(fs::path_file(zip_file), "nlum.tif")
  )
  fs::dir_delete(fs::path_temp("nlum"))
}

test_that("read_clum_stars() works properly", {
  c_stars <- read_clum_stars(x = zip_file, data_set = "nlum")
  expect_equal(unname(dim(c_stars)), c(95, 90))
  expect_named(c_stars, "nlum.tif")
})


test_that("read_clum_terra works properly", {
  c_terra <- read_clum_terra(zip_file, data_set = "nlum")
  expect_equal(dim(c_terra), c(90, 95, 1))
  expect_named(c_terra, "nlum")
})

test_that("read_clum_terra() fails with incorrect data_set", {
  expect_error(
    read_clum_terra(zip_file, data_set = "non_existent_data_set"),
    "`data_set` must be one of"
  )
})

test_that("read_clum_stars() fails with incorrect data_set", {
  expect_error(
    read_clum_stars(zip_file, data_set = 1L),
    "`data_set` must be a single character string value."
  )
})
