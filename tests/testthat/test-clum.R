test_that(".get_clum() returns expected filenames from fixture zip", {
  datasets <- c("clum_50m_2023_v2", "scale_date_update")

  for (ds in datasets) {
    zip <- system.file(
      "extdata",
      sprintf("%s.zip", ds),
      package = "read.abares",
      mustWork = TRUE
    )

    zip_list <- utils::unzip(zip, list = TRUE)$Name
    tif_files <- grep("\\.tif$", zip_list, value = TRUE)

    expect_type(tif_files, "character")
    expect_gt(length(tif_files), 0L)
    expect_true(endsWith(tif_files, "tif"))
  }
})
