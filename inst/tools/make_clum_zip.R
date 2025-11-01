# create zip files for testing the CLUM functions
# and cleanup afterwards
writeLines("Dummy GeoTIFF content", "land_use_2023.tif")
writeLines("Dummy GeoTIFF content", "scale_update.tif")

zip("clum_50m_2023_v2.zip", "land_use_2023.tif")
zip("scale_date_update.zip", "scale_update.tif")

fs::file_move("clum_50m_2023_v2.zip", "inst/extdata/clum_50m_2023_v2.zip")
fs::file_move("scale_date_update.zip", "inst/extdata/scale_date_update.zip")

tif <- fs::dir_ls(regexp = ".tif$")
fs::file_delete(tif)
