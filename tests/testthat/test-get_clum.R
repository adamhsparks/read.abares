test_that(".get_clum() downloads and returns .tif file listing", {
  skip_if_offline()
  for (ds_key in c("clum_50m_2023_v2", "scale_date_update")) {
    base_tmp <- tempdir()
    zip_path <- fs::path(base_tmp, sprintf("%s.zip", ds_key))
    ds_dir <- fs::path(base_tmp, ds_key)
    fs::dir_create(ds_dir)

    # Create dummy .tif files
    f1 <- fs::path(ds_dir, "catchment1.tif")
    f2 <- fs::path(ds_dir, "catchment2.tif")
    writeBin(raw(0L), f1)
    writeBin(raw(0L), f2)

    # Create a valid ZIP file with the .tif files
    old_wd <- setwd(base_tmp)
    on.exit(setwd(old_wd), add = TRUE)
    utils::zip(
      zipfile = zip_path,
      files = fs::path_rel(c(f1, f2), start = base_tmp)
    )

    retry_mock <- function(url, dest, ...) {
      fs::file_copy(zip_path, dest, overwrite = TRUE)
      invisible(dest)
    }

    with_mocked_bindings(
      .retry_download = retry_mock,
      {
        out <- .get_clum(.data_set = ds_key)
        out_paths <- fs::path(base_tmp, out)
        expect_type(out, "character")
        expect_true(all(fs::file_exists(out_paths)))
        expect_setequal(
          basename(out_paths),
          c("catchment1.tif", "catchment2.tif")
        )
      }
    )
  }
})

test_that(".get_clum returns empty character if no .tif files in archive", {
  skip_if_offline()
  ds_key <- "clum_empty"
  base_tmp <- tempdir()
  zip_path <- fs::path(base_tmp, sprintf("%s.zip", ds_key))
  ds_dir <- fs::path(base_tmp, ds_key)
  fs::dir_create(ds_dir)

  # Create a valid ZIP file with no .tif files
  dummy_file <- fs::path(ds_dir, "readme.txt")
  writeLines("No tif files here", dummy_file)

  old_wd <- setwd(base_tmp)
  on.exit(setwd(old_wd), add = TRUE)
  utils::zip(
    zipfile = zip_path,
    files = fs::path_rel(dummy_file, start = base_tmp)
  )

  retry_mock <- function(url, dest, ...) {
    fs::file_copy(zip_path, dest, overwrite = TRUE)
    invisible(dest)
  }

  with_mocked_bindings(
    .retry_download = retry_mock,
    {
      out <- .get_clum(.data_set = ds_key)
      expect_type(out, "character")
      expect_length(out, 0L)
    }
  )
})

test_that(".get_clum errors for unknown dataset key", {
  skip_if_offline()
  expect_error(.get_clum(.data_set = "not_a_key"))
})
