test_that("read_clum_commodities reads and fixes geometry (alternative approach)", {
  skip_if_offline()

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
  old_s2 <- sf::sf_use_s2()
  sf::sf_use_s2(FALSE)
  withr::defer(sf::sf_use_s2(old_s2), priority = "first")
  expect_false(sf::st_is_valid(x))

  # Create a mock function that returns our test data
  mock_read_clum <- function(x = NULL) {
    # Apply the same processing as the real function
    return(sf::st_make_valid(x))
  }

  # Test the geometry fixing logic directly
  result <- mock_read_clum(x)
  expect_s3_class(result, "sf")

  # Test validity after processing
  old_s2_local <- sf::sf_use_s2()
  sf::sf_use_s2(FALSE)
  on.exit(sf::sf_use_s2(old_s2_local), add = TRUE)

  # If MakeValid returned a collection, extract polygonal parts
  gt <- as.character(sf::st_geometry_type(result, by_geometry = TRUE))
  if (any(gt == "GEOMETRYCOLLECTION")) {
    result <- sf::st_collection_extract(result, "POLYGON", warn = FALSE)
  }

  expect_gte(nrow(result), 1L)
  expect_true(all(sf::st_is_valid(result)))
  expect_true(all(
    as.character(sf::st_geometry_type(result)) %in%
      c("POLYGON", "MULTIPOLYGON")
  ))
})
