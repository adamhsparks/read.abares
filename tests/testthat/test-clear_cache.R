test_that("clearing the cache deletes files", {
  withr::local_envvar(R_USER_CACHE_DIR = tempdir())
  temp_cache <- file.path(tempdir(), "R/read.abares/")
  dir.create(temp_cache, recursive = TRUE)
  file.create(file.path(temp_cache, "test.txt"))
  expect_no_message(clear_cache())
  expect_message(clear_cache())
  withr::deferred_run()
})
