.onLoad <- function(libname, pkgname) {
  # save options for non-read.abares options for resetting after package exits
  op <- options()
  read.abares_env <- new.env(parent = emptyenv())
  read.abares_env$old_options <- op[
    names(op) %in%
      c(
        "rlib_message_verbosity",
        "rlib_warning_verbosity",
        "warn",
        "datatable.showProgress"
      )
  ]
  assign(".read.abares_env", read.abares_env, envir = parent.env(environment()))

  op.read.abares <- list(
    read.abares.user_agent = read.abares_user_agent(),
    read.abares.timeout = 2000L,
    read.abares.max_tries = 3L,
    read.abares.verbosity = "verbose"
  )
  toset <- !(names(op.read.abares) %in% names(op))
  if (any(toset)) {
    options(op.read.abares[toset])
  }

  verbosity <- getOption("read.abares.verbosity")
  rlib_message_level <- switch(
    verbosity,
    "quiet" = "quiet",
    "minimal" = "minimal",
    "verbose" = "verbose",
    "verbose"
  )
  rlib_warning_level <- switch(
    verbosity,
    "quiet" = "quiet",
    "minimal" = "verbose",
    "verbose" = "verbose",
    "verbose"
  )
  warn_level <- switch(
    verbosity,
    "quiet" = -1L,
    "minimal" = 0L,
    "verbose" = 0L
  )
  fread_level <- switch(
    verbosity,
    "quiet" = FALSE,
    "minimal" = FALSE,
    "verbose" = TRUE
  )
  options(
    rlib_message_verbosity = rlib_message_level,
    rlib_warning_verbosity = rlib_warning_level,
    warn = warn_level,
    datatable.showProgress = fread_level
  )
}

.onUnload <- function(libpath) {
  if (exists(".read.abares_env", envir = parent.env(environment()))) {
    old_opts <- get(
      ".read.abares_env",
      envir = parent.env(environment())
    )$old_options
    options(old_opts)
  }
}
test_that("reads from a provided local zip file and returns a terra rast object", {
  skip_if_offline()
  skip_if_not_installed("terra")

  # Create a valid dummy GeoTIFF using terra
  temp_dir <- withr::local_tempdir()
  tif_path <- fs::path(
    temp_dir,
    "NLUM_v7_250_ALUMV8_2020_21_alb_package_20241128",
    "dummy.tif"
  )
  fs::dir_create(fs::path_dir(tif_path))
  r <- terra::rast(nrows = 10, ncols = 10, vals = 1:100)
  terra::writeRaster(r, tif_path, overwrite = TRUE)

  zip_path <- fs::path(
    temp_dir,
    "NLUM_v7_250_ALUMV8_2020_21_alb_package_20241128.zip"
  )
  utils::zip(zipfile = zip_path, files = tif_path, flags = "-j")

  # Mock .get_nlum to return the path to the dummy tif
  with_mocked_bindings(
    {
      out <- read_nlum_terra(x = zip_path)
      expect_s4_class(out, "SpatRaster")
    },
    .get_nlum = function(.data_set = NULL, .x = NULL) {
      return(tif_path)
    }
  )
})

test_that("downloads when x is NULL and reads terra rast object", {
  skip_if_offline()
  skip_if_not_installed("terra")

  temp_dir <- withr::local_tempdir()
  tif_path <- fs::path(
    temp_dir,
    "NLUM_v7_250_ALUMV8_2020_21_alb_package_20241128",
    "dummy.tif"
  )
  fs::dir_create(fs::path_dir(tif_path))
  r <- terra::rast(nrows = 10L, ncols = 10L, vals = 1L:100L)
  terra::writeRaster(r, tif_path, overwrite = TRUE)

  zip_path <- fs::path(
    temp_dir,
    "NLUM_v7_250_ALUMV8_2020_21_alb_package_20241128.zip"
  )

  last_url <- NULL
  retry_mock <- function(url, .f) {
    last_url <<- url
    file.create(.f)
    invisible(.f)
  }

  with_mocked_bindings(
    {
      out <- read_nlum_terra(data_set = "Y202021")
      expect_s4_class(out, "SpatRaster")
    },
    .get_nlum = function(.data_set = NULL, .x = NULL) {
      return(tif_path)
    },
    .retry_download = retry_mock,
    .unzip_file = function(x) NULL
  )
})

test_that("errors cleanly when file does not exist", {
  skip_if_offline()
  skip_if_not_installed("terra")

  bogus <- fs::path(tempdir(), "no-such-nlum.zip")
  if (fs::file_exists(bogus)) {
    fs::file_delete(bogus)
  }

  with_mocked_bindings(
    {
      expect_error(
        read_nlum_terra(x = bogus),
        regexp = "cannot open|does not exist|Failed to open|cannot find",
        ignore.case = TRUE
      )
    },
    .get_nlum = function(.x = NULL, ...) {
      stop("Failed to open file")
    }
  )
})
