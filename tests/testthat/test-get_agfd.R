test_that(".get_agfd returns files for requested years (fixed prices)", {
  skip_if_offline()
  with_mocked_bindings(
    .retry_download = function(url, dest, ...) {
      expect_match(url, "/client/en_AU/search/asset/1036161/3$")
      expect_identical(
        fs::path_file(dest),
        "historical_climate_prices_fixed.zip"
      )
      ds_name <- "historical_climate_prices_fixed"
      dat_dir <- fs::path(fs::path_dir(dest), ds_name)
      fs::dir_create(dat_dir)
      fs::file_create(fs::path(dat_dir, "ag_c2020.nc"))
      fs::file_create(fs::path(dat_dir, "ag_c2021.nc"))
      fs::file_create(fs::path(dat_dir, "ag_c2019.nc"))
      create_zip(dest, files_dir = fs::path_dir(dest), files_rel = ds_name)
      invisible(NULL)
    },
    {
      res <- .get_agfd(.fixed_prices = TRUE, .yyyy = 2020:2021)
      res_paths <- as.character(unlist(res))
      expect_true(all(grepl("c2020|c2021", basename(res_paths))))
      expect_false(any(grepl("c2019", basename(res_paths))))
      expect_true(all(fs::file_exists(res_paths)))
    }
  )
})

test_that(".get_agfd returns files for requested years (historical prices)", {
  skip_if_offline()
  with_mocked_bindings(
    .retry_download = function(url, dest, ...) {
      expect_match(url, "/client/en_AU/search/asset/1036161/2$")
      expect_identical(fs::path_file(dest), "historical_climate_prices.zip")
      ds_name <- "historical_climate_prices"
      dat_dir <- fs::path(fs::path_dir(dest), ds_name)
      fs::dir_create(dat_dir)
      fs::file_create(fs::path(dat_dir, "ag_c1995.nc"))
      fs::file_create(fs::path(dat_dir, "ag_c1996.nc"))
      fs::file_create(fs::path(dat_dir, "ag_c2010.nc"))
      create_zip(dest, files_dir = fs::path_dir(dest), files_rel = ds_name)
      invisible(NULL)
    },
    {
      res <- .get_agfd(.fixed_prices = FALSE, .yyyy = 1995:1996)
      res_paths <- as.character(unlist(res))
      expect_true(all(grepl("c1995|c1996", basename(res_paths))))
      expect_false(any(grepl("c2010", basename(res_paths))))
      expect_true(all(fs::file_exists(res_paths)))
    }
  )
})

test_that(".get_agfd returns empty when requested years not present", {
  skip_if_offline()
  with_mocked_bindings(
    .retry_download = function(url, dest, ...) {
      ds_name <- "historical_climate_prices_fixed"
      dat_dir <- fs::path(fs::path_dir(dest), ds_name)
      fs::dir_create(dat_dir)
      fs::file_create(fs::path(dat_dir, "ag_c1991.nc"))
      fs::file_create(fs::path(dat_dir, "ag_c1992.nc"))
      create_zip(dest, files_dir = fs::path_dir(dest), files_rel = ds_name)
      invisible(NULL)
    },
    {
      res <- .get_agfd(.fixed_prices = TRUE, .yyyy = 2020:2021)
      expect_length(res, 0L)
    }
  )
})
