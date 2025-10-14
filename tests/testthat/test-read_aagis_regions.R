build_aagis_fixture_zip <- function(
  build_dir,
  layer = "aagis_asgs16v1_g5a",
  extra_layers = character(0)
) {
  shp_dir <- fs::path(build_dir, "aagis")
  fs::dir_create(shp_dir, recurse = TRUE)

  # Minimal polygons
  poly1 <- sf::st_polygon(list(rbind(
    c(0, 0),
    c(1, 0),
    c(1, 1),
    c(0, 1),
    c(0, 0)
  )))
  poly2 <- sf::st_polygon(list(rbind(
    c(2, 0),
    c(3, 0),
    c(3, 1),
    c(2, 1),
    c(2, 0)
  )))
  geom <- sf::st_sfc(poly1, poly2, crs = 4326)

  dat <- data.frame(
    name = c("NSW East", "WA West"),
    class = c("Wool", "Beef"),
    zone = c(1L, 2L),
    aagis = c("Wool", "Beef")
  )
  aagis_sf <- sf::st_sf(dat, geometry = geom)

  # Write the primary layer (expected by hardened function)
  invisible(sf::st_write(
    aagis_sf,
    dsn = shp_dir,
    layer = layer,
    driver = "ESRI Shapefile",
    delete_layer = TRUE,
    quiet = TRUE
  ))

  # Optionally add other layers next to it
  if (length(extra_layers) > 0) {
    other_geom <- sf::st_sfc(
      sf::st_polygon(list(rbind(
        c(10, 0),
        c(11, 0),
        c(11, 1),
        c(10, 1),
        c(10, 0)
      ))),
      crs = 4326
    )
    other_dat <- data.frame(
      name = "VIC East",
      class = "Beef",
      zone = 9L,
      aagis = "Beef",
      stringsAsFactors = FALSE
    )
    other_sf <- sf::st_sf(other_dat, geometry = other_geom)

    for (ly in extra_layers) {
      invisible(sf::st_write(
        other_sf,
        dsn = shp_dir,
        layer = ly,
        driver = "ESRI Shapefile",
        delete_layer = TRUE,
        quiet = TRUE
      ))
    }
  }

  # Zip the "aagis/" folder relative to build_dir
  zip_path <- fs::path(build_dir, "fixture.zip")
  withr::with_dir(build_dir, {
    utils::zip(zipfile = zip_path, files = "aagis")
  })
  zip_path
}

# -------------------------------------------------------------------------
# 1) Provided local ZIP (happy path)
# -------------------------------------------------------------------------
test_that("read_aagis_regions reads and cleans data from a provided local ZIP (strict filename match)", {
  withr::local_options(read.abares.verbosity = "quiet")

  td <- withr::local_tempdir()
  build_dir <- fs::path(td, "build")
  fs::dir_create(build_dir, recurse = TRUE)

  # Build fixture with the CORRECT layer name
  local_zip <- build_aagis_fixture_zip(build_dir, layer = "aagis_asgs16v1_g5a")
  expect_true(fs::file_exists(local_zip))

  # Put ZIP into a separate directory (this is the directory the function will search)
  zip_dir <- fs::path(td, "zipin")
  fs::dir_create(zip_dir)
  zip_path <- fs::path(zip_dir, "aagis.zip")
  fs::file_copy(local_zip, zip_path, overwrite = TRUE)

  # --- Pre-extract alongside the ZIP so the expected .shp is already discoverable ---
  utils::unzip(zipfile = zip_path, exdir = zip_dir) # <<< extract to fs::path_dir(x)
  shp_expected <- fs::path(zip_dir, "aagis", "aagis_asgs16v1_g5a.shp")
  expect_true(fs::file_exists(shp_expected))

  # --- Make unzip a no-op so the function won't change anything during the test ---
  testthat::local_mocked_bindings(
    .unzip_file = function(x) {
      invisible(TRUE)
    },
    .env = asNamespace("read.abares")
  )

  # Call the function with provided ZIP
  res <- read_aagis_regions(x = zip_path)

  # The function should delete the ZIP
  expect_false(fs::file_exists(zip_path))

  # Return type & geometry validity
  expect_s3_class(res, "sf")
  expect_true(all(sf::st_is_valid(res)))
  expect_identical(sf::st_crs(res)$epsg, 4326L)

  # Columns: dropped + renamed
  expect_false("aagis" %in% names(res))
  expect_true(all(
    c("ABARES_region", "Class", "Zone", "State", "geometry") %in% names(res)
  ))

  # Values
  expect_setequal(res$ABARES_region, c("NSW East", "WA West"))
  expect_setequal(res$Class, c("Wool", "Beef"))
  expect_setequal(as.integer(res$Zone), c(1L, 2L))
  expect_setequal(res$State, c("NSW", "WA"))
  expect_identical(nrow(res), 2L)
})


# -------------------------------------------------------------------------
# 2) Default path (x = NULL) with mocked download/unzip (NO tempdir mocking)
#    Build the fixture, ZIP it, then DELETE the build directory so the function
#    only ever sees the unzipped shapefile under tempdir().
# -------------------------------------------------------------------------
testthat::test_that("read_aagis_regions default path (x = NULL) works with mocked download/unzip without tempdir mocking", {
  withr::local_options(read.abares.verbosity = "quiet")

  td <- withr::local_tempdir()
  build_dir <- fs::path(td, "build")
  fs::dir_create(build_dir, recurse = TRUE)

  # Build local fixture ZIP (correct layer name)
  local_zip <- build_aagis_fixture_zip(build_dir, layer = "aagis_asgs16v1_g5a")
  testthat::expect_true(fs::file_exists(local_zip))

  # IMPORTANT: remove the build tree so no matching .shp is left under tempdir()
  fs::dir_delete(build_dir)

  # Clean any debris under session tempdir()
  zip_path <- fs::path(tempdir(), "aagis.zip")
  unzip_dir <- fs::path(tempdir(), "aagis")
  if (fs::file_exists(zip_path)) {
    fs::file_delete(zip_path)
  }
  if (fs::dir_exists(unzip_dir)) {
    fs::dir_delete(unzip_dir)
  }

  # Guard: if some other test left a matching shapefile under tempdir(), skip to avoid false failure
  pre_existing <- fs::dir_ls(
    tempdir(),
    regexp = "aagis_asgs16v1_g5a[.]shp$",
    recurse = TRUE,
    type = "file"
  )
  testthat::skip_if(
    length(pre_existing) > 0L,
    message = "Found existing 'aagis_asgs16v1_g5a.shp' under tempdir(); skipping default-path test."
  )

  # Mock helpers to avoid network and use local fixture
  testthat::local_mocked_bindings(
    .retry_download = function(url, dest) {
      # copy our local ZIP fixture to the expected default path
      fs::file_copy(local_zip, dest, overwrite = TRUE)
      invisible(dest)
    },
    .unzip_file = function(x) {
      # unzip alongside the ZIP (i.e., into session tempdir())
      utils::unzip(x, exdir = fs::path_dir(x))
      invisible(TRUE)
    },
    .env = asNamespace("read.abares") # adjust if your pkg namespace differs
  )

  # Exercise default branch
  res <- read_aagis_regions() # x = NULL

  # ZIP is deleted by the function
  testthat::expect_false(fs::file_exists(zip_path))

  # Exactly one matching .shp under tempdir(), thanks to strict regex + deleted build tree
  shps <- fs::dir_ls(
    fs::path_dir(zip_path),
    regexp = "aagis_asgs16v1_g5a[.]shp$",
    recurse = TRUE,
    type = "file"
  )
  testthat::expect_length(shps, 1L)

  # Return & contents
  testthat::expect_s3_class(res, "sf")
  testthat::expect_true(all(sf::st_is_valid(res)))
  testthat::expect_identical(sf::st_crs(res)$epsg, 4326L)

  testthat::expect_false("aagis" %in% names(res))
  testthat::expect_true(all(
    c("ABARES_region", "Class", "Zone", "State", "geometry") %in% names(res)
  ))

  testthat::expect_setequal(res$ABARES_region, c("NSW East", "WA West"))
  testthat::expect_setequal(res$Class, c("Wool", "Beef"))
  testthat::expect_setequal(as.integer(res$Zone), c(1L, 2L))
  testthat::expect_setequal(res$State, c("NSW", "WA"))
  testthat::expect_identical(nrow(res), 2L)
  fs::file_delete(fs::dir_ls(tempdir(), regexp = "$aagis_extract."))
})

# -------------------------------------------------------------------------
# 3) Negative: ZIP missing the expected shapefile → error
# -------------------------------------------------------------------------

test_that("read_aagis_regions errors when expected shapefile is missing from ZIP", {
  withr::local_options(read.abares.verbosity = "quiet")

  td <- withr::local_tempdir()
  build_dir <- fs::path(td, "build")
  fs::dir_create(build_dir, recurse = TRUE)

  bad_zip <- build_aagis_fixture_zip(build_dir, layer = "WRONG_LAYER_NAME")
  expect_true(fs::file_exists(bad_zip))

  # Expect the current out-of-bounds error
  expect_error(
    read_aagis_regions(x = bad_zip),
    class = "subscriptOutOfBoundsError" # from your trace
  )
})

# -------------------------------------------------------------------------
# 4) Robustness: extra shapefiles present → still reads only the expected one
# -------------------------------------------------------------------------
testthat::test_that("read_aagis_regions ignores other shapefiles and reads only the expected one", {
  withr::local_options(read.abares.verbosity = "quiet")

  td <- withr::local_tempdir()
  build_dir <- fs::path(td, "build")
  fs::dir_create(build_dir, recurse = TRUE)

  # Build fixture with expected layer + an extra different layer
  zip_path <- build_aagis_fixture_zip(
    build_dir,
    layer = "aagis_asgs16v1_g5a",
    extra_layers = c("some_other_layer")
  )
  testthat::expect_true(fs::file_exists(zip_path))

  # Should read only the expected shapefile
  res <- read_aagis_regions(x = zip_path)

  testthat::expect_s3_class(res, "sf")
  testthat::expect_false("aagis" %in% names(res))
  testthat::expect_true(all(
    c("ABARES_region", "Class", "Zone", "State", "geometry") %in% names(res)
  ))

  # Confirm content corresponds to the expected layer only (two features we wrote)
  testthat::expect_identical(nrow(res), 2L)
  testthat::expect_setequal(res$ABARES_region, c("NSW East", "WA West"))
  testthat::expect_setequal(res$Class, c("Wool", "Beef"))
  testthat::expect_setequal(as.integer(res$Zone), c(1L, 2L))
  testthat::expect_setequal(res$State, c("NSW", "WA"))
})
