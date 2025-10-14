test_that("unzips a valid zip file into a named folder", {
  # Create a temp directory and file to zip
  tmp_dir <- withr::local_tempdir()
  src_file <- fs::path(tmp_dir, "test.txt")
  writeLines("hello world", src_file)

  # Create zip at a known absolute path in tempdir
  zip_path <- fs::path(tempdir(), "test-zip.zip")
  withr::with_dir(fs::path_dir(src_file), {
    zip::zipr(zipfile = zip_path, files = fs::path_file(src_file))
  })

  # Sanity
  expect_true(fs::file_exists(zip_path))

  # Run unzip (returns extraction dir invisibly)
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
  bogus <- fs::path(tempdir(), "does-not-exist")
  expect_true(.safe_delete(bogus))
})

test_that(".unzip_file successfully unzips valid zip file", {
  withr::with_tempdir({
    # Create test content
    src_dir <- fs::path("test_content")
    fs::dir_create(src_dir)

    src_file <- fs::path(src_dir, "test_file.txt")
    writeLines("test content", src_file)

    # Create zip INSIDE src_dir; use absolute path so we can find it later
    zipfile <- fs::path(src_dir, "test.zip")
    withr::with_dir(fs::path_dir(src_file), {
      zip::zipr(zipfile = zipfile, files = fs::path_file(src_file))
    })

    # Sanity
    expect_true(fs::file_exists(zipfile))

    # Test unzip
    result_dir <- .unzip_file(zipfile)

    expect_true(fs::dir_exists(result_dir))
    expect_true(fs::file_exists(fs::path(result_dir, "test_file.txt")))
    expect_identical(fs::path_file(result_dir), "test")
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
    src_dir <- fs::path("source")
    fs::dir_create(src_dir)
    src_file <- fs::path(src_dir, "data.txt")
    fs::file_create(src_file)

    # Put the zip inside source dir so we know exactly where it is
    zipfile <- fs::path(src_dir, "my_special_data_file.zip")
    withr::with_dir(fs::path_dir(src_file), {
      zip::zipr(zipfile = zipfile, files = fs::path_file(src_file))
    })

    # Sanity
    expect_true(fs::file_exists(zipfile))

    result_dir <- .unzip_file(zipfile)

    expect_identical(fs::path_file(result_dir), "my_special_data_file")
    expect_true(fs::dir_exists(result_dir))
  })
})

test_that(".unzip_file overwrites existing extraction directory", {
  withr::with_tempdir({
    # Setup initial content
    src_dir <- fs::path("content")
    fs::dir_create(src_dir)
    file1 <- fs::path(src_dir, "file.txt")
    writeLines("original content", file1)

    # Zip inside src_dir; absolute path avoids cwd confusion
    zipfile <- fs::path(src_dir, "test.zip")
    withr::with_dir(fs::path_dir(file1), {
      zip::zipr(zipfile = zipfile, files = fs::path_file(file1))
    })

    # Sanity
    expect_true(fs::file_exists(zipfile))

    # First extraction
    result1 <- .unzip_file(zipfile)

    # Modify the extracted content to verify overwrite
    writeLines("modified content", fs::path(result1, "file.txt"))

    # Create new zip with different content
    writeLines("new content", file1)
    fs::file_delete(zipfile)
    withr::with_dir(fs::path_dir(file1), {
      zip::zipr(zipfile = zipfile, files = fs::path_file(file1))
    })

    # Sanity again
    expect_true(fs::file_exists(zipfile))

    # Second extraction should overwrite
    result2 <- .unzip_file(zipfile)

    expect_identical(result1, result2)
    content <- readLines(fs::path(result2, "file.txt"))
    expect_identical(content, "new content")
  })
})
