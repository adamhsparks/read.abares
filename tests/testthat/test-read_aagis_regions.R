# tests/testthat/test-read_aagis_regions.R

has_read <- "read_aagis_regions" %in% ls(getNamespace("read.abares"))
has_get <- "get_aagis_regions" %in% ls(getNamespace("read.abares"))
skip_if_not(has_read || has_get)

call_aagis <- function(...)
  if (has_read) read_aagis_regions(...) else get_aagis_regions(...)

test_that("AAGIS: provided path => no download; unzip + parser mocked", {
  testthat::skip_if_not_installed("sf")

  tmp_zip <- withr::local_tempfile(fileext = ".zip")
  writeLines("placeholder", tmp_zip)

  exdir <- withr::local_tempdir()
  shp <- file.path(exdir, "aagis_asgs16v1_g5a.shp")

  testthat::local_mocked_bindings(
    .retry_download = function(...) stop("should not run"),
    .unzip_file = function(x) exdir
  )
  testthat::local_mocked_bindings(dir_ls = function(...) shp, .package = "fs")
  testthat::local_mocked_bindings(
    file_delete = function(x) invisible(x),
    .package = "fs"
  )
  testthat::local_mocked_bindings(
    dir_delete = function(x) invisible(x),
    .package = "fs"
  )
  testthat::local_mocked_bindings(
    st_read = function(dsn, ...) fake_sf(),
    .package = "sf"
  )

  out <- call_aagis(tmp_zip)
  expect_s3_class(out, "sf")
  expect_true(NROW(out) >= 1)
  # geometry present
  expect_true("geometry" %in% names(out) || !is.null(attr(out, "sf_column")))
})

test_that("AAGIS: x=NULL => download mocked; unzip + parser mocked", {
  testthat::skip_if_not_installed("sf")

  exdir <- withr::local_tempdir()
  shp <- file.path(exdir, "aagis_asgs16v1_g5a.shp")

  testthat::local_mocked_bindings(
    .retry_download = function(url, .f) {
      writeLines("placeholder", .f)
      invisible(NULL)
    },
    .unzip_file = function(x) exdir
  )
  testthat::local_mocked_bindings(dir_ls = function(...) shp, .package = "fs")
  testthat::local_mocked_bindings(
    file_delete = function(x) invisible(x),
    .package = "fs"
  )
  testthat::local_mocked_bindings(
    dir_delete = function(x) invisible(x),
    .package = "fs"
  )
  testthat::local_mocked_bindings(
    st_read = function(dsn, ...) fake_sf(),
    .package = "sf"
  )

  out <- call_aagis()
  expect_s3_class(out, "sf")
  expect_true(NROW(out) >= 1)
})

test_that("AAGIS: failure path surfaces a readable error", {
  testthat::skip_if_not_installed("sf")

  exdir <- withr::local_tempdir()
  shp <- file.path(exdir, "aagis_asgs16v1_g5a.shp")

  testthat::local_mocked_bindings(
    .retry_download = function(url, .f) {
      writeLines("placeholder", .f)
      invisible(NULL)
    },
    .unzip_file = function(x) exdir
  )
  testthat::local_mocked_bindings(dir_ls = function(...) shp, .package = "fs")
  testthat::local_mocked_bindings(
    file_delete = function(x) invisible(x),
    .package = "fs"
  )
  testthat::local_mocked_bindings(
    dir_delete = function(x) invisible(x),
    .package = "fs"
  )
  # Force a clear, controlled error at parser call:
  testthat::local_mocked_bindings(
    st_read = function(...) stop("network fail"),
    .package = "sf"
  )

  expect_error(call_aagis(), "network fail")
})
