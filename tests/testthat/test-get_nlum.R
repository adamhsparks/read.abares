testthat::test_that(".get_nlum(.x = NULL) builds the dataset folder under tempdir() and returns file listing", {
  testthat::skip_on_cran()

  # Choose a dataset key and the exact folder name the function derives from switch()
  ds_key <- "Y202021"
  ds_name <- "NLUM_v7_250_ALUMV8_2020_21_alb_package_20241128"

  # The function sets .x <- fs::path(tempdir(), sprintf("%s.zip", ds_name))
  # and then lists: fs::dir_ls(fs::path(fs::path_dir(.x), ds_name)) == tempdir()/ds_name
  base_tmp <- tempdir()
  zip_path <- fs::path(base_tmp, sprintf("%s.zip", ds_name))
  ds_dir <- fs::path(base_tmp, ds_name)

  # Create expected dir and some fake files inside (as the "unzipped" content)
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

  # Mocks: pretend to download and unzip; just create the zip path so file_exists(.x) becomes TRUE
  retry_mock <- function(url, .f) {
    fs::file_create(.f)
    invisible(.f)
  }
  unzip_mock <- function(x) invisible(x)

  testthat::with_mocked_bindings(
    {
      out <- .get_nlum(.data_set = ds_key, .x = NULL)

      testthat::expect_type(out, "character")
      testthat::expect_true(all(fs::file_exists(out)))
      testthat::expect_setequal(basename(out), c("file_a.tif", "file_b.tif"))
      # Ensure it looked under tempdir()/ds_name
      testthat::expect_true(all(dirname(out) == ds_dir))
    },
    .retry_download = retry_mock,
    .unzip_file = unzip_mock
  )
})


testthat::test_that(".get_nlum with explicit local zip path (.x) returns listing under sibling folder", {
  testthat::skip_on_cran()

  # Arrange: create a root temp area with a zip file name and a sibling folder (without actually zipping)
  root <- withr::local_tempdir()
  zip_path <- fs::path(root, "my_nlum.zip")
  ds_dir <- fs::path(root, "my_nlum")

  fs::dir_create(ds_dir)
  f1 <- fs::path(ds_dir, "alpha.tif")
  f2 <- fs::path(ds_dir, "beta.tif")
  writeBin(raw(0L), f1)
  writeBin(raw(0L), f2)

  # Act: when .x is supplied, function ignores .data_set for path derivation
  #      and uses ds <- basename(file_path_sans_ext(.x)) -> "my_nlum"
  out <- .get_nlum(.data_set = "Y201516", .x = zip_path)

  # Assert
  testthat::expect_type(out, "character")
  testthat::expect_true(all(fs::file_exists(out)))
  testthat::expect_setequal(basename(out), c("alpha.tif", "beta.tif"))
  testthat::expect_true(all(dirname(out) == ds_dir))
})


testthat::test_that(".get_nlum errors for unknown dataset key when .x is NULL", {
  testthat::skip_on_cran()

  # Unknown key makes switch() return NULL; subsequent code will fail -> expect error
  testthat::expect_error(.get_nlum(.data_set = "NOT_A_KEY", .x = NULL))
})

# tests/testthat/test-nlum-snapshot.R

testthat::test_that("summary header snapshot: print.read.abares.agfd.nlum.files", {
  testthat::skip_on_cran()

  # Keep snapshot output stable across environments
  testthat::local_reproducible_output(width = 80)
  withr::local_options(cli.num_colors = 0)

  # Build minimal input: a character vector of file paths (as the printer expects)
  files <- c(
    "/tmp/NLUM/sample1.tif",
    "/tmp/NLUM/sample2.tif",
    "/tmp/NLUM/sample3.tif"
  )
  class(files) <- c("read.abares.agfd.nlum.files", class(files))

  # Snapshot the full printed banner+list
  testthat::expect_snapshot({
    print.read.abares.agfd.nlum.files(files)
  })
})
