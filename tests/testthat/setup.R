create_clum_fixture <- function() {
  library(terra)
  clum_50m_2023_v2 <- rast(system.file("ex/elev.tif", package = "terra"))
  writeRaster(
    clum_50m_2023_v2,
    filename = fs::path_temp("clum_50m_2023_v2.tif"),
    overwrite = TRUE
  )
  zip_file <- fs::path_temp("clum_50m_2023_v2.zip")
  utils::zip(
    zip_file,
    files = fs::path_temp("clum_50m_2023_v2.tif")
  )
}
