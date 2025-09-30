test_that("read_clum_commodities reads and fixes geometry (mocked download/unzip)", {
  skip_on_cran()
  skip_if_not_installed("sf")
  skip_if_not_installed("fs")
  skip_if_not_installed("withr")

  # Target directory that read_clum_commodities() expects
  cc_dir <- fs::path(tempdir(), "CLUM_Commodities_2023")

  # Clean slate for the expected directory
  if (fs::dir_exists(cc_dir)) {
    fs::dir_delete(cc_dir)
  }
  fs::dir_create(cc_dir)
  withr::defer({
    if (fs::dir_exists(cc_dir)) fs::dir_delete(cc_dir)
  })

  # Build an INVALID polygon ("bow-tie" self-intersection)
  poly <- sf::st_polygon(list(rbind(
    c(0, 0),
    c(1, 1),
    c(1, 0),
    c(0, 1),
    c(0, 0)
  )))
  sfc <- sf::st_sfc(poly, crs = 4326)
  x <- sf::st_sf(id = 1L, geometry = sfc)

  # Sanity: the source geometry is invalid
  # (Uses GEOS check when s2 is off; see below.)
  old_s2 <- sf::sf_use_s2()
  sf::sf_use_s2(FALSE)
  withr::defer(sf::sf_use_s2(old_s2), priority = "first")
  expect_false(sf::st_is_valid(x))

  # Write a shapefile where the function will read from
  shp_path <- fs::path(cc_dir, "clum_commodities.shp")
  sf::st_write(x, dsn = shp_path, quiet = TRUE)

  # Silence output from st_read() within the function
  withr::local_options(list(read.abares.verbosity = "quiet"))

  # Mock out download and unzip (no-ops; we already placed the data)
  retry_mock <- function(url, .f) invisible(.f)
  unzip_mock <- function(x) invisible(x)

  testthat::with_mocked_bindings(
    {
      out <- read_clum_commodities() # x = NULL path; uses tempdir()
      expect_s3_class(out, "sf")

      # --- Robust validity check across backends ---
      # Use planar (GEOS) validity for consistency in tests.
      # (s2 validity on lon/lat can disagree with GEOS for some invalid inputs)
      old_s2_local <- sf::sf_use_s2()
      sf::sf_use_s2(FALSE)
      on.exit(sf::sf_use_s2(old_s2_local), add = TRUE)

      # If MakeValid returned a collection, extract polygonal parts
      gt <- as.character(sf::st_geometry_type(out, by_geometry = TRUE))
      if (any(gt == "GEOMETRYCOLLECTION")) {
        out <- sf::st_collection_extract(out, "POLYGON", warn = FALSE)
      }

      # After extraction we expect at least one feature and it should be valid
      expect_gte(nrow(out), 1L)
      expect_true(all(sf::st_is_valid(out)))
      # And the geometry should be polygonal
      expect_true(all(
        as.character(sf::st_geometry_type(out)) %in%
          c("POLYGON", "MULTIPOLYGON")
      ))
    },
    .retry_download = retry_mock,
    .unzip_file = unzip_mock
  )
})
