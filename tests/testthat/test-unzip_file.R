test_that("unzips a valid zip file into a named folder", {
  skip_if_offline()

  # Create a temp directory and file to zip
  tmp_dir <- withr::local_tempdir()
  file_path <- fs::path(tmp_dir, "test.txt")
  writeLines("hello world", file_path)

  # Create zip
  zip_path <- fs::path(tempdir(), "test-zip.zip")
  utils::zip(zipfile = zip_path, files = file_path, flags = "-j")

  # Sanity
  expect_true(fs::file_exists(zip_path))

  # Run unzip
  expect_invisible(.unzip_file(zip_path))

  # Check extracted folder
  extract_dir <- fs::path_ext_remove(zip_path)
  expect_true(fs::dir_exists(extract_dir))

  # Check contents
  extracted_file <- fs::path(extract_dir, "test.txt")
  expect_true(fs::file_exists(extracted_file))
  expect_identical(readLines(extracted_file), "hello world")
})


test_that("safe_delete deletes files and directories", {
  skip_if_offline()

  # File deletion
  tmp_file <- withr::local_tempfile()
  writeLines("delete me", tmp_file)
  expect_true(fs::file_exists(tmp_file))
  expect_true(.safe_delete(tmp_file))
  expect_false(fs::file_exists(tmp_file))

  # Directory deletion
  tmp_dir <- withr::local_tempdir()
  file_in_dir <- fs::path(tmp_dir, "file.txt")
  writeLines("delete me too", file_in_dir)
  expect_true(fs::dir_exists(tmp_dir))
  expect_true(.safe_delete(tmp_dir))
  expect_false(fs::dir_exists(tmp_dir))
})

test_that("safe_delete returns TRUE for non-existent paths", {
  skip_if_offline()

  bogus <- fs::path(tempdir(), "does-not-exist")
  expect_true(.safe_delete(bogus))
})
