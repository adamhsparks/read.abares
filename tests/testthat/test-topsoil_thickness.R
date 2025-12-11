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

zipfile <- make_fake_topsoil_zip()

test_that("read_topsoil_thickness_stars returns a stars object with correct dimensions", {
  result <- read_topsoil_thickness_stars(x = zipfile)
  expect_s3_class(result, "stars")
  expect_identical(unname(dim(result)), c(2L, 2L))
})

test_that("read_topsoil_thickness_stars works with NULL x and mocked download", {
  fake_retry_download <- function(url, dest) {
    file.copy(zipfile, dest, overwrite = TRUE)
  }
  with_mocked_bindings(
    result <- read_topsoil_thickness_stars(x = NULL),
    .retry_download = fake_retry_download
  )
  expect_s3_class(result, "stars")
  expect_identical(unname(dim(result)), c(2L, 2L))
})

test_that("read_topsoil_thickness_terra returns a SpatRaster with correct dimensions", {
  result <- read_topsoil_thickness_terra(x = zipfile)
  expect_s4_class(result, "SpatRaster")
  expect_identical(dim(result), c(2, 2, 1))
})

test_that("read_topsoil_thickness_terra works with NULL x and mocked download", {
  fake_retry_download <- function(url, dest) {
    file.copy(zipfile, dest, overwrite = TRUE)
  }
  with_mocked_bindings(
    result <- read_topsoil_thickness_terra(x = NULL),
    .retry_download = fake_retry_download
  )
  expect_s4_class(result, "SpatRaster")
  expect_identical(dim(result), c(2, 2, 1))
})
