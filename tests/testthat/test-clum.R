library(terra)
zip_file <- fs::path_temp("clum_50m_2023_v2.zip")
create_clum_fixture <- function(zip_file) {
  clum_50m_2023_v2 <- rast(system.file("ex/elev.tif", package = "terra"))
  names(clum_50m_2023_v2) <- "clum_50m_2023_v2"
  writeRaster(
    clum_50m_2023_v2,
    filename = fs::path_temp("clum_50m_2023_v2.tif"),
    overwrite = TRUE
  )
  utils::zip(
    zip_file,
    files = fs::path_temp("clum_50m_2023_v2.tif")
  )
}

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
