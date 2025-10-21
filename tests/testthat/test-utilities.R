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
