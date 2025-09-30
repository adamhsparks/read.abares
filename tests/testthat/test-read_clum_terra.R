test_that("read_clum_terra integrates with .get_clum for a local zip and applies coltab (clum_50m_2023_v2)", {
  skip_on_cran()
  skip_if_not_installed("terra")

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

  # Helper: normalize terra coltab (hex or RGB(A), named or not) -> data.frame(value, hex)
  normalize_coltab <- function(ct_entry) {
    df <- as.data.frame(ct_entry, stringsAsFactors = FALSE)
    if (nrow(df) == 0L) {
      return(data.frame(
        value = integer(),
        hex = character(),
        stringsAsFactors = FALSE
      ))
    }

    # Lowercase column names for matching; if none, fabricate temporary names
    nms <- names(df)
    if (is.null(nms)) {
      names(df) <- paste0("V", seq_len(ncol(df)))
      nms <- names(df)
    }
    nms_l <- tolower(nms)

    # Identify candidate "value" column:
    # pick the numeric/integer column that contains the most of our raster values
    num_cols <- which(vapply(
      df,
      function(z) is.numeric(z) || is.integer(z),
      logical(1)
    ))
    score <- if (length(num_cols)) {
      vapply(
        num_cols,
        function(i) sum(vals_in_raster %in% as.integer(df[[i]])),
        integer(1)
      )
    } else {
      integer()
    }
    value_col <- if (length(score)) num_cols[which.max(score)] else NA_integer_

    # If we could not find any numeric column that overlaps, bail out with empty
    if (is.na(value_col) || score[which.max(score)] == 0L) {
      return(data.frame(
        value = integer(),
        hex = character(),
        stringsAsFactors = FALSE
      ))
    }

    value <- as.integer(df[[value_col]])

    # Identify hex column (direct) or RGB(A) columns to construct hex
    # 1) direct hex column
    hex_col <- which(vapply(
      df,
      function(z) is.character(z) && any(grepl("^#[0-9A-Fa-f]{6}$", z)),
      logical(1)
    ))
    if (length(hex_col)) {
      hex <- tolower(df[[hex_col[1]]])
      return(data.frame(value = value, hex = hex, stringsAsFactors = FALSE))
    }

    # 2) RGB(A) columns in various spellings
    have_rgb <- all(c("red", "green", "blue") %in% nms_l) ||
      all(c("r", "g", "b") %in% nms_l)
    if (have_rgb) {
      red_nm <- if ("red" %in% nms_l) {
        nms[match("red", nms_l)]
      } else {
        nms[match("r", nms_l)]
      }
      green_nm <- if ("green" %in% nms_l) {
        nms[match("green", nms_l)]
      } else {
        nms[match("g", nms_l)]
      }
      blue_nm <- if ("blue" %in% nms_l) {
        nms[match("blue", nms_l)]
      } else {
        nms[match("b", nms_l)]
      }
      r <- as.integer(df[[red_nm]])
      g <- as.integer(df[[green_nm]])
      b <- as.integer(df[[blue_nm]])
      tohex <- function(a, b, c) {
        sprintf(
          "#%02x%02x%02x",
          pmax(0, pmin(255, a)),
          pmax(0, pmin(255, b)),
          pmax(0, pmin(255, c))
        )
      }
      hex <- tolower(tohex(r, g, b))
      return(data.frame(value = value, hex = hex, stringsAsFactors = FALSE))
    }

    # 3) Fallback: assume the first non-value column is hex-like; try to coerce
    other_cols <- setdiff(seq_len(ncol(df)), value_col)
    if (length(other_cols)) {
      hx <- df[[other_cols[1]]]
      if (is.numeric(hx)) {
        # If numeric 0-255, treat as grayscale; construct hex
        x <- as.integer(pmax(0, pmin(255, hx)))
        hx <- tolower(sprintf("#%02x%02x%02x", x, x, x))
      }
      if (is.factor(hx)) {
        hx <- as.character(hx)
      }
      return(data.frame(
        value = value,
        hex = tolower(hx),
        stringsAsFactors = FALSE
      ))
    }

    data.frame(value = integer(), hex = character(), stringsAsFactors = FALSE)
  }

  testthat::with_mocked_bindings(
    {
      res <- read_clum_terra(data_set = ds_name, x = zip_path)

      # terra SpatRaster is S4
      expect_true(inherits(res, "SpatRaster")) # or: expect_s4_class(res, "SpatRaster")
      expect_equal(terra::nlyr(res), 1L)
      expect_equal(terra::ncell(res), 4L)

      # Colour table should be applied for clum_50m_2023_v2
      ctl <- terra::coltab(res)
      expect_type(ctl, "list")
      expect_equal(length(ctl), 1L)

      ct1_df <- as.data.frame(ctl[[1]], stringsAsFactors = FALSE)
      expect_gt(nrow(ct1_df), 0L) # some entries must exist

      norm <- normalize_coltab(ctl[[1]])
      # We at least expect the value codes present in our raster to exist in the coltab
      expect_true(all(vals_in_raster %in% norm$value))

      # If we could detect/compute hex, assert a few canonical mappings
      if (nrow(norm) > 0L && any(grepl("^#[0-9a-f]{6}$", norm$hex))) {
        get_hex <- function(val) norm$hex[match(val, norm$value)]
        expect_identical(get_hex(0L), "#ffffff")
        expect_identical(get_hex(100L), "#9666cc")
        expect_identical(get_hex(600L), "#0000ff")
        expect_identical(get_hex(663L), "#0000ff")
      } else {
        testthat::skip(
          "Could not detect hex in terra::coltab() on this platform; color presence verified."
        )
      }
    },
    .unzip_file = unzip_mock
  )
})

test_that("read_clum_terra integrates with .get_clum and does NOT apply coltab for scale_date_update", {
  skip_on_cran()
  skip_if_not_installed("terra")

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

  testthat::with_mocked_bindings(
    {
      res <- read_clum_terra(data_set = ds_name, x = zip_path)
      expect_true(inherits(res, "SpatRaster"))
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
  skip_on_cran()

  expect_error(
    read_clum_terra(data_set = "not-a-valid-dataset"),
    regexp = "must be one of|`data_set` must be one of",
    ignore.case = TRUE
  )
})

test_that("read_clum_terra passes data_set and x to .get_clum and reads returned files", {
  skip_on_cran()
  skip_if_not_installed("terra")

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

  testthat::with_mocked_bindings(
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
  skip_on_cran()
  skip_if_not_installed("terra")

  # Two small rasters -> two layers when passed as multiple files
  m <- matrix(c(0L, 100L, 600L, 663L), nrow = 2, ncol = 2, byrow = TRUE)
  r <- terra::rast(m)
  tmpdir <- withr::local_tempdir()
  tif1 <- fs::path(tmpdir, "tileA.tif")
  tif2 <- fs::path(tmpdir, "tileB.tif")
  terra::writeRaster(r, tif1, overwrite = TRUE)
  terra::writeRaster(r, tif2, overwrite = TRUE)

  get_clum_mock <- function(.data_set, .x) c(tif1, tif2)

  testthat::with_mocked_bindings(
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
  skip_on_cran()
  skip_if_not_installed("terra")

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
  retry_mock <- function(url, .f) {
    last_url <<- url
    fs::file_copy(prebuilt_zip, .f, overwrite = TRUE)
    invisible(.f)
  }

  unzip_mock <- function(x) {
    utils::unzip(zipfile = x, exdir = fs::path_dir(x))
    invisible(x)
  }

  testthat::with_mocked_bindings(
    {
      res <- read_clum_terra(data_set = ds_name, x = NULL)
      expect_s4_class(res, "SpatRaster")
      expect_identical(terra::nlyr(res), 1)

      # Colour table should be present for clum dataset
      ct <- terra::coltab(res)
      expect_true(nrow(as.data.frame(ct[[1]])) > 0L)

      # Sanity that the correct resource is referenced in the URL selection
      expect_true(grepl(
        "6deab695-3661-4135-abf7-19f25806cfd7",
        last_url,
        fixed = TRUE
      ))
    },
    .retry_download = retry_mock,
    .unzip_file = unzip_mock
  )
})

test_that(".set_clum_update_levels returns a list with the expected named tables", {
  skip_on_cran()

  lvls <- .set_clum_update_levels()

  expect_type(lvls, "list")
  # Keep this strict so accidental reordering is caught early
  expect_identical(
    names(lvls),
    c("date_levels", "update_levels", "scale_levels")
  )

  # Each element should behave like a data frame (data.table inherits data.frame)
  lapply(lvls, function(x) expect_true(inherits(x, "data.frame")))
})

test_that("date_levels: years 2008–2023 as integers; rast_cat identical; strictly increasing", {
  skip_on_cran()

  dl <- .set_clum_update_levels()$date_levels

  # Columns exist and have correct types
  expect_true(all(c("int", "rast_cat") %in% names(dl)))
  expect_true(is.integer(dl$int))
  expect_true(is.integer(dl$rast_cat))

  # Exact sequence and identity between columns
  years <- 2008L:2023L
  expect_identical(dl$int, years)
  expect_identical(dl$rast_cat, years)

  # Shape and quality
  expect_equal(nrow(dl), length(years))
  expect_true(all(diff(dl$int) > 0))
  expect_false(anyNA(dl$int))
  expect_false(anyNA(dl$rast_cat))
  expect_equal(length(unique(dl$int)), length(dl$int))
})

test_that("update_levels: 0/1 map to expected labels in order", {
  skip_on_cran()

  ul <- .set_clum_update_levels()$update_levels

  expect_true(all(c("int", "rast_cat") %in% names(ul)))
  expect_true(is.integer(ul$int))
  expect_type(ul$rast_cat, "character")

  expect_equal(nrow(ul), 2L)
  expect_identical(ul$int, 0L:1L)
  expect_identical(
    ul$rast_cat,
    c("Not Updated", "Updated Since CLUM Dec. 2020 Release")
  )

  expect_false(anyNA(ul$int))
  expect_false(anyNA(ul$rast_cat))
  expect_true(all(diff(ul$int) > 0))
  expect_equal(length(unique(ul$int)), length(ul$int))
})

test_that("scale_levels: denominators map exactly to formatted labels and are strictly increasing", {
  skip_on_cran()

  sl <- .set_clum_update_levels()$scale_levels

  expect_true(all(c("int", "rast_cat") %in% names(sl)))
  expect_true(is.integer(sl$int))
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

  expect_equal(nrow(sl), length(expected_int))
  expect_identical(sl$int, expected_int)
  expect_identical(sl$rast_cat, expected_lab)

  expect_true(all(diff(sl$int) > 0))
  expect_false(anyNA(sl$int))
  expect_false(anyNA(sl$rast_cat))
  expect_equal(length(unique(sl$int)), length(sl$int))

  # Labels follow "1:<thousands-with-commas>" pattern
  expect_true(all(grepl("^1:\\d{1,3}(,\\d{3})*$", sl$rast_cat)))
})

test_that("all tables are data.table (implementation detail) while also data.frame", {
  skip_on_cran()

  lvls <- .set_clum_update_levels()
  # If you ever change internals away from data.table(), this test will point it out.
  lapply(lvls, function(x) {
    expect_true(inherits(x, "data.frame"))
    expect_true(inherits(x, "data.table"))
  })
})
