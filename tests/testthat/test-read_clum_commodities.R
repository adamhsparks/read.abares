test_that("read_clum_commodities returns an sf object from provided zip", {
  # fresh temp dir
  tmp_dir <- withr::local_tempdir()
  subdir <- file.path(tmp_dir, "CLUM_Commodities_2023")
  dir.create(subdir)

  # write shapefile set
  shp_path <- file.path(subdir, "CLUM_Commodities_2023.shp")
  dummy <- sf::st_sf(id = 1, geometry = sf::st_sfc(sf::st_point(c(0, 0))))
  sf::st_write(dummy, shp_path, quiet = TRUE, append = FALSE)

  # zip the folder
  zip_path <- tempfile(fileext = ".zip")
  old_wd <- setwd(tmp_dir)
  on.exit(setwd(old_wd), add = TRUE)
  utils::zip(zipfile = zip_path, files = "CLUM_Commodities_2023")

  # call function
  result <- read_clum_commodities(zip_path)
  expect_s3_class(result, "sf")
})


mock_retry <- function(url, dest) {
  captured <<- url

  # fresh temp dir
  tmp_dir <- withr::local_tempdir()
  subdir <- file.path(tmp_dir, "CLUM_Commodities_2023")
  dir.create(subdir)

  shp_path <- file.path(subdir, "CLUM_Commodities_2023.shp")
  dummy <- sf::st_sf(id = 1, geometry = sf::st_sfc(sf::st_point(c(1, 1))))
  sf::st_write(dummy, shp_path, quiet = TRUE, append = FALSE)

  # zip the folder, preserving structure
  old_wd <- setwd(tmp_dir)
  on.exit(setwd(old_wd), add = TRUE)
  utils::zip(zipfile = dest, files = "CLUM_Commodities_2023")
}


test_that("read_clum_commodities calls .retry_download when x is NULL", {
  captured <- NULL
  mock_retry <- function(url, dest) {
    captured <<- url
    # build a valid zip with shapefile set
    tmp_dir <- withr::local_tempdir()
    subdir <- file.path(tmp_dir, "CLUM_Commodities_2023")
    dir.create(subdir)
    shp_path <- file.path(subdir, "CLUM_Commodities_2023.shp")
    dummy <- sf::st_sf(id = 1, geometry = sf::st_sfc(sf::st_point(c(1, 1))))
    sf::st_write(dummy, shp_path, quiet = TRUE, append = FALSE)
    old_wd <- setwd(tmp_dir)
    on.exit(setwd(old_wd), add = TRUE)
    utils::zip(zipfile = dest, files = "CLUM_Commodities_2023")
  }

  tmp <- fs::path_temp("clum_commodities.zip")
  if (fs::file_exists(tmp)) fs::file_delete(tmp)

  with_mocked_bindings(
    {
      result <- read_clum_commodities() # call with x = NULL
      expect_s3_class(result, "sf")
      expect_false(is.null(captured))
      expect_match(captured, "clum_commodities_2023.zip")
    },
    .retry_download = mock_retry
  )
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
    old_wd <- setwd(tmp_dir)
    on.exit(setwd(old_wd), add = TRUE)
    utils::zip(zipfile = dest, files = "CLUM_Commodities_2023")
  }

  tmp <- fs::path_temp("clum_commodities.zip")
  if (fs::file_exists(tmp)) fs::file_delete(tmp)

  with_mocked_bindings(
    {
      result <- read_clum_commodities()
      expect_s3_class(result, "sf")
      expect_false(is.null(captured))
      expect_match(captured, "clum_commodities_2023.zip")
    },
    .retry_download = stub_retry
  )
})
