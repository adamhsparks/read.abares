test_that("read_clum_stars() retrieves catchment scale land use data", {
  local_mock(
    read_clum_stars = function(data_set) {
      structure(
        list(data = NULL),
        class = c("stars_proxy", "stars"),
        names = "clum_50m_2023_v2.tif"
      )
    }
  )

  x <- read_clum_stars(data_set = "clum_50m_2023_v2")
  expect_s3_class(x, c("stars_proxy", "stars"))
  expect_identical(basename(names(x)), "clum_50m_2023_v2.tif")
})

test_that("read_clum_stars() retrieves catchment scale scale and date data", {
  local_mock(
    read_clum_stars = function(data_set) {
      structure(
        list(data = NULL),
        class = c("stars_proxy", "stars"),
        names = "clum_50m_2023_v2.tif"
      )
    }
  )

  x <- read_clum_stars(data_set = "scale_date_update")
  expect_s3_class(x, c("stars_proxy", "stars"))
  expect_identical(basename(names(x)), "clum_50m_2023_v2.tif")
})
