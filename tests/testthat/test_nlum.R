library(terra)
nlum_file_names <- c(
  "NLUM_v7_250_ALUMV8_2020_21_alb_package_20241128",
  "NLUM_v7_250_ALUMV8_2015_16_alb_package_20241128",
  "NLUM_v7_250_ALUMV8_2010_11_alb_package_20241128",
  "NLUM_v7_250_CHANGE_SIMP_2011_to_2021_alb_package_20241128",
  "NLUM_v7_250_INPUTS_2020_21_geo_package_20241128",
  "NLUM_v7_250_INPUTS_2015_16_geo_package_20241128",
  "NLUM_v7_250_INPUTS_2010_11_geo_package_20241128",
  "NLUM_v7_250_AgProbabilitySurfaces_2020_21_geo_package_20241128",
  "NLUM_v7_250_AgProbabilitySurfaces_2015_16_geo_package_20241128",
  "NLUM_v7_250_AgProbabilitySurfaces_2010_11_geo_package_20241128"
)

nlum_data_sets <- c(
  "Y202021",
  "Y201516",
  "Y201011",
  "C201121",
  "T202021",
  "T201516",
  "T201011",
  "P202021",
  "P201516",
  "P201011"
)

zip_file <- fs::path_temp(nlum_file_names)
fs::dir_create(zip_file)

create_nlum_fixture <- function(zip_file) {
  nlum <- rast(system.file("ex/elev.tif", package = "terra"))
  names(nlum) <- fs::path_file(zip_file)
  writeRaster(
    nlum,
    filename = sprintf("%s/%s.tif", zip_file, fs::path_file(zip_file)),
    overwrite = TRUE
  )
  utils::zip(
    zip_file,
    files = fs::path(zip_file, "nlum.tif")
  )
  fs::dir_delete(zip_file)
}

lapply(X = zip_file, FUN = create_nlum_fixture)

nlum_file_zip <- fs::dir_ls(fs::path_temp(), glob = "*.zip")

test_that("read_nlum_stars() works properly for Y201011", {
  n_stars <- lapply(
    X = nlum_file_zip,
    FUN = read_nlum_stars,
    data_set = NULL
  )
  expect_equal(unname(dim(n_stars)), c(95, 90))
  expect_named(n_stars, paste0(i, ".tif"))
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
