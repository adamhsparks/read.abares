# Helper function to create valid test raster files
create_test_raster <- function(path, nrows = 10, ncols = 10) {
  raster <- terra::rast(
    nrows = nrows,
    ncols = ncols,
    xmin = 140,
    xmax = 150,
    ymin = -40,
    ymax = -30
  )
  terra::values(raster) <- runif(nrows * ncols, 100, 2000)
  terra::writeRaster(raster, path, overwrite = TRUE, filetype = "GTiff")
  return(raster)
}

# Helper function to create realistic metadata
create_test_metadata <- function(path) {
  metadata_content <- paste(
    "Australian Soil Thickness Data",
    "Dataset ANZLIC ID ANZCW1202000149",
    "",
    "Custodian: CSIRO Land & Water",
    "Jurisdiction: Australia",
    "",
    "Feature attribute definition: Predicted average Thickness (mm) of soil layer 1",
    "Data Type: RASTER",
    "Datum: WGS84",
    sep = "\n"
  )

  writeLines(metadata_content, path)
  return(metadata_content)
}

test_that(".get_topsoil_thickness works with valid zip file", {
  withr::with_tempdir({
    # Create test directory structure that matches expected format
    test_dir <- fs::path("test_topsoil")
    fs::dir_create(test_dir)

    # Create the expected raster file (thpk_1 without extension)
    test_raster_path <- fs::path(test_dir, "thpk_1.tif")
    create_test_raster(test_raster_path)

    # Rename to remove .tif extension to match expected format
    expected_raster_path <- fs::path(test_dir, "thpk_1")
    fs::file_move(test_raster_path, expected_raster_path)

    # Create test metadata file
    metadata_path <- fs::path(test_dir, "ANZCW1202000149.txt")
    create_test_metadata(metadata_path)

    # Create zip file using base R zip with withr::with_dir
    test_zip <- fs::path("test_topsoil.zip")
    withr::with_dir(test_dir, {
      utils::zip(
        zipfile = file.path("..", "test_topsoil.zip"),
        files = list.files()
      )
    })

    # Test the function
    result <- .get_topsoil_thickness(.x = test_zip)

    expect_s3_class(result, "read.abares.topsoil.thickness")
    expect_type(result, "list")
    expect_named(result, c("metadata", "data"))
    expect_type(result$metadata, "character")
    expect_s4_class(result$data, "SpatRaster")
    expect_gt(nchar(result$metadata), 0L)
    expect_true(grepl("CSIRO Land & Water", result$metadata))
  })
})

test_that(".get_topsoil_thickness returns correct class structure", {
  withr::with_tempdir({
    # Setup valid test data
    test_dir <- fs::path("topsoil_test")
    fs::dir_create(test_dir)

    raster_path <- fs::path(test_dir, "thpk_1.tif")
    create_test_raster(raster_path, nrows = 5, ncols = 5)
    fs::file_move(raster_path, fs::path(test_dir, "thpk_1"))

    metadata_path <- fs::path(test_dir, "ANZCW1202000149.txt")
    create_test_metadata(metadata_path)

    test_zip <- fs::path("structure_test.zip")
    withr::with_dir(test_dir, {
      utils::zip(
        zipfile = file.path("..", "structure_test.zip"),
        files = list.files()
      )
    })

    result <- .get_topsoil_thickness(.x = test_zip)

    expect_s3_class(result, "read.abares.topsoil.thickness")
    expect_type(result, "list")
    expect_length(result, 2L)
    expect_named(result, c("metadata", "data"))

    # Check metadata
    expect_type(result$metadata, "character")
    expect_gt(nchar(result$metadata), 0L)

    # Check raster data
    expect_s4_class(result$data, "SpatRaster")
    expect_identical(terra::nrow(result$data), 5)
    expect_identical(terra::ncol(result$data), 5)
  })
})
