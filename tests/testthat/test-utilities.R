test_that("unzips a valid zip file into a named folder", {
  tmp_dir <- withr::local_tempdir()
  src_file <- fs::path(tmp_dir, "test.txt")
  writeLines("hello world", src_file)

  zip_path <- fs::path_abs(fs::path(tempdir(), "test-zip.zip"))
  zip::zipr(
    zipfile = zip_path,
    files = fs::path_file(src_file),
    root = fs::path_dir(src_file)
  )
  expect_true(fs::file_exists(zip_path))

  out_dir <- .unzip_file(zip_path)
  expect_type(out_dir, "character") # MUST be character
  expect_true(fs::dir_exists(out_dir))
  expect_identical(out_dir, as.character(fs::path_ext_remove(zip_path)))

  extracted_file <- fs::path(out_dir, "test.txt")
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
    src_dir <- fs::path("test_content")
    fs::dir_create(src_dir)

    src_file <- fs::path(src_dir, "test_file.txt")
    writeLines("test content", src_file)

    # Absolute zip path inside src_dir; files added relative to root=
    zip_path <- fs::path_abs(fs::path(src_dir, "test.zip"))
    zip::zipr(
      zipfile = zip_path,
      files = fs::path_file(src_file),
      root = fs::path_dir(src_file)
    )
    expect_true(fs::file_exists(zip_path))

    result_dir <- .unzip_file(zip_path)
    expect_type(result_dir, "character")
    expect_true(fs::dir_exists(result_dir))

    # Directory name should be the stem of "test.zip"
    expect_identical(fs::path_file(result_dir), "test")
  })
})

test_that(".unzip_file handles corrupted zip file without creating directories", {
  withr::with_tempdir({
    corrupted_zip <- fs::path("corrupted.zip")
    writeLines("not a zip file at all", corrupted_zip)

    # Cross-OS error variants from libzip / {zip}
    expect_error(
      .unzip_file(corrupted_zip),
      regexp = "(Unrecognized archive format|Cannot open zip file .* for reading|zip error|End-of-central-directory signature not found)"
    )

    # No extraction directory should be created
    extract_dir <- fs::path_ext_remove(corrupted_zip)
    expect_false(fs::dir_exists(extract_dir))
  })
})

test_that(".unzip_file handles missing zip file", {
  withr::with_tempdir({
    non_existent <- fs::path("absolutely_does_not_exist.zip")
    expect_error(.unzip_file(non_existent), "Zip file does not exist")

    extract_dir <- fs::path_ext_remove(non_existent)
    expect_false(fs::dir_exists(extract_dir))
  })
})

test_that(".unzip_file creates extract directory with correct name", {
  withr::with_tempdir({
    src_dir <- fs::path("source")
    fs::dir_create(src_dir)
    src_file <- fs::path(src_dir, "data.txt")
    fs::file_create(src_file)

    zip_path <- fs::path_abs(fs::path(src_dir, "my_special_data_file.zip"))
    zip::zipr(
      zipfile = zip_path,
      files = fs::path_file(src_file),
      root = fs::path_dir(src_file)
    )
    expect_true(fs::file_exists(zip_path))

    result_dir <- .unzip_file(zip_path)
    expect_type(result_dir, "character")
    expect_identical(fs::path_file(result_dir), "my_special_data_file")
    expect_true(fs::dir_exists(result_dir))
  })
})

test_that(".unzip_file overwrites existing extraction directory", {
  withr::with_tempdir({
    src_dir <- fs::path("content")
    fs::dir_create(src_dir)
    file1 <- fs::path(src_dir, "file.txt")
    writeLines("original content", file1)

    zip_path <- fs::path_abs(fs::path(src_dir, "test.zip"))
    zip::zipr(
      zipfile = zip_path,
      files = fs::path_file(file1),
      root = fs::path_dir(file1)
    )
    expect_true(fs::file_exists(zip_path))

    result1 <- .unzip_file(zip_path)
    expect_type(result1, "character")
    expect_true(fs::dir_exists(result1))

    # Modify the extracted content to verify overwrite
    writeLines("modified content", fs::path(result1, "file.txt"))

    # Re-zip with different content
    writeLines("new content", file1)
    fs::file_delete(zip_path)
    zip::zipr(
      zipfile = zip_path,
      files = fs::path_file(file1),
      root = fs::path_dir(file1)
    )
    expect_true(fs::file_exists(zip_path))

    result2 <- .unzip_file(zip_path)
    expect_identical(result1, result2)
    expect_identical(readLines(fs::path(result2, "file.txt")), "new content")
  })
})
