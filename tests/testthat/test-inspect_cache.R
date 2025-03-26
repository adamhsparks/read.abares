withr::local_envvar(R_USER_CACHE_DIR = tempdir())
# check message with no files present ----

test_that("inspect_cache() works w/ no files", {
  fs::dir_create(.find_user_cache())
  cli_out <- function() {
    return(cli::cli_inform(c(
      "There do not appear to be any files cached for {.pkg {{read.abares}}}."
    )))
  }

  expect_identical(inspect_cache(), cli_out())
})

# Now create a file to check when files are present ----

test_that("inspect_cache() works, recursive = FALSE", {
  test_file <- fs::path(.find_user_cache(), "test.R")
  file.create(test_file)

  f <- .find_user_cache()
  f <- fs::dir_ls(f, full.names = TRUE)
  expect_identical(
    inspect_cache() |>
      capture_output(),
    f |> capture_output()
  )
})

test_that("inspect_cache() works, recursive = TRUE", {
  test_file <- fs::path(.find_user_cache(), "test.R")
  file.create(test_file)

  f <- .find_user_cache()
  f <- fs::dir_ls(f, recurse = TRUE, full.names = TRUE)
  expect_identical(
    inspect_cache(recurse = TRUE) |>
      capture_output(),
    f |> capture_output()
  )
})

withr::deferred_run()
