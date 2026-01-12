test_that("read_clum_commodities returns an sf object from provided zip", {
  # fresh temp dir
  tmp_dir <- withr::local_tempdir()
  subdir <- file.path(tmp_dir, "CLUM_Commodities_2023")
  fs::dir_create(subdir)

  # write shapefile set
  shp_path <- file.path(subdir, "CLUM_Commodities_2023.shp")
  dummy <- sf::st_sf(id = 1, geometry = sf::st_sfc(sf::st_point(c(0, 0))))
  sf::st_write(dummy, shp_path, quiet = TRUE, append = FALSE)

  # zip the folder
  zip_path <- tempfile(fileext = ".zip")
  # Use with_dir to safely change directory just for the zip operation
  withr::with_dir(tmp_dir, {
    zip::zipr(zipfile = zip_path, files = "CLUM_Commodities_2023")
  })

  # Normalize AFTER creating the zip file
  zip_path <- normalizePath(zip_path, winslash = "/", mustWork = TRUE)

  # call function
  result <- read_clum_commodities(zip_path)
  expect_s3_class(result, "sf")
})

test_that("read_clum_commodities calls .retry_download when x is NULL", {
  captured <- NULL

  # define a stub just for this test
  stub_retry <- function(url, dest) {
    captured <<- url

    # build a valid zip with shapefile set
    tmp_dir <- withr::local_tempdir()
    subdir <- file.path(tmp_dir, "CLUM_Commodities_2023")
    dir.create(subdir)

    shp_path <- file.path(subdir, "CLUM_Commodities_2023.shp")
    dummy <- sf::st_sf(id = 1, geometry = sf::st_sfc(sf::st_point(c(1, 1))))
    sf::st_write(dummy, shp_path, quiet = TRUE, append = FALSE)

    # Zip safely using withr::with_dir inside the mock
    withr::with_dir(tmp_dir, {
      utils::zip(zipfile = dest, files = "CLUM_Commodities_2023")
    })
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
