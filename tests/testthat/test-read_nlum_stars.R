test_that("reads from a provided local zip file and returns a stars object", {
  skip_if_offline()

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
      out <- read_nlum_stars(x = zip_path)
      expect_s3_class(out, "stars")
    },
    .get_nlum = function(.data_set = NULL, .proj = NULL, .x = NULL) {
      return(tif_path)
    }
  )
})

test_that("downloads when x is NULL and reads stars object", {
  skip_if_offline()

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

  last_url <- NULL
  retry_mock <- function(url, .f) {
    last_url <<- url
    file.create(.f)
    invisible(.f)
  }

  with_mocked_bindings(
    {
      out <- read_nlum_stars(data_set = "Y202021", proj = "Albers")
      expect_s3_class(out, "stars")
    },
    .get_nlum = function(.data_set = NULL, .proj = NULL, .x = NULL) {
      return(tif_path)
    },
    .retry_download = retry_mock,
    .unzip_file = function(x) NULL
  )
})

test_that("errors cleanly when file does not exist", {
  skip_if_offline()
  skip_if_not_installed("stars")

  bogus <- fs::path(tempdir(), "no-such-nlum.zip")
  if (fs::file_exists(bogus)) {
    fs::file_delete(bogus)
  }

  with_mocked_bindings(
    {
      expect_error(
        read_nlum_stars(x = bogus),
        regexp = "cannot open|does not exist|Failed to open|cannot find",
        ignore.case = TRUE
      )
    },
    .get_nlum = function(.x = NULL, ...) {
      stop("Failed to open file")
    }
  )
})
