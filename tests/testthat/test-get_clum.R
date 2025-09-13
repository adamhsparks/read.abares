test_that(".get_clum triggers download and unzip when .x is NULL", {
  data_set <- "clum_50m_2023_v2"
  zip_path <- fs::path(tempdir(), sprintf("%s.zip", data_set))
  unzip_dir <- fs::path(fs::path_dir(zip_path), data_set)
  tif_file <- fs::path(unzip_dir, "mock.tif")

  # Mock .retry_download and .unzip_file
  testthat::local_mocked_bindings(
    .retry_download = function(url, .f) {
      fs::file_create(.f)
      invisible(list(success = TRUE, path = .f))
    },
    .unzip_file = function(path) {
      fs::dir_create(unzip_dir)
      fs::file_create(tif_file)
    },
    .env = asNamespace("read.abares")
  )

  result <- .get_clum(data_set, NULL)

  expect_true(all(fs::file_exists(result)))
  expect_true(endsWith(result, ".tif"))
  expect_identical(
    result,
    fs::dir_ls(unzip_dir, recurse = TRUE, glob = "*.tif")
  )
})


test_that("get_clum uses provided .x and unzips", {
  tmp_zip <- tempfile(fileext = ".zip")
  file.create(tmp_zip)

  # Mock .unzip_file
  local_mocked_bindings(
    .unzip_file = function(path) {
      fs::dir_create(fs::path(tempdir(), "scale_date_update"))
      fs::file_create(fs::path(tempdir(), "scale_date_update", "mock.tif"))
    },
    .env = environment(.get_clum)
  )

  result <- .get_clum("scale_date_update", tmp_zip)

  expect_true(all(fs::file_exists(result)))
  expect_true(endsWith(result, "tiff"))
})
