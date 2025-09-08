# tests/testthat/test-read_nlum.R

# If your export is named differently (e.g., read_nlum_terra), change here:
skip_if_not("read_nlum" %in% ls(getNamespace("read.abares")))

testthat::skip_if_not_installed("terra")

# Helper that builds a real in-memory SpatRaster (no disk I/O, no Internet)
build_dummy_spatraster <- function() {
  r <- terra::rast(nrows = 1, ncols = 2, vals = c(1, 2))
  # CRS not strictly needed; harmless if set
  terra::crs(r) <- "EPSG:4326"
  r
}

# (Optional) If the reader validates a 'data_set' argument, set it here; else keep NULL.
# E.g., for CLUM we used "clum_50m_2023_v2"; for NLUM you might have "nlum_2023" or similar.
# If your read_nlum does NOT have data_set, leave nlum_data_set <- NULL and the tests pass it only if the formal exists.
nlum_data_set <- NULL

call_read_nlum <- function(...) {
  fn <- get("read_nlum", envir = asNamespace("read.abares"))
  # pass data_set only if formal exists
  fmls <- names(formals(fn))
  args <- list(...)
  if (
    !is.null(nlum_data_set) && "data_set" %in% fmls && is.null(args$data_set)
  ) {
    args$data_set <- nlum_data_set
  }
  do.call(fn, args)
}

test_that("NLUM: x = NULL => mocked download + unzip + terra::rast (real SpatRaster)", {
  # 1) Create a real SpatRaster that terra ops (e.g., coltab<-) can modify safely
  r0 <- build_dummy_spatraster()

  # 2) Unzip step returns a directory; listing returns a single .tif path
  exdir <- withr::local_tempdir()
  fake_tif <- file.path(exdir, "nlum.tif")
  writeLines("tif-bytes", fake_tif) # never actually read—terra::rast is mocked

  # 3) Mock download/unzip/list
  testthat::local_mocked_bindings(
    .retry_download = function(url, .f) {
      writeLines("zip", .f)
      invisible(NULL)
    },
    .unzip_file = function(x) exdir
  )
  testthat::local_mocked_bindings(
    dir_ls = function(...) fake_tif,
    .package = "fs"
  )

  # 4) The critical bit: mock terra::rast to return our *real* SpatRaster
  testthat::local_mocked_bindings(
    rast = function(x, ...) r0,
    .package = "terra"
  )

  out <- call_read_nlum()
  # Depending on implementation, you might return a SpatRaster or a derived object
  expect_true(inherits(out, "SpatRaster") || is.list(out))
})

test_that("NLUM: provided path (zip) => mocked unzip + terra::rast", {
  r0 <- build_dummy_spatraster()

  # Supply a .zip-looking path (content irrelevant due to mocking)
  tmp_zip <- withr::local_tempfile(fileext = ".zip")
  writeLines("zip", tmp_zip)
  exdir <- withr::local_tempdir()
  fake_tif <- file.path(exdir, "nlum.tif")
  writeLines("tif-bytes", fake_tif)

  testthat::local_mocked_bindings(
    .retry_download = function(...) {
      stop(".retry_download should not be called when x is provided")
    },
    .unzip_file = function(x) exdir
  )
  testthat::local_mocked_bindings(
    dir_ls = function(...) fake_tif,
    .package = "fs"
  )
  testthat::local_mocked_bindings(
    rast = function(x, ...) r0,
    .package = "terra"
  )

  out <- call_read_nlum(x = tmp_zip)
  expect_true(inherits(out, "SpatRaster") || is.list(out))
})

test_that("NLUM: controlled failure on download", {
  testthat::local_mocked_bindings(.retry_download = function(...) {
    stop("timeout")
  })
  expect_error(call_read_nlum(), "timeout")
})
