test_that(".get_clum() returns expected filenames from fixture zip", {
  zip <- locate_clum_fixture()
  c_stars <- read_clum_stars(zip, data_set = "clum_50m_2023_v2")
})
