# tests/testthat/test-read_agfd_dt.R

skip_if_not("read_agfd_dt" %in% ls(getNamespace("read.abares")))

test_that("AGFD: x=NULL => download mocked; unzip + tidync pipeline mocked; worker returns DT", {
  exdir <- withr::local_tempdir()
  fake_nc <- file.path(exdir, "file.nc")
  writeLines("placeholder", fake_nc)

  testthat::local_mocked_bindings(
    .retry_download = function(url, .f) {
      writeLines("zip", .f)
      invisible(NULL)
    },
    .unzip_file = function(x) exdir
  )
  testthat::local_mocked_bindings(
    dir_ls = function(...) fake_nc,
    .package = "fs"
  )

  testthat::local_mocked_bindings(
    tidync = function(x, ...) structure(list(file = x), class = "tidync"),
    hyper_tibble = function(x, ...) data.frame(),
    .package = "tidync"
  )

  testthat::local_mocked_bindings(
    .get_agfd = function(...)
      data.table::data.table(code = c("01", "02"), name = c("Alpha", "Beta"))
  )

  out <- read_agfd_dt()
  expect_true(data.table::is.data.table(out))
  # Not asserting row count to avoid coupling to internal filtering
})
