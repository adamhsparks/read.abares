has_read <- "read_aagis_regions" %in% ls(getNamespace("read.abares"))
has_get <- "get_aagis_regions" %in% ls(getNamespace("read.abares"))
skip_if_not(has_read || has_get)

call_aagis <- function(...) {
  if (has_read) read_aagis_regions(...) else get_aagis_regions(...)
}

# Valid sf for tests (geometry present)
fake_sf <- function(n = 2L) {
  xs <- 115 + seq_len(n) * 0.01
  ys <- -31 - seq_len(n) * 0.01
  pts <- sf::st_sfc(
    lapply(seq_len(n), \(i) sf::st_point(c(xs[i], ys[i]))),
    crs = 4326
  )
  sf::st_sf(id = seq_len(n), name = c("A", "B")[seq_len(n)], geometry = pts)
}

test_that("AAGIS: provided path => unzip + read mocked", {
  testthat::skip_if_not_installed("sf")

  tmp_zip <- withr::local_tempfile(fileext = ".zip")
  writeLines("zip", tmp_zip)
  exdir <- withr::local_tempdir()
  shp <- file.path(exdir, "aagis.shp")

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
  expect_true("geometry" %in% names(out) || !is.null(attr(out, "sf_column")))
})

test_that("AAGIS: x=NULL => mocked download + unzip + read", {
  testthat::skip_if_not_installed("sf")

  exdir <- withr::local_tempdir()
  shp <- file.path(exdir, "aagis.shp")

  testthat::local_mocked_bindings(
    .retry_download = function(url, .f) {
      writeLines("zip", .f)
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

test_that("AAGIS: controlled failure at read", {
  testthat::skip_if_not_installed("sf")

  exdir <- withr::local_tempdir()
  shp <- file.path(exdir, "aagis.shp")

  testthat::local_mocked_bindings(
    .retry_download = function(url, .f) {
      writeLines("zip", .f)
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
    st_read = function(...) stop("network fail"),
    .package = "sf"
  )

  expect_error(call_aagis(), "network fail")
})
