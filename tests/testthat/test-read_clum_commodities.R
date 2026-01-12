test_that("read_clum_commodities returns an sf object from provided zip", {
  # Create base directory for test
  test_dir <- file.path(tempdir(), "test_clum")
  dir.create(test_dir, showWarnings = FALSE, recursive = TRUE)

  # Create expected subdirectory
  subdir <- file.path(test_dir, "CLUM_Commodities_2023")
  dir.create(subdir, showWarnings = FALSE)

  # Write shapefile set
  shp_path <- file.path(subdir, "CLUM_Commodities_2023.shp")
  dummy <- sf::st_sf(id = 1, geometry = sf::st_sfc(sf::st_point(c(0, 0))))
  sf::st_write(dummy, shp_path, quiet = TRUE, append = FALSE)

  # Create zip file
  zip_path <- file.path(tempdir(), "test_clum_commodities.zip")

  # Use utils::zip
  curr_dir <- getwd()
  on.exit(setwd(curr_dir), add = TRUE)
  setwd(test_dir)

  utils::zip(zip_path, files = "CLUM_Commodities_2023", flags = "-r9Xq")

  # Call function
  result <- read_clum_commodities(zip_path)
  expect_s3_class(result, "sf")
})

test_that("read_clum_commodities calls .retry_download when x is NULL", {
  captured <- NULL

  # Define a stub just for this test
  stub_retry <- function(url, dest) {
    captured <<- url

    # Build a valid zip with shapefile set
    test_dir <- file.path(tempdir(), "test_clum_null")
    dir.create(test_dir, showWarnings = FALSE, recursive = TRUE)

    subdir <- file.path(test_dir, "CLUM_Commodities_2023")
    dir.create(subdir, showWarnings = FALSE)

    shp_path <- file.path(subdir, "CLUM_Commodities_2023.shp")
    dummy <- sf::st_sf(id = 1, geometry = sf::st_sfc(sf::st_point(c(1, 1))))
    sf::st_write(dummy, shp_path, quiet = TRUE, append = FALSE)

    # Use utils::zip
    curr_dir <- getwd()
    setwd(test_dir)
    utils::zip(dest, files = "CLUM_Commodities_2023", flags = "-r9Xq")
    setwd(curr_dir)
  }

  tmp <- fs::path_temp("clum_commodities.zip")
  if (fs::file_exists(tmp)) {
    fs::file_delete(tmp)
  }

  with_mocked_bindings(
    {
      result <- read_clum_commodities() # call with x = NULL
      expect_s3_class(result, "sf")
      expect_false(is.null(captured))
      expect_match(captured, "clum_commodities_2023.zip")
    },
    .retry_download = stub_retry
  )
})
