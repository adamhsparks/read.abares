test_that("read_clum_commodities returns an sf object from provided zip", {
  zip_path <- test_path("testdata", "test_clum.zip")
  result <- read_clum_commodities(zip_path)
  expect_s3_class(result, "sf")
})

test_that("read_clum_commodities calls .retry_download when x is NULL", {
  captured <- NULL
  zipfile <- test_path("testdata", "test_clum.zip")

  stub_retry <- function(url, dest) {
    captured <<- url
    file.copy(zipfile, dest, overwrite = TRUE)
  }

  tmp <- fs::path_temp("clum_commodities. zip")
  if (fs::file_exists(tmp)) {
    fs::file_delete(tmp)
  }

  with_mocked_bindings(
    {
      result <- read_clum_commodities()
      expect_s3_class(result, "sf")
      expect_false(is.null(captured))
      expect_match(captured, "clum_commodities_2023.zip")
    },
    .retry_download = stub_retry
  )
})
