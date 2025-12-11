make_fake_topsoil_zip <- function() {
  tmpdir <- tempdir()
  subdir <- file.path(tmpdir, "staiar9cl__05911a01eg_geo___")
  dir.create(subdir, showWarnings = FALSE)

  # Create a trivial raster
  r <- terra::rast(nrows = 2, ncols = 2, vals = 1:4)

  # Write it as ESRI Grid into "thpk_1" subdirectory
  grid_dir <- file.path(subdir, "thpk_1")
  terra::writeRaster(
    r,
    grid_dir,
    overwrite = TRUE,
    filetype = "AAIGrid",
    NAflag = -9999
  )

  # Metadata file alongside the grid
  txt_file <- file.path(subdir, "ANZCW1202000149.txt")
  writeLines("Fake metadata line", txt_file)

  # Zip the whole subdir with proper structure
  zipfile <- tempfile(fileext = ".zip")
  zip::zipr(zipfile, files = subdir)

  return(zipfile)
}
test_that(".get_topsoil_thickness returns correct object structure", {
  zipfile <- make_fake_topsoil_zip()
  result <- .get_topsoil_thickness(zipfile)

  expect_s3_class(result, "read.abares.topsoil.thickness")
  expect_named(result, c("metadata", "data"))
  expect_type(result$metadata, "character")
  expect_true(nchar(result$metadata) > 0)
  expect_s4_class(result$data, "SpatRaster")
  expect_equal(dim(result$data), c(2, 2, 1))
})

test_that(".get_topsoil_thickness works with NULL .x and triggers download", {
  fake_retry_download <- function(url, dest) {
    zipfile <- make_fake_topsoil_zip()
    file.copy(zipfile, dest, overwrite = TRUE)
  }

  with_mocked_bindings(
    result <- .get_topsoil_thickness(.x = NULL),
    .retry_download = fake_retry_download
  )

  expect_s3_class(result, "read.abares.topsoil.thickness")
  expect_s4_class(result$data, "SpatRaster")
  expect_true(nchar(result$metadata) > 0)
})

test_that("print method shows metadata", {
  zipfile <- make_fake_topsoil_zip()
  result <- .get_topsoil_thickness(zipfile)

  printed <- capture.output(print(result))
  expect_true(any(grepl("Fake metadata line", printed)))
})
