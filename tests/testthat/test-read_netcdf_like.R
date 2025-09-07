skip_if_not("read_abares_netcdf" %in% ls(getNamespace("read.abares")))

test_that("NetCDF-like reader: x provided => parser mocked; no download", {
  testthat::skip_if_not_installed("stars")
  tmp <- withr::local_tempfile()
  writeLines("placeholder", tmp)

  testthat::local_mocked_bindings(
    .retry_download = function(...) stop("should not run")
  )
  testthat::local_mocked_bindings(
    read_ncdf = function(...) fake_stars(),
    .package = "stars"
  )

  out <- read_abares_netcdf(tmp)
  expect_true(inherits(out, "stars"))
})

test_that("NetCDF-like reader: x=NULL => download + parse mocked", {
  testthat::skip_if_not_installed("stars")

  testthat::local_mocked_bindings(.retry_download = function(url, .f) {
    writeLines("placeholder", .f)
    invisible(NULL)
  })
  testthat::local_mocked_bindings(
    read_ncdf = function(...) fake_stars(),
    .package = "stars"
  )

  out <- read_abares_netcdf()
  expect_true(inherits(out, "stars"))
})
