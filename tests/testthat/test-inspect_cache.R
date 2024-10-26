
withr::local_envvar(R_USER_CACHE_DIR = file.path(tempdir()))
dir.create(file.path(.find_user_cache()), recursive = TRUE)
test_file <- file.path(.find_user_cache(), "test.R")
test_that("inspect_cache() works, recursive = FALSE", {
  file.create(test_file)

  f <- .find_user_cache()
  f <- list.files(f, full.names = TRUE)
  expect_identical(inspect_cache() |>
                     capture_output(),
                   f |> capture_output()
  )
})

test_that("inspect_cache() works, recursive = TRUE", {
  file.create(test_file)

  f <- .find_user_cache()
  f <- list.files(f, recursive = TRUE, full.names = TRUE)
  expect_identical(inspect_cache(recursive = TRUE) |>
                     capture_output(),
                   f |> capture_output()
  )
})

withr::deferred_run()
