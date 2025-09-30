test_that("read_clum_stars integrates with .get_clum for a local zip and returns a stars object", {
  skip_on_cran()

  ds_name <- "clum_50m_2023_v2"

  # Create a tiny raster and write to GeoTIFF inside the expected dataset dir
  root <- withr::local_tempdir()
  ds_dir <- fs::path(root, ds_name)
  fs::dir_create(ds_dir)

  tif_path <- fs::path(ds_dir, "tile_01.tif")
  st <- stars::st_as_stars(matrix(as.numeric(1:4), nrow = 2, ncol = 2))

  ok <- TRUE
  tryCatch(
    stars::write_stars(st, tif_path, quiet = TRUE),
    error = function(e) ok <<- FALSE
  )
  if (!ok) {
    testthat::skip(
      "Unable to write GeoTIFF (GDAL/GeoTIFF driver not available)"
    )
  }

  # Zip the dataset folder so .get_clum(.x = zip_path) can unzip it
  zip_path <- fs::path(root, sprintf("%s.zip", ds_name))
  create_zip(zip_path, files_dir = root, files_rel = ds_name)
  withr::defer({
    if (fs::file_exists(zip_path)) fs::file_delete(zip_path)
  })

  # Mock .unzip_file to unzip where .get_clum expects it
  unzip_mock <- function(x) {
    utils::unzip(zipfile = x, exdir = fs::path_dir(x))
    invisible(x)
  }

  # Ensure clean unzipped target
  out_dir <- fs::path(tempdir(), ds_name)
  if (fs::dir_exists(out_dir)) {
    fs::dir_delete(out_dir)
  }
  withr::defer({
    if (fs::dir_exists(out_dir)) fs::dir_delete(out_dir)
  })

  testthat::with_mocked_bindings(
    {
      res <- read_clum_stars(data_set = ds_name, x = zip_path)
      expect_s3_class(res, "stars")
      # basic sanity: x/y dims exist
      expect_true(all(c("x", "y") %in% names(stars::st_dimensions(res))))
    },
    .unzip_file = unzip_mock
  )
})

test_that("read_clum_stars forwards ... to stars::read_stars (proxy = TRUE)", {
  skip_on_cran()

  ds_name <- "scale_date_update"

  files_root <- withr::local_tempdir()
  ds_dir <- fs::path(files_root, ds_name)
  fs::dir_create(ds_dir)

  tif_path <- fs::path(ds_dir, "scale_meta.tif")
  st <- stars::st_as_stars(matrix(as.numeric(1:4), nrow = 2, ncol = 2))

  ok <- TRUE
  tryCatch(
    stars::write_stars(st, tif_path, quiet = TRUE),
    error = function(e) ok <<- FALSE
  )
  if (!ok) {
    testthat::skip(
      "Unable to write GeoTIFF (GDAL/GeoTIFF driver not available)"
    )
  }

  zip_path <- fs::path(files_root, sprintf("%s.zip", ds_name))
  create_zip(zip_path, files_dir = files_root, files_rel = ds_name)
  withr::defer({
    if (fs::file_exists(zip_path)) fs::file_delete(zip_path)
  })

  unzip_mock <- function(x) {
    utils::unzip(zipfile = x, exdir = fs::path_dir(x))
    invisible(x)
  }

  out_dir <- fs::path(tempdir(), ds_name)
  if (fs::dir_exists(out_dir)) {
    fs::dir_delete(out_dir)
  }
  withr::defer({
    if (fs::dir_exists(out_dir)) fs::dir_delete(out_dir)
  })

  testthat::with_mocked_bindings(
    {
      # proxy = TRUE should return a stars_proxy object
      res <- read_clum_stars(data_set = ds_name, x = zip_path, proxy = TRUE)
      expect_true(inherits(res, "stars_proxy"))
      # stars_proxy may not expose dimensions immediately in some versions
      dims <- try(stars::st_dimensions(res), silent = TRUE)
      expect_true(is.null(dims) || all(c("x", "y") %in% names(dims)))
    },
    .unzip_file = unzip_mock
  )
})

test_that("read_clum_stars validates data_set choices", {
  skip_on_cran()

  expect_error(
    read_clum_stars(data_set = "this_is_not_valid"),
    regexp = "must be one of|`data_set` must be one of",
    ignore.case = TRUE
  )
})

test_that("read_clum_stars passes x and data_set to .get_clum and reads returned files", {
  skip_on_cran()

  tmpdir <- withr::local_tempdir()
  tif_dir <- fs::path(tmpdir, "clum_50m_2023_v2")
  fs::dir_create(tif_dir)

  # build a real small GeoTIFF
  tif1 <- fs::path(tif_dir, "tileA.tif")
  st <- stars::st_as_stars(matrix(as.numeric(1:4), nrow = 2, ncol = 2))

  ok <- TRUE
  tryCatch(
    stars::write_stars(st, tif1, quiet = TRUE),
    error = function(e) ok <<- FALSE
  )
  if (!ok) {
    testthat::skip(
      "Unable to write GeoTIFF (GDAL/GeoTIFF driver not available)"
    )
  }

  captured <- new.env(parent = emptyenv())
  get_clum_mock <- function(.data_set, .x) {
    captured$data_set <- .data_set
    captured$x <- .x
    return(tif1) # the path stars::read_stars should read
  }

  testthat::with_mocked_bindings(
    {
      res <- read_clum_stars(
        data_set = "clum_50m_2023_v2",
        x = "dummy/path.zip"
      )
      expect_identical(captured$data_set, "clum_50m_2023_v2")
      expect_identical(captured$x, "dummy/path.zip")
      expect_s3_class(res, "stars")
      expect_true(all(c("x", "y") %in% names(stars::st_dimensions(res))))
    },
    .get_clum = get_clum_mock
  )
})

test_that("read_clum_stars handles multiple files returned by .get_clum()", {
  skip_on_cran()

  tmpdir <- withr::local_tempdir()
  tif_dir <- fs::path(tmpdir, "clum_50m_2023_v2")
  fs::dir_create(tif_dir)

  # Build two tiny GeoTIFFs
  ras <- stars::st_as_stars(matrix(as.numeric(1:4), nrow = 2, ncol = 2))
  tif1 <- fs::path(tif_dir, "tileA.tif")
  tif2 <- fs::path(tif_dir, "tileB.tif")

  ok <- TRUE
  tryCatch(
    {
      stars::write_stars(ras, tif1, quiet = TRUE)
      stars::write_stars(ras, tif2, quiet = TRUE)
    },
    error = function(e) ok <<- FALSE
  )
  if (!ok) {
    testthat::skip(
      "Unable to write GeoTIFF (GDAL/GeoTIFF driver not available)"
    )
  }

  get_clum_mock <- function(.data_set, .x) c(tif1, tif2)

  testthat::with_mocked_bindings(
    {
      res <- read_clum_stars(data_set = "clum_50m_2023_v2", x = NULL)
      expect_s3_class(res, "stars")
      # Must be raster-like with x/y dims; extra dims may or may not be present
      expect_true(all(c("x", "y") %in% names(stars::st_dimensions(res))))
      # Ensure we can compute a bbox
      expect_s3_class(sf::st_bbox(res), "bbox")
    },
    .get_clum = get_clum_mock
  )
})
