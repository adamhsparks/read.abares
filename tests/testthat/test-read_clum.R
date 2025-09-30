test_that(".get_clum returns .tif paths when given a local zip (.x)", {
  skip_on_cran()

  # Build a synthetic zip with the *expected* top-level directory name
  #   for the dataset, containing dummy .tif files.
  ds_name <- "clum_50m_2023_v2"

  # Work under an isolated temp directory
  root <- withr::local_tempdir()
  ds_dir <- fs::path(root, ds_name)
  fs::dir_create(ds_dir)

  # Add some files (at different depths) the function should find
  fs::file_create(fs::path(ds_dir, "b.tif"))
  fs::dir_create(fs::path(ds_dir, "rasters"))
  fs::file_create(fs::path(ds_dir, "rasters", "a.tif"))

  # Create the zip with the dataset directory as the top-level entry
  zip_path <- fs::path(root, sprintf("%s.zip", ds_name))
  create_zip(zip_path, files_dir = root, files_rel = ds_name) # uses utils::zip

  # Mock .unzip_file to unzip to the same directory as the zip file
  unzip_mock <- function(x) {
    utils::unzip(zipfile = x, exdir = fs::path_dir(x))
    invisible(x)
  }

  testthat::with_mocked_bindings(
    {
      res <- .get_clum(.data_set = ds_name, .x = zip_path)
      expect_true(all(fs::file_exists(res)))
      # We created only these two .tif files
      expect_setequal(fs::path_file(res), c("a.tif", "b.tif"))
      # And they should both live under the unzipped dataset directory
      expect_true(all(grepl(fs::path(root, ds_name), res, fixed = TRUE)))
    },
    .unzip_file = unzip_mock
  )
})

test_that(".get_clum downloads (mocked) and unzips when .x is NULL", {
  skip_on_cran()
  skip_if_not_installed("fs")
  skip_if_not_installed("withr")

  ds_name <- "clum_50m_2023_v2"

  # Prepare a prebuilt zip (NOT at the final target path)
  staging <- withr::local_tempdir()
  ds_dir <- fs::path(staging, ds_name)
  fs::dir_create(ds_dir)
  fs::file_create(fs::path(ds_dir, "foo.tif"))

  prebuilt_zip <- fs::path(staging, sprintf("%s.zip", ds_name))
  create_zip(prebuilt_zip, files_dir = staging, files_rel = ds_name)

  # This is where .get_clum() will try to put it when .x is NULL
  target_zip <- fs::path(tempdir(), sprintf("%s.zip", ds_name))
  # Ensure a clean slate
  if (fs::file_exists(target_zip)) {
    fs::file_delete(target_zip)
  }
  target_dir <- fs::path(tempdir(), ds_name)
  if (fs::dir_exists(target_dir)) {
    fs::dir_delete(target_dir)
  }

  # Capture the URL chosen by the switch() inside .get_clum
  last_url <- NULL

  retry_mock <- function(url, .f) {
    # record the URL and copy our prebuilt zip to the expected target
    last_url <<- url
    fs::file_copy(prebuilt_zip, .f, overwrite = TRUE)
    invisible(.f)
  }

  unzip_mock <- function(x) {
    utils::unzip(zipfile = x, exdir = fs::path_dir(x))
    invisible(x)
  }

  withr::defer({
    if (fs::file_exists(target_zip)) {
      fs::file_delete(target_zip)
    }
    if (fs::dir_exists(target_dir)) fs::dir_delete(target_dir)
  })

  testthat::with_mocked_bindings(
    {
      res <- .get_clum(.data_set = ds_name, .x = NULL)
      # should list foo.tif from the unzipped dataset directory
      expect_length(res, 1L)
      expect_match(fs::path_file(res), "foo\\.tif$")
      expect_true(fs::file_exists(res))
      # sanity check the correct resource ID is used for this dataset
      expect_true(grepl(
        "6deab695-3661-4135-abf7-19f25806cfd7",
        last_url,
        fixed = TRUE
      ))
    },
    .retry_download = retry_mock,
    .unzip_file = unzip_mock
  )
})

test_that(".get_clum works for scale_date_update with local zip", {
  skip_on_cran()
  skip_if_not_installed("fs")
  skip_if_not_installed("withr")

  ds_name <- "scale_date_update"

  root <- withr::local_tempdir()
  ds_dir <- fs::path(root, ds_name)
  fs::dir_create(ds_dir)
  fs::file_create(fs::path(ds_dir, "meta.tif"))

  zip_path <- fs::path(root, sprintf("%s.zip", ds_name))
  create_zip(zip_path, files_dir = root, files_rel = ds_name)

  unzip_mock <- function(x) {
    utils::unzip(zipfile = x, exdir = fs::path_dir(x))
    invisible(x)
  }

  testthat::with_mocked_bindings(
    {
      res <- .get_clum(.data_set = ds_name, .x = zip_path)
      expect_length(res, 1L)
      expect_match(fs::path_file(res), "meta\\.tif$")
      expect_true(fs::file_exists(res))
    },
    .unzip_file = unzip_mock
  )
})
