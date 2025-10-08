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

test_that("print.read.abares.topsoil.thickness prints correctly", {
  # Create a mock object
  mock_obj <- structure(
    list(
      metadata = "Test metadata content",
      data = terra::rast(nrows = 2, ncols = 2)
    ),
    class = c("read.abares.topsoil.thickness", "list")
  )

  # Use snapshot testing for cli output
  expect_snapshot(print.read.abares.topsoil.thickness(mock_obj))
})

test_that("print_topsoil_thickness_metadata displays complete metadata", {
  # Create metadata with Custodian marker
  metadata_content <- paste(
    "Some initial content",
    "Custodian: CSIRO Land & Water",
    "Additional metadata content",
    "More details about the dataset",
    sep = "\n"
  )

  mock_obj <- structure(
    list(
      metadata = metadata_content,
      data = terra::rast(nrows = 2, ncols = 2)
    ),
    class = c("read.abares.topsoil.thickness", "list")
  )

  expect_snapshot({
    print_topsoil_thickness_metadata(mock_obj)
  })
})

test_that("print_topsoil_thickness_metadata returns invisible NULL", {
  mock_obj <- structure(
    list(
      metadata = "Some content\nCustodian: Test\nMore content",
      data = terra::rast(nrows = 2, ncols = 2)
    ),
    class = c("read.abares.topsoil.thickness", "list")
  )

  returned_obj <- withVisible(print_topsoil_thickness_metadata(mock_obj))
  expect_null(returned_obj$value)
  expect_false(returned_obj$visible)
})

test_that(".unzip_file successfully unzips valid zip file", {
  withr::with_tempdir({
    # Create test content
    test_dir <- fs::path("test_content")
    fs::dir_create(test_dir)

    test_file <- fs::path(test_dir, "test_file.txt")
    writeLines("test content", test_file)

    # Create zip
    test_zip <- fs::path("test.zip")
    withr::with_dir(test_dir, {
      utils::zip(zipfile = file.path("..", "test.zip"), files = list.files())
    })

    # Test unzip
    result_dir <- .unzip_file(test_zip)

    expect_true(fs::dir_exists(result_dir))
    expect_true(fs::file_exists(fs::path(result_dir, "test_file.txt")))
    expect_equal(fs::path_file(result_dir), "test")
  })
})

test_that(".unzip_file handles corrupted zip file without creating directories", {
  withr::with_tempdir({
    # Create corrupted zip
    corrupted_zip <- fs::path("corrupted.zip")
    writeLines("not a zip file at all", corrupted_zip)

    expect_error(
      .unzip_file(corrupted_zip),
      "Unrecognized archive format"
    )

    # Check that no extraction directory was created
    extract_dir <- fs::path_ext_remove(corrupted_zip)
    expect_false(fs::dir_exists(extract_dir))
  })
})

test_that(".unzip_file handles missing zip file", {
  withr::with_tempdir({
    non_existent <- fs::path("absolutely_does_not_exist.zip")

    expect_error(
      .unzip_file(non_existent),
      "Zip file does not exist"
    )

    # Verify the extraction directory was not created
    extract_dir <- fs::path_ext_remove(non_existent)
    expect_false(fs::dir_exists(extract_dir))
  })
})

test_that(".unzip_file creates extract directory with correct name", {
  withr::with_tempdir({
    # Create test zip with specific name
    test_dir <- fs::path("source")
    fs::dir_create(test_dir)
    fs::file_create(fs::path(test_dir, "data.txt"))

    test_zip <- fs::path("my_special_data_file.zip")
    withr::with_dir(test_dir, {
      utils::zip(
        zipfile = file.path("..", "my_special_data_file.zip"),
        files = list.files()
      )
    })

    result_dir <- .unzip_file(test_zip)

    expect_identical(fs::path_file(result_dir), "my_special_data_file")
    expect_true(fs::dir_exists(result_dir))
  })
})

test_that(".unzip_file overwrites existing extraction directory", {
  withr::with_tempdir({
    # Setup initial content
    test_dir <- fs::path("content")
    fs::dir_create(test_dir)
    writeLines("original content", fs::path(test_dir, "file.txt"))

    test_zip <- fs::path("test.zip")
    withr::with_dir(test_dir, {
      utils::zip(zipfile = file.path("..", "test.zip"), files = list.files())
    })

    # First extraction
    result1 <- .unzip_file(test_zip)

    # Modify the extracted content to verify overwrite
    writeLines("modified content", fs::path(result1, "file.txt"))

    # Create new zip with different content
    writeLines("new content", fs::path(test_dir, "file.txt"))
    fs::file_delete(test_zip)

    withr::with_dir(test_dir, {
      utils::zip(zipfile = file.path("..", "test.zip"), files = list.files())
    })

    # Second extraction should overwrite
    result2 <- .unzip_file(test_zip)

    expect_identical(result1, result2)
    content <- readLines(fs::path(result2, "file.txt"))
    expect_identical(content, "new content")
  })
})
