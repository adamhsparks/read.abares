test_that(".get_agfd returns files for requested years when .x supplied", {
  skip_if_offline()
  td <- withr::local_tempdir()
  ds_name <- "historical_climate_prices_fixed"
  dat_dir <- fs::path(td, ds_name)
  fs::dir_create(dat_dir)

  yrs <- c(1991, 2019, 2020, 2021, 2023)
  for (y in yrs) {
    fs::file_create(fs::path(dat_dir, sprintf("ag_c%d.nc", y)))
  }

  zip_path <- fs::path(td, sprintf("%s.zip", ds_name))
  create_zip(zip_path, files_dir = td, files_rel = ds_name)

  res <- .get_agfd(
    .fixed_prices = TRUE,
    .yyyy = 2020:2021,
    .x = zip_path
  )

  expect_true(all(grepl("c2020|c2021", basename(res))))
  expect_false(any(grepl("c1991|c2019|c2023", basename(res))))
  expect_true(all(fs::file_exists(res)))
})

test_that(".get_agfd downloads via mocked .retry_download when .x = NULL (fixed prices)", {
  skip_if_offline()
  with_mocked_bindings(
    .retry_download = function(
      url,
      dest,
      dataset_id,
      show_progress = TRUE,
      ...
    ) {
      expect_match(url, "/client/en_AU/search/asset/1036161/3$")
      expect_identical(
        fs::path_file(dest),
        "historical_climate_prices_fixed.zip"
      )

      ds_name <- "historical_climate_prices_fixed"
      dat_dir <- fs::path(fs::path_dir(dest), ds_name)
      fs::dir_create(dat_dir)
      fs::file_create(fs::path(dat_dir, "x_c2020.nc"))
      fs::file_create(fs::path(dat_dir, "x_c2021.nc"))
      fs::file_create(fs::path(dat_dir, "x_c2018.nc"))

      create_zip(dest, files_dir = fs::path_dir(dest), files_rel = ds_name)
      invisible(NULL)
    },
    .unzip_file = function(x) utils::unzip(x, exdir = fs::path_dir(x)),
    {
      res <- .get_agfd(
        .fixed_prices = TRUE,
        .yyyy = 2020:2021,
        .x = NULL
      )
      expect_true(all(grepl("c2020|c2021", basename(res))))
      expect_false(any(grepl("c2018", basename(res))))
      expect_true(all(fs::file_exists(res)))
    }
  )
})

test_that(".get_agfd downloads via mocked .retry_download when .x = NULL (historical prices)", {
  skip_if_offline()
  with_mocked_bindings(
    .retry_download = function(
      url,
      dest,
      dataset_id,
      show_progress = TRUE,
      ...
    ) {
      expect_match(url, "/client/en_AU/search/asset/1036161/2$")
      expect_identical(fs::path_file(dest), "historical_climate_prices.zip")

      ds_name <- "historical_climate_prices"
      dat_dir <- fs::path(fs::path_dir(dest), ds_name)
      fs::dir_create(dat_dir)
      fs::file_create(fs::path(dat_dir, "y_c1995.nc"))
      fs::file_create(fs::path(dat_dir, "y_c1996.nc"))
      fs::file_create(fs::path(dat_dir, "y_c2010.nc"))

      create_zip(dest, files_dir = fs::path_dir(dest), files_rel = ds_name)
      invisible(NULL)
    },
    .unzip_file = function(x) utils::unzip(x, exdir = fs::path_dir(x)),
    {
      res <- .get_agfd(
        .fixed_prices = FALSE,
        .yyyy = 1995:1996,
        .x = NULL
      )
      expect_true(all(grepl("c1995|c1996", basename(res))))
      expect_false(any(grepl("c2010", basename(res))))
      expect_true(all(fs::file_exists(res)))
    }
  )
})

test_that(".get_agfd returns empty when requested years not present", {
  skip_if_offline()
  td <- withr::local_tempdir()
  ds_name <- "historical_climate_prices_fixed"
  dat_dir <- fs::path(td, ds_name)
  fs::dir_create(dat_dir)
  fs::file_create(fs::path(dat_dir, "a_c1991.nc"))
  fs::file_create(fs::path(dat_dir, "a_c1992.nc"))

  zip_path <- fs::path(td, sprintf("%s.zip", ds_name))
  create_zip(zip_path, files_dir = td, files_rel = ds_name)

  res <- .get_agfd(
    .fixed_prices = TRUE,
    .yyyy = 2020:2021,
    .x = zip_path
  )
  expect_length(res, 0L)
})
