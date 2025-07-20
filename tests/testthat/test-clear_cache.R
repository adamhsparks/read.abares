withr::local_envvar(R_USER_CACHE_DIR = tempdir())
test_that("clearing the cache deletes files", {
  temp_cache <- fs::path(tempdir(), "R/read.abares/")
  fs::dir_create(temp_cache, recurse = TRUE)
  file.create(fs::path(temp_cache, "test.txt"))
  withr::local_options(
    list(read.abares.cache_location = temp_cache),
    getOption("read.abares.cache_location")
  )
  expect_no_message(clear_cache())
  expect_message(clear_cache())
})
withr::deferred_run()
