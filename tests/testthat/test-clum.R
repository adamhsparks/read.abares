# Note: the zip file used in the test is created in setup.R before tests run

test_that(".get_clum() returns expected filenames from fixture zip", {
  c_stars <- read_clum_stars(zip_file, data_set = "clum_50m_2023_v2")
  expect_equal(unname(nrow(c_stars)), 95)
  expect_named(c_stars, "clum_50m_2023_v2.tif")
})
