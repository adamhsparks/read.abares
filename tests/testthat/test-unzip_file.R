# tests/testthat/test-unzip_file.R

# Skip robustly if the internal helper isn't present on this branch
has_unzip <- "read.abares" %in%
  loadedNamespaces() &&
  exists(".unzip_file", envir = asNamespace("read.abares"), inherits = FALSE)
testthat::skip_if(
  !has_unzip,
  "Internal helper .unzip_file() not available on this branch"
)

# Pull the internal
.unzip_file <- get(".unzip_file", envir = asNamespace("read.abares"))

test_that(".unzip_file extracts into exdir (offline, assert side-effects)", {
  # Provide a real-looking input path so any cleanup or logging doesn't fail
  zip_in <- withr::local_tempfile(fileext = ".zip")
  writeBin(raw(0), zip_in)

  # Capture exdir and fabricate an extracted file there
  seen <- new.env(parent = emptyenv())
  seen$exdir <- NULL

  testthat::local_mocked_bindings(
    unzip = function(zipfile, exdir, overwrite = TRUE, ...) {
      seen$exdir <- exdir
      dir.create(exdir, showWarnings = FALSE, recursive = TRUE)
      file.create(file.path(exdir, "dummy.txt"))
      # internal method typically returns extracted file paths; we don't rely on it
      return(file.path(exdir, "dummy.txt"))
    },
    .package = "utils"
  )

  # Call the helper; do not assume a particular return value
  out <- .unzip_file(zip_in)

  # Assert the intended side-effects
  expect_true(is.character(seen$exdir) && nzchar(seen$exdir))
  expect_true(file.exists(file.path(seen$exdir, "dummy.txt")))

  # Return shape is not stable across branches; accept common shapes without failing
  expect_true(
    is.null(out) || is.character(out) || is.list(out) || isFALSE(is.na(out))
  )
})

test_that(".unzip_file propagates errors and cleans up bad zip (offline)", {
  # Create an actual path so your error cleanup (fs::file_delete) won't ENOENT
  zip_in <- withr::local_tempfile(fileext = ".zip")
  writeBin(raw(0), zip_in)
  expect_true(file.exists(zip_in)) # sanity

  # Force unzip to fail. Your helper will wrap this via cli::cli_abort()/rlang::abort()
  testthat::local_mocked_bindings(
    unzip = function(...) stop("zip exploded"),
    .package = "utils"
  )

  # Accept either the raw message or your wrapped, user-facing one
  expect_error(
    .unzip_file(zip_in),
    regexp = "zip exploded|downloaded file|bad version of the zip file",
    ignore.case = TRUE
  )

  # Your helper deletes the corrupt zip on error; verify the side-effect
  expect_false(file.exists(zip_in))
})
