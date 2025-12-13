test_that(".get_clum constructs correct URL for clum_50m_2023_v2", {
  captured <- NULL
  mock_retry <- function(url, dest) {
    captured <<- url
    fs::file_create(dest)
  }

  # Ensure the temp file does not exist so .retry_download is called
  tmp <- fs::path_temp("clum_50m_2023_v2.zip")
  if (fs::file_exists(tmp)) fs::file_delete(tmp)

  with_mocked_bindings(
    {
      result <- .get_clum("clum_50m_2023_v2")
      expect_true(fs::file_exists(result))
      expect_match(captured, "clum_50m_2023_v2.zip")
    },
    .retry_download = mock_retry
  )
})

test_that(".get_clum constructs correct URL for scale_date_update", {
  captured <- NULL
  mock_retry <- function(url, dest) {
    captured <<- url
    fs::file_create(dest)
  }

  # Ensure the temp file does not exist so .retry_download is called
  tmp <- fs::path_temp("scale_date_update.zip")
  if (fs::file_exists(tmp)) {
    fs::file_delete(tmp)
  }

  with_mocked_bindings(
    {
      result <- .get_clum("scale_date_update")
      expect_true(fs::file_exists(result))
      expect_match(captured, "scale_date_update.zip")
    },
    .retry_download = mock_retry
  )
})

test_that(".get_clum returns expected temp file path when file already exists", {
  tmp <- fs::path_temp("scale_date_update.zip")
  fs::file_create(tmp) # Pretend file already exists
  result <- .get_clum("scale_date_update")
  expect_identical(result, tmp)
  expect_true(fs::file_exists(result))
})

test_that(".get_clum handles invalid dataset names", {
  expect_error(.get_clum("not_a_dataset"))
})
