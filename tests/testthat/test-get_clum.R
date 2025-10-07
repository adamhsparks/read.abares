test_that(".get_clum(.x = NULL) builds the dataset folder under tempdir() and returns .tif file listing", {
  skip_if_offline()

  for (ds_key in c("clum_50m_2023_v2", "scale_date_update")) {
    base_tmp <- tempdir()
    zip_path <- fs::path(base_tmp, sprintf("%s.zip", ds_key))
    ds_dir <- fs::path(base_tmp, ds_key)

    fs::dir_create(ds_dir)
    withr::defer({
      if (fs::dir_exists(ds_dir)) {
        fs::dir_delete(ds_dir)
      }
      if (fs::file_exists(zip_path)) fs::file_delete(zip_path)
    })

    f1 <- fs::path(ds_dir, "catchment1.tif")
    f2 <- fs::path(ds_dir, "catchment2.tif")
    writeBin(raw(0L), f1)
    writeBin(raw(0L), f2)

    retry_mock <- function(url, dest, dataset_id, show_progress = TRUE, ...) {
      fs::file_create(dest)
      invisible(dest)
    }
    unzip_mock <- function(x) invisible(x)

    with_mocked_bindings(
      .retry_download = retry_mock,
      .unzip_file = unzip_mock,
      {
        out <- .get_clum(.data_set = ds_key, .x = NULL)

        expect_type(out, "character")
        expect_true(all(fs::file_exists(out)))
        expect_setequal(basename(out), c("catchment1.tif", "catchment2.tif"))
        expect_true(all(dirname(out) == ds_dir))
      }
    )
  }
})

test_that(".get_clum with explicit local zip path (.x) returns .tif listing under sibling folder", {
  skip_if_offline()

  root <- withr::local_tempdir()
  zip_path <- fs::path(root, "my_clum.zip")
  ds_key <- "clum_50m_2023_v2"
  ds_dir <- fs::path(root, ds_key) # <-- fix: directory must match .data_set

  fs::dir_create(ds_dir)
  f1 <- fs::path(ds_dir, "x1.tif")
  f2 <- fs::path(ds_dir, "x2.tif")
  writeBin(raw(0L), f1)
  writeBin(raw(0L), f2)

  unzip_mock <- function(x) invisible(x) # Do nothing

  with_mocked_bindings(
    .unzip_file = unzip_mock,
    {
      out <- .get_clum(.data_set = ds_key, .x = zip_path)

      expect_type(out, "character")
      expect_true(all(fs::file_exists(out)))
      expect_setequal(basename(out), c("x1.tif", "x2.tif"))
      expect_true(all(dirname(out) == ds_dir))
    }
  )
})


test_that(".get_clum returns empty character if no .tif files in folder", {
  skip_if_offline()

  root <- withr::local_tempdir()
  zip_path <- fs::path(root, "clum_empty.zip")
  ds_dir <- fs::path(root, "clum_empty")

  fs::dir_create(ds_dir)
  # no .tif files

  unzip_mock <- function(x) invisible(x) # Do nothing

  with_mocked_bindings(
    .unzip_file = unzip_mock,
    {
      out <- .get_clum(.data_set = "clum_empty", .x = zip_path)
      expect_type(out, "character")
      expect_length(out, 0L)
    }
  )
})


test_that(".get_clum errors for unknown dataset key when .x is NULL", {
  skip_if_offline()
  expect_error(.get_clum(.data_set = "not_a_key", .x = NULL))
})
