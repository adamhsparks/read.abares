test_that(".get_agfd returns correct file names for fixed prices", {
  fake_files <- c(
    fs::path_temp("c2020_file.nc"),
    fs::path_temp("c2021_file.nc"),
    fs::path_temp("c2019_file.nc")
  )

  with_mocked_bindings(
    .read_ncdf_from_zip = function(zip_path, .fixed_prices) fake_files,
    .retry_download = function(url, dest) NULL,
    .file_exists = function(path) TRUE,
    {
      result <- .get_agfd(.fixed_prices = TRUE, .yyyy = 2020:2021)
      expect_named(result, c("year_2020", "year_2021"))
      expect_true(all(grepl("2020|2021", result)))
    }
  )
})

test_that(".get_agfd calls .retry_download if file missing", {
  tmpfile <- fs::path_temp("historical_climate_prices.zip")
  if (fs::file_exists(tmpfile)) fs::file_delete(tmpfile)

  called <- FALSE
  with_mocked_bindings(
    .file_exists = function(path) FALSE, # force missing file
    .retry_download = function(url, dest) {
      called <<- TRUE
    },
    .read_ncdf_from_zip = function(zip_path, .fixed_prices) {
      # return at least one fake file so names() assignment works
      fs::path_temp("c1991_file.nc")
    },
    {
      .get_agfd(.fixed_prices = FALSE, .yyyy = 1991)
      expect_true(called)
    }
  )
})


test_that(".read_ncdf_from_zip extracts files correctly", {
  tmpzip <- tempfile(fileext = ".zip")
  tmpdir <- fs::path_temp("historical_climate_prices_fixed")
  fs::dir_create(tmpdir) # make sure the folder exists

  ncfile <- file.path(tmpdir, "c2020_test.nc")
  writeLines("dummy", ncfile)

  # zip the folder, not just the file
  utils::zip(tmpzip, files = ncfile)

  result <- .read_ncdf_from_zip(zip_path = tmpzip, .fixed_prices = TRUE)
  expect_true(any(grepl("c2020_test.nc", result)))
})


test_that(".copy_local_agfd_zip copies and reads correctly", {
  tmpzip <- tempfile(fileext = ".zip")
  tmpdir <- fs::path_temp("historical_climate_prices_fixed")
  fs::dir_create(tmpdir)

  ncfile <- file.path(tmpdir, "c2021_test.nc")
  writeLines("dummy", ncfile)

  utils::zip(tmpzip, files = ncfile)

  result <- .copy_local_agfd_zip(tmpzip)
  expect_true(any(grepl("c2021_test.nc", result)))
})
