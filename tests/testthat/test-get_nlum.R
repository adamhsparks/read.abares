test_that(".get_nlum() downloads and returns .tif file listing", {
  skip_if_offline()
  ds_key <- "Y202021"
  zip_name <- "NLUM_v7_250_ALUMV8_2020_21_alb_package_20241128"
  base_tmp <- tempdir()
  zip_path <- fs::path(base_tmp, sprintf("%s.zip", ds_key))
  ds_dir <- fs::path(base_tmp, zip_name)
  fs::dir_create(ds_dir)

  # Create dummy .tif files inside the expected subdirectory
  f1 <- fs::path(ds_dir, "file_a.tif")
  f2 <- fs::path(ds_dir, "file_b.tif")
  writeBin(raw(0L), f1)
  writeBin(raw(0L), f2)

  # Create a valid ZIP file with subdirectory structure
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
      out <- .get_nlum(.data_set = ds_key)
      expect_type(out, "character")
      expect_setequal(
        out,
        fs::path(zip_name, c("file_a.tif", "file_b.tif"))
      )
    }
  )
})

test_that(".get_nlum returns empty character if no .tif files in archive", {
  skip_if_offline()
  ds_key <- "T202021"
  zip_name <- "NLUM_v7_250_INPUTS_2020_21_geo_package_20241128"
  base_tmp <- tempdir()
  zip_path <- fs::path(base_tmp, sprintf("%s.zip", ds_key))
  ds_dir <- fs::path(base_tmp, zip_name)
  fs::dir_create(ds_dir)

  # Create a non-.tif file
  dummy_file <- fs::path(ds_dir, "readme.txt")
  writeLines("No tif files here", dummy_file)

  # Create a valid ZIP file
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
      out <- .get_nlum(.data_set = ds_key)
      expect_type(out, "character")
      expect_length(out, 0L)
    }
  )
})

test_that(".get_nlum errors for unknown dataset key", {
  skip_if_offline()
  expect_error(.get_nlum(.data_set = "NOT_A_KEY"))
})

test_that("summary header snapshot: print.read.abares.agfd.nlum.files", {
  local_reproducible_output(width = 80L)
  withr::local_options(cli.num_colors = 0L)
  files <- c(
    "/tmp/NLUM/sample1.tif",
    "/tmp/NLUM/sample2.tif",
    "/tmp/NLUM/sample3.tif"
  )
  class(files) <- c("read.abares.agfd.nlum.files", class(files))
  expect_snapshot({
    print.read.abares.agfd.nlum.files(files)
  })
})
