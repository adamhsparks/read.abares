skip_if_not("read_nlum" %in% ls(getNamespace("read.abares")))
testthat::skip_if_not_installed("terra")

call_read_nlum <- function(...){
  fn <- get("read_nlum", envir = asNamespace("read.abares"))
  do.call(fn, list(...))
}

test_that("NLUM: x=NULL => mocked curl::curl_download creates a real .zip; terra::rast mocked", {
  r0 <- build_dummy_spatraster()

  # Mock curl_download to create a real zip containing a placeholder tif
  testthat::local_mocked_bindings(
    curl_download = function(url, destfile, quiet = TRUE, ...) {
      stage <- withr::local_tempdir()
      tif   <- file.path(stage, "nlum.tif")
      writeLines("tif-bytes", tif)
      dir.create(dirname(destfile), showWarnings = FALSE, recursive = TRUE)
      old <- setwd(stage); on.exit(setwd(old), add = TRUE)
      utils::zip(zipfile = destfile, files = basename(tif))
      invisible(destfile)
    },
    .package = "curl"
  )
  testthat::local_mocked_bindings(rast = function(x, ...) r0, .package = "terra")

  out <- call_read_nlum()
  expect_true(inherits(out, "SpatRaster") || is.list(out))
})

test_that("NLUM: provided path (.zip) => unzip runs; terra::rast mocked", {
  r0 <- build_dummy_spatraster()

  tmp_zip <- withr::local_tempfile(fileext = ".zip")
  stage   <- withr::local_tempdir()
  tif     <- file.path(stage, "nlum.tif")
  writeLines("tif", tif)
  old <- setwd(stage); on.exit(setwd(old), add = TRUE)
  utils::zip(zipfile = tmp_zip, files = basename(tif))

  testthat::local_mocked_bindings(.retry_download = function(...) stop(".retry_download should not be called"))
  testthat::local_mocked_bindings(rast = function(x, ...) r0, .package = "terra")

  out <- call_read_nlum(x = tmp_zip)
  expect_true(inherits(out, "SpatRaster") || is.list(out))
})

test_that("NLUM: download failure is surfaced", {
  testthat::local_mocked_bindings(curl_download = function(...) stop("timeout"), .package = "curl")
  expect_error(call_read_nlum(), "timeout")
})
