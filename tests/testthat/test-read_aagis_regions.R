test_that("read_aagis_regions reads and cleans data from a provided local ZIP", {
  testthat::skip_if_offline()
  testthat::skip_if_not_installed("sf")

  # Build a minimal shapefile matching the expected on-disk structure:
  #   aagis/aagis_asgs16v1_g5a.(shp|shx|dbf|prj...)
  td <- withr::local_tempdir()
  files_dir <- fs::path(td, "payload")
  shp_dir <- fs::path(files_dir, "aagis")
  fs::dir_create(shp_dir)

  # Minimal polygons with required attributes the function expects
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
    name = c("NSW East", "WA West"), # used to produce State and ABARES_region
    class = c("Wool", "Beef"), # will be renamed to 'Class'
    zone = c(1L, 2L), # will be renamed to 'Zone'
    aagis = c("Wool", "Beef") # dropped by the function
  )

  aagis_sf <- sf::st_sf(dat, geometry = geom)

  # Write ESRI Shapefile with the exact layer name expected
  invisible(
    sf::st_write(
      aagis_sf,
      dsn = shp_dir,
      layer = "aagis_asgs16v1_g5a",
      driver = "ESRI Shapefile",
      delete_layer = TRUE,
      quiet = TRUE
    )
  )

  # Create a ZIP with the relative paths
  zip_path <- fs::path(td, "aagis.zip")
  all_files <- fs::dir_ls(shp_dir, recurse = FALSE, type = "file")
  files_rel <- fs::path_rel(all_files, start = files_dir)

  # Helper will skip if system 'zip' is unavailable
  create_zip(zip_path = zip_path, files_dir = files_dir, files_rel = files_rel)

  # Mock only the unzip step to ensure it extracts next to 'x'
  res <- testthat::with_mocked_bindings(
    {
      withr::with_options(list(read.abares.verbosity = "quiet"), {
        read_aagis_regions(x = zip_path)
      })
    },
    .unzip_file = function(x) {
      utils::unzip(x, exdir = fs::path_dir(x))
      invisible(x)
    }
  )

  # ---- Assertions ----
  testthat::expect_s3_class(res, "sf")
  testthat::expect_true(all(sf::st_is_valid(res)))

  # Column checks
  testthat::expect_false("aagis" %in% names(res))
  testthat::expect_false(any(c("name", "class", "zone") %in% names(res)))
  testthat::expect_true(all(
    c("ABARES_region", "Class", "Zone", "State") %in% names(res)
  ))

  # Values derived from 'name'
  testthat::expect_equal(res$State, c("NSW", "WA"))
  testthat::expect_equal(res$ABARES_region, c("NSW East", "WA West"))

  # The ZIP should be deleted by the function
  testthat::expect_false(fs::file_exists(zip_path))

  # Extracted folder can be cleaned up automatically with local_tempdir()
})

test_that("read_aagis_regions works with x = NULL by mocking download + unzip", {
  testthat::skip_if_offline()
  testthat::skip_if_not_installed("sf")

  # Build a fresh payload and staged ZIP we'll 'download' via mocking
  td <- withr::local_tempdir()
  files_dir <- fs::path(td, "payload")
  shp_dir <- fs::path(files_dir, "aagis")
  fs::dir_create(shp_dir)

  poly1 <- sf::st_polygon(list(rbind(
    c(10, 10),
    c(11, 10),
    c(11, 11),
    c(10, 11),
    c(10, 10)
  )))
  geom <- sf::st_sfc(poly1, crs = 4326)
  dat <- data.frame(
    name = "QLD North",
    class = "Mixed",
    zone = 3L,
    aagis = "Mixed"
  )
  aagis_sf <- sf::st_sf(dat, geometry = geom)

  invisible(
    sf::st_write(
      aagis_sf,
      dsn = shp_dir,
      layer = "aagis_asgs16v1_g5a",
      driver = "ESRI Shapefile",
      delete_layer = TRUE,
      quiet = TRUE
    )
  )

  staged_zip <- fs::path(td, "staged_aagis.zip")
  files_rel <- fs::path_rel(
    fs::dir_ls(shp_dir, type = "file"),
    start = files_dir
  )
  create_zip(
    zip_path = staged_zip,
    files_dir = files_dir,
    files_rel = files_rel
  )

  # Ensure a clean slate where the function expects to place the temp zip
  # (read_aagis_regions uses fs::path(tempdir(), "aagis.zip") when x = NULL)
  expected_temp_zip <- fs::path(tempdir(), "aagis.zip")
  expected_unzip_dir <- fs::path(tempdir(), "aagis")
  if (fs::file_exists(expected_temp_zip)) {
    fs::file_delete(expected_temp_zip)
  }
  if (fs::dir_exists(expected_unzip_dir)) {
    fs::dir_delete(expected_unzip_dir)
  }

  res <- testthat::with_mocked_bindings(
    {
      withr::with_options(list(read.abares.verbosity = "quiet"), {
        read_aagis_regions(x = NULL)
      })
    },
    .retry_download = function(url, dest, dataset_id, show_progress) {
      # Simulate a successful download by copying our staged ZIP to the target
      fs::file_copy(staged_zip, dest, overwrite = TRUE)
      invisible(dest)
    },
    .unzip_file = function(x) {
      utils::unzip(x, exdir = fs::path_dir(x))
      invisible(x)
    }
  )

  # ---- Assertions ----
  testthat::expect_s3_class(res, "sf")
  testthat::expect_true(all(sf::st_is_valid(res)))

  testthat::expect_true(all(
    c("ABARES_region", "Class", "Zone", "State") %in% names(res)
  ))
  testthat::expect_identical(res$State, "QLD")
  testthat::expect_identical(res$ABARES_region, "QLD North")

  # The temp zip created by the function should be gone
  testthat::expect_false(fs::file_exists(expected_temp_zip))
})

test_that("read_aagis_regions leaves no legacy columns", {
  testthat::skip_if_offline()
  testthat::skip_if_not_installed("sf")

  td <- withr::local_tempdir()
  files_dir <- fs::path(td, "payload")
  shp_dir <- fs::path(files_dir, "aagis")
  fs::dir_create(shp_dir)

  # Simple point geometry is fine; function is geometry-agnostic for our checks
  pt <- sf::st_point(c(100, -30))
  geom <- sf::st_sfc(pt, crs = 4326)
  dat <- data.frame(
    name = "SA Central",
    class = "Cropping",
    zone = 5L,
    aagis = "Cropping"
  )
  aagis_sf <- sf::st_sf(dat, geometry = geom)

  invisible(
    sf::st_write(
      aagis_sf,
      dsn = shp_dir,
      layer = "aagis_asgs16v1_g5a",
      driver = "ESRI Shapefile",
      delete_layer = TRUE,
      quiet = TRUE
    )
  )

  zip_path <- fs::path(td, "aagis.zip")
  files_rel <- fs::path_rel(
    fs::dir_ls(shp_dir, type = "file"),
    start = files_dir
  )
  create_zip(zip_path, files_dir, files_rel)

  res <- testthat::with_mocked_bindings(
    {
      read_aagis_regions(x = zip_path)
    },
    .unzip_file = function(x) {
      utils::unzip(x, exdir = fs::path_dir(x))
      invisible(x)
    }
  )

  # Only the cleaned set of fields should remain (plus geometry)
  kept <- c("ABARES_region", "Class", "Zone", "State", attr(res, "sf_column"))
  testthat::expect_setequal(names(res), kept)
})
