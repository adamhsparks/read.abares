test_that("reads provided path without calling .retry_download", {
  tmp <- withr::local_tempfile()
  write_csv_payload(tmp, text = "Region,Code\nWheat,1\nBarley,2\n")

  testthat::local_mocked_bindings(
    .retry_download = function(...) stop(".retry_download should not be called")
  )

  out <- read_abares_trade_regions(tmp)
  expect_s3_class(out, "data.table")
  expect_equal(nrow(out), 2L)
  expect_equal(names(out), c("Region", "Code"))
  expect_identical(out$Region, c("Wheat", "Barley"))
  expect_equal(as.numeric(out$Code), c(1, 2))
})

test_that("x=NULL: mocked .retry_download writes CSV then read", {
  csv <- "Region,Code\nCanola,3\nOats,4\n"
  testthat::local_mocked_bindings(
    .retry_download = function(url, .f) {
      writeLines(csv, .f)
      invisible(NULL)
    }
  )
  out <- read_abares_trade_regions()
  expect_s3_class(out, "data.table")
  expect_identical(out$Region, c("Canola", "Oats"))
  expect_equal(as.numeric(out$Code), c(3, 4))
})

test_that("non-existent path errors", {
  bad <- fs::path(tempdir(), "does_not_exist.csv")
  expect_error(read_abares_trade_regions(bad))
})
