# Note: the zip file used in the test is created in setup.R before tests run

test_that("read_clum_stars() works properly", {
  c_stars <- read_clum_stars(zip_file, data_set = "clum_50m_2023_v2")
  expect_equal(unname(dim(c_stars)), c(95, 90))
  expect_named(c_stars, "clum_50m_2023_v2.tif")
})


test_that("read_clum_terra works properly", {
  c_terra <- read_clum_terra(zip_file, data_set = "clum_50m_2023_v2")
  expect_equal(dim(c_terra), c(90, 95, 1))
  expect_named(c_terra, "clum_50m_2023_v2")
})
