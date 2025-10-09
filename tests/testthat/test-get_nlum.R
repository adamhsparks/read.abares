test_that(".get_nlum(.x = NULL) builds the dataset folder under tempdir() and returns file listing", {
  skip_if_offline()

  ds_key <- "Y202021"
  ds_name <- "NLUM_v7_250_ALUMV8_2020_21_alb_package_20241128"

  base_tmp <- tempdir()
  zip_path <- fs::path(base_tmp, sprintf("%s.zip", ds_name))
  ds_dir <- fs::path(base_tmp, ds_name)

  fs::dir_create(ds_dir)
  withr::defer({
    if (fs::dir_exists(ds_dir)) {
      fs::dir_delete(ds_dir)
    }
    if (fs::file_exists(zip_path)) fs::file_delete(zip_path)
  })

  f1 <- fs::path(ds_dir, "file_a.tif")
  f2 <- fs::path(ds_dir, "file_b.tif")
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
      out <- .get_nlum(.data_set = ds_key, .x = NULL)

      expect_type(out, "character")
      expect_true(all(fs::file_exists(out)))
      expect_setequal(basename(out), c("file_a.tif", "file_b.tif"))
      expect_true(all(dirname(out) == ds_dir))
    }
  )
})

test_that(".get_nlum with explicit local zip path (.x) returns listing under sibling folder", {
  skip_if_offline()

  root <- withr::local_tempdir()
  zip_path <- fs::path(root, "my_nlum.zip")
  ds_dir <- fs::path(root, "my_nlum")

  fs::dir_create(ds_dir)
  f1 <- fs::path(ds_dir, "alpha.tif")
  f2 <- fs::path(ds_dir, "beta.tif")
  writeBin(raw(0L), f1)
  writeBin(raw(0L), f2)

  out <- .get_nlum(.data_set = "Y201516", .x = zip_path)

  expect_type(out, "character")
  expect_true(all(fs::file_exists(out)))
  expect_setequal(basename(out), c("alpha.tif", "beta.tif"))
  expect_true(all(dirname(out) == ds_dir))
})

test_that(".get_nlum errors for unknown dataset key when .x is NULL", {
  skip_if_offline()
  expect_error(.get_nlum(.data_set = "NOT_A_KEY", .x = NULL))
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
