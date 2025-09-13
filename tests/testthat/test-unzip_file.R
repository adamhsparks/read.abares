test_that(".unzip_file fails and deletes bad zip", {
  zip_path <- tempfile(fileext = ".zip")
  fs::file_create(zip_path)

  # Mock utils::unzip to throw an error
  testthat::local_mocked_bindings(
    unzip = function(...) stop("Simulated unzip failure"),
    .env = asNamespace("utils")
  )

  # Mock .safe_delete to track deletion
  deleted <- NULL
  testthat::local_mocked_bindings(
    .safe_delete = function(x) {
      deleted <<- x
    },
    .env = asNamespace("read.abares")
  )

  expect_error(read.abares:::.unzip_file(zip_path), class = "rlang_error")
  expect_equal(deleted, zip_path)
})

test_that(".safe_delete deletes only existing files", {
  existing <- tempfile()
  missing <- tempfile()

  fs::file_create(existing)

  deleted <- character()
  testthat::local_mocked_bindings(
    fs::file_delete = function(x) {
      deleted <<- c(deleted, x)
    },
    .env = asNamespace("fs")
  )

  read.abares:::.safe_delete(c(existing, missing))

  expect_equal(deleted, existing)
})
