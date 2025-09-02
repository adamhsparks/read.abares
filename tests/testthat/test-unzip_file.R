test_that(".unzip_file works with valid zip file", {
  # Create a temporary zip file for testing
  temp_dir <- tempdir()
  zip_file <- fs::path(temp_dir, "test.zip")
  test_file <- fs::path(temp_dir, "test.txt")
  
  # Create test content
  writeLines("test content", test_file)
  
  # Create zip file
  withr::with_dir(temp_dir, {
    zip(zip_file, "test.txt", flags = "-q")
  })
  
  # Remove original file
  fs::file_delete(test_file)
  
  # Test that unzip_file works
  expect_no_error(.unzip_file(zip_file))
  
  # Check that file was extracted
  expect_true(fs::file_exists(fs::path(fs::path_ext_remove(zip_file), "test.txt")))
  
  # Clean up
  fs::file_delete(zip_file)
  fs::dir_delete(fs::path_ext_remove(zip_file))
})

test_that(".unzip_file handles corrupted zip file", {
  # Create a fake corrupted zip file
  temp_dir <- tempdir()
  corrupt_zip <- fs::path(temp_dir, "corrupt.zip")
  
  # Write invalid zip content
  writeLines("This is not a valid zip file", corrupt_zip)
  
  # Mock the error case
  expect_error(
    .unzip_file(corrupt_zip),
    "There was an issue with the downloaded file"
  )
  
  # Check that corrupted file was deleted
  expect_false(fs::file_exists(corrupt_zip))
})

test_that(".unzip_file returns invisible NULL", {
  # Create a valid test zip
  temp_dir <- tempdir()
  zip_file <- fs::path(temp_dir, "test_return.zip")
  test_file <- fs::path(temp_dir, "test_return.txt")
  
  writeLines("test content", test_file)
  
  withr::with_dir(temp_dir, {
    zip(zip_file, "test_return.txt", flags = "-q")
  })
  
  fs::file_delete(test_file)
  
  # Test return value
  result <- .unzip_file(zip_file)
  expect_null(result)
  expect_invisible(result)
  
  # Clean up
  fs::file_delete(zip_file)
  fs::dir_delete(fs::path_ext_remove(zip_file))
})