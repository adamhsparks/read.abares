test_that("read_clum_terra integrates with .get_clum for a local zip and applies coltab (clum_50m_2023_v2)", {
  skip_if_offline()

  ds_name <- "clum_50m_2023_v2"

  # Create a tiny raster with values present in the colour table
  vals_in_raster <- c(0L, 100L, 600L, 663L)
  m <- matrix(vals_in_raster, nrow = 2, byrow = TRUE)
  r <- terra::rast(m)

  # Stage a zip with top-level == data_set
  root <- withr::local_tempdir()
  ds_dir <- fs::path(root, ds_name)
  fs::dir_create(ds_dir)

  tif_path <- fs::path(ds_dir, "tile_01.tif")
  terra::writeRaster(r, tif_path, overwrite = TRUE)

  zip_path <- fs::path(root, sprintf("%s.zip", ds_name))
  create_zip(zip_path, files_dir = root, files_rel = ds_name)
  withr::defer({
    if (fs::file_exists(zip_path)) fs::file_delete(zip_path)
  })

  # Mock unzip to extract next to the zip (where .get_clum expects it)
  unzip_mock <- function(x) {
    utils::unzip(zipfile = x, exdir = fs::path_dir(x))
    invisible(x)
  }

  # Clean unzipped target under tempdir()
  out_dir <- fs::path(tempdir(), ds_name)
  if (fs::dir_exists(out_dir)) {
    fs::dir_delete(out_dir)
  }
  withr::defer({
    if (fs::dir_exists(out_dir)) fs::dir_delete(out_dir)
  })

  with_mocked_bindings(
    {
      res <- read_clum_terra(data_set = ds_name, x = zip_path)

      # terra SpatRaster is S4
      expect_s4_class(res, "SpatRaster")
      expect_identical(terra::nlyr(res), 1)
      expect_identical(terra::ncell(res), 4)

      # Colour table should be applied for clum_50m_2023_v2
      ctl <- terra::coltab(res)
      expect_type(ctl, "list")
      expect_length(ctl, 1L)

      # Check that the color table has entries
      ct_df <- as.data.frame(ctl[[1]], stringsAsFactors = FALSE)
      expect_gt(nrow(ct_df), 0L)

      # Get the expected color table from the function
      expected_ct <- .create_clum_50m_coltab()

      # Verify that our raster values exist in the expected color table
      expect_true(all(vals_in_raster %in% expected_ct$value))

      # Check specific color mappings from the expected color table
      get_expected_color <- function(val) {
        idx <- match(val, expected_ct$value)
        if (is.na(idx)) {
          return(NA_character_)
        }
        return(expected_ct$color[idx])
      }

      # Verify the expected colors are correct
      expect_identical(get_expected_color(0L), "#ffffff")
      expect_identical(get_expected_color(100L), "#9666cc")
      expect_identical(get_expected_color(600L), "#0000ff")
      expect_identical(get_expected_color(663L), "#0000ff")
    },
    .unzip_file = unzip_mock
  )
})

test_that("read_clum_terra integrates with .get_clum and does NOT apply coltab for scale_date_update", {
  skip_if_offline()

  ds_name <- "scale_date_update"

  # Create a small raster and zip it as the dataset
  m <- matrix(1:4, nrow = 2, ncol = 2)
  r <- terra::rast(m)

  files_root <- withr::local_tempdir()
  ds_dir <- fs::path(files_root, ds_name)
  fs::dir_create(ds_dir)
  tif_path <- fs::path(ds_dir, "scale_meta.tif")
  terra::writeRaster(r, tif_path, overwrite = TRUE)

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

  with_mocked_bindings(
    {
      res <- read_clum_terra(data_set = ds_name, x = zip_path)
      expect_s4_class(res, "SpatRaster")
      expect_equal(terra::nlyr(res), 1L)

      ctl <- terra::coltab(res)
      expect_type(ctl, "list")
      expect_identical(length(ctl), 1L)

      # For scale_date_update we expect no coltab entries (terra returns empty)
      expect_equal(nrow(as.data.frame(ctl[[1]], stringsAsFactors = FALSE)), 0L)
    },
    .unzip_file = unzip_mock
  )
})

test_that("read_clum_terra validates data_set choices", {
  skip_if_offline()

  expect_error(
    read_clum_terra(data_set = "not-a-valid-dataset"),
    regexp = "must be one of|`data_set` must be one of",
    ignore.case = TRUE
  )
})

test_that("read_clum_terra passes data_set and x to .get_clum and reads returned files", {
  skip_if_offline()

  # Build a tiny GeoTIFF that terra can read
  m <- matrix(c(0L, 100L, 600L, 663L), nrow = 2L, ncol = 2L, byrow = TRUE)
  r <- terra::rast(m)
  tmpdir <- withr::local_tempdir()
  tif1 <- fs::path(tmpdir, "tileA.tif")
  terra::writeRaster(r, tif1, overwrite = TRUE)

  captured <- new.env(parent = emptyenv())
  get_clum_mock <- function(.data_set, .x) {
    captured$data_set <- .data_set
    captured$x <- .x
    return(tif1)
  }

  with_mocked_bindings(
    {
      res <- read_clum_terra(
        data_set = "clum_50m_2023_v2",
        x = "dummy/path.zip"
      )
      expect_identical(captured$data_set, "clum_50m_2023_v2")
      expect_identical(captured$x, "dummy/path.zip")

      expect_s4_class(res, "SpatRaster")
      expect_identical(terra::nlyr(res), 1)

      # Colour table should be present (applied for clum_50m_2023_v2)
      ct <- terra::coltab(res)
      expect_identical(length(ct), 1L)
      expect_gte(nrow(as.data.frame(ct[[1L]])), 1L)
    },
    .get_clum = get_clum_mock
  )
})

test_that("read_clum_terra handles multiple files from .get_clum() and applies coltab to each layer", {
  skip_if_offline()

  # Two small rasters -> two layers when passed as multiple files
  m <- matrix(c(0L, 100L, 600L, 663L), nrow = 2, ncol = 2, byrow = TRUE)
  r <- terra::rast(m)
  tmpdir <- withr::local_tempdir()
  tif1 <- fs::path(tmpdir, "tileA.tif")
  tif2 <- fs::path(tmpdir, "tileB.tif")
  terra::writeRaster(r, tif1, overwrite = TRUE)
  terra::writeRaster(r, tif2, overwrite = TRUE)

  get_clum_mock <- function(.data_set, .x) c(tif1, tif2)

  with_mocked_bindings(
    {
      res <- read_clum_terra(data_set = "clum_50m_2023_v2", x = NULL)
      expect_s4_class(res, "SpatRaster")
      expect_equal(terra::nlyr(res), 2L)

      # Colour table applied to each layer
      ct <- terra::coltab(res)
      expect_equal(length(ct), 2L)
      expect_true(all(vapply(
        ct,
        function(z) nrow(as.data.frame(z)) > 0L,
        logical(1)
      )))
    },
    .get_clum = get_clum_mock
  )
})

test_that("read_clum_terra works end-to-end with mocked download when x = NULL (unzips into tempdir)", {
  skip_if_offline()

  ds_name <- "clum_50m_2023_v2"

  # Stage a prebuilt zip with the expected directory layout (top-level == data_set)
  staging <- withr::local_tempdir()
  ds_dir <- fs::path(staging, ds_name)
  fs::dir_create(ds_dir)

  # Write a small raster
  m <- matrix(c(0L, 100L, 600L, 663L), nrow = 2, ncol = 2, byrow = TRUE)
  r <- terra::rast(m)
  tif_path <- fs::path(ds_dir, "tile_01.tif")
  terra::writeRaster(r, tif_path, overwrite = TRUE)

  prebuilt_zip <- fs::path(staging, sprintf("%s.zip", ds_name))
  create_zip(prebuilt_zip, files_dir = staging, files_rel = ds_name)

  # Clean target locations used by .get_clum() with x = NULL
  target_zip <- fs::path(tempdir(), sprintf("%s.zip", ds_name))
  target_dir <- fs::path(tempdir(), ds_name)
  if (fs::file_exists(target_zip)) {
    fs::file_delete(target_zip)
  }
  if (fs::dir_exists(target_dir)) {
    fs::dir_delete(target_dir)
  }

  withr::defer({
    if (fs::file_exists(target_zip)) {
      fs::file_delete(target_zip)
    }
    if (fs::dir_exists(target_dir)) fs::dir_delete(target_dir)
  })

  last_url <- NULL
  # Updated mock function to match the actual .retry_download signature
  retry_mock <- function(
    url,
    dest,
    dataset_id = NULL,
    force_stream = NULL,
    show_progress = TRUE,
    ...
  ) {
    last_url <<- url
    fs::file_copy(prebuilt_zip, dest, overwrite = TRUE)
    invisible(dest)
  }

  unzip_mock <- function(x) {
    utils::unzip(zipfile = x, exdir = fs::path_dir(x))
    invisible(x)
  }

  with_mocked_bindings(
    {
      res <- read_clum_terra(data_set = ds_name, x = NULL)

      # Add your test assertions here
      expect_s4_class(res, "SpatRaster")
      expect_true(fs::file_exists(target_zip))
      expect_true(fs::dir_exists(target_dir))
      expect_false(is.null(last_url))
    },
    .retry_download = retry_mock,
    .unzip_file = unzip_mock,
    .package = "read.abares"
  )
})

test_that(".set_clum_update_levels returns a list with the expected named tables", {
  skip_if_offline()

  lvls <- .set_clum_update_levels()

  expect_type(lvls, "list")
  # Keep this strict so accidental reordering is caught early
  expect_named(
    lvls,
    c("date_levels", "update_levels", "scale_levels")
  )

  # Each element should behave like a data frame (data.table inherits data.frame)
  lapply(lvls, function(x) expect_s3_class(x, "data.frame"))
})

test_that("date_levels: years 2008–2023 as integers; rast_cat identical; strictly increasing", {
  skip_if_offline()

  dl <- .set_clum_update_levels()$date_levels

  # Columns exist and have correct types
  expect_true(all(c("int", "rast_cat") %in% names(dl)))
  expect_type(dl$int, "integer")
  expect_type(dl$rast_cat, "integer")

  # Exact sequence and identity between columns
  years <- 2008L:2023L
  expect_identical(dl$int, years)
  expect_identical(dl$rast_cat, years)

  # Shape and quality
  expect_identical(nrow(dl), length(years))
  expect_true(all(diff(dl$int) > 0))
  expect_false(anyNA(dl$int))
  expect_false(anyNA(dl$rast_cat))
  expect_identical(length(unique(dl$int)), length(dl$int))
})

test_that("update_levels: 0/1 map to expected labels in order", {
  skip_if_offline()

  ul <- .set_clum_update_levels()$update_levels

  expect_true(all(c("int", "rast_cat") %in% names(ul)))
  expect_type(ul$int, "integer")
  expect_type(ul$rast_cat, "character")

  expect_identical(nrow(ul), 2L)
  expect_identical(ul$int, 0L:1L)
  expect_identical(
    ul$rast_cat,
    c("Not Updated", "Updated Since CLUM Dec. 2020 Release")
  )

  expect_false(anyNA(ul$int))
  expect_false(anyNA(ul$rast_cat))
  expect_true(all(diff(ul$int) > 0L))
  expect_identical(length(unique(ul$int)), length(ul$int))
})

test_that("scale_levels: denominators map exactly to formatted labels and are strictly increasing", {
  skip_if_offline()

  sl <- .set_clum_update_levels()$scale_levels

  expect_true(all(c("int", "rast_cat") %in% names(sl)))
  expect_type(sl$int, "integer")
  expect_type(sl$rast_cat, "character")

  expected_int <- c(5000L, 10000L, 20000L, 25000L, 50000L, 100000L, 250000L)
  expected_lab <- c(
    "1:5,000",
    "1:10,000",
    "1:20,000",
    "1:25,000",
    "1:50,000",
    "1:100,000",
    "1:250,000"
  )

  expect_identical(nrow(sl), length(expected_int))
  expect_identical(sl$int, expected_int)
  expect_identical(sl$rast_cat, expected_lab)

  expect_true(all(diff(sl$int) > 0))
  expect_false(anyNA(sl$int))
  expect_false(anyNA(sl$rast_cat))
  expect_identical(length(unique(sl$int)), length(sl$int))

  # Labels follow "1:<thousands-with-commas>" pattern
  expect_true(all(grepl("^1:\\d{1,3}(,\\d{3})*$", sl$rast_cat)))
})

test_that("all tables are data.table (implementation detail) while also data.frame", {
  skip_if_offline()

  lvls <- .set_clum_update_levels()
  # If you ever change internals away from data.table(), this test will point it out.
  lapply(lvls, function(x) {
    expect_s3_class(x, "data.frame")
    expect_s3_class(x, "data.table")
  })
})

test_that(".create_clum_50m_coltab creates expected color table structure", {
  skip_if_offline()

  ct <- .create_clum_50m_coltab()

  # Should be a data.table/data.frame
  expect_s3_class(ct, "data.frame")
  expect_s3_class(ct, "data.table")

  # Should have expected columns
  expect_true(all(c("value", "color") %in% names(ct)))
  expect_type(ct$value, "integer")
  expect_type(ct$color, "character")

  # Should have 198 rows as defined in the function
  expect_identical(nrow(ct), 198L)

  # All colors should be valid hex codes
  expect_true(all(grepl("^#[0-9a-f]{6}$", ct$color)))

  # Values should be unique and sorted
  expect_identical(length(unique(ct$value)), nrow(ct))
  expect_gt(all(diff(ct$value)), 0)

  # Check some specific mappings
  expect_identical(ct$color[ct$value == 0L], "#ffffff")
  expect_identical(ct$color[ct$value == 100L], "#9666cc")
  expect_identical(ct$color[ct$value == 600L], "#0000ff")
  expect_identical(ct$color[ct$value == 663L], "#0000ff")
})
