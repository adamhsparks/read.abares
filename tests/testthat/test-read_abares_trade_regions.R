test_that("read_abares_trade_regions returns a data.table", {
  tmp <- tempfile(fileext = ".csv")
  write.csv(
    data.frame(region = c("WA", "NSW"), value = c(10, 20)),
    tmp,
    row.names = FALSE
  )

  result <- read_abares_trade_regions(tmp)
  expect_s3_class(result, "data.table")
})

test_that("read_abares_trade_regions reads provided file correctly", {
  tmp <- tempfile(fileext = ".csv")
  write.csv(
    data.frame(region = c("QLD", "VIC"), value = c(1, 2)),
    tmp,
    row.names = FALSE
  )

  result <- read_abares_trade_regions(tmp)
  expect_identical(result$region, c("QLD", "VIC"))
  expect_identical(result$value, c(1, 2))
})

test_that("read_abares_trade_regions calls .retry_download when x is NULL", {
  captured <- NULL
  mock_retry <- function(url, dest) {
    captured <<- url
    fs::file_create(dest)
    write.csv(data.frame(region = "Mock", value = 99), dest, row.names = FALSE)
  }

  tmp <- fs::path_temp("trade_regions")
  if (fs::file_exists(tmp)) fs::file_delete(tmp)

  with_mocked_bindings(
    {
      result <- read_abares_trade_regions()
      expect_true(fs::file_exists(tmp))
      expect_match(captured, "1033841/2")
      expect_identical(result$region, "Mock")
    },
    .retry_download = mock_retry
  )
})

test_that("read_abares_trade_regions skips download if file already exists", {
  tmp <- fs::path_temp("trade_regions")
  write.csv(data.frame(region = "Existing", value = 42), tmp, row.names = FALSE)

  result <- read_abares_trade_regions(tmp)
  expect_identical(result$region, "Existing")
})

test_that("read_abares_trade_regions errors on invalid path", {
  expect_error(read_abares_trade_regions("not_a_real_file.csv"))
})
