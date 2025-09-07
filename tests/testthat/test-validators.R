# tests/testthat/test-validators.R

exports <- getNamespaceExports("read.abares")
reader_fns <- exports[grepl("^(read|get)_", exports)]

# Avoid duplicating explicit tests for these:
reader_fns <- setdiff(reader_fns, skip_list)

ns <- asNamespace("read.abares")

for (fn_name in reader_fns) {
  fn <- get(fn_name, envir = ns)

  test_that(paste0(fn_name, ": errors on non-existent path"), {
    bad <- fs::path(tempdir(), "no_such_file.xyz")
    # Some functions may try to unzip; avoid extra noise by mocking unzip to error clearly
    testthat::local_mocked_bindings(
      unzip = function(...) stop("bad zip"),
      .package = "utils"
    )
    expect_error(fn(bad))
  })

  test_that(paste0(fn_name, ": errors or succeeds with wrong type for x"), {
    # Pass a list to x where a path string is expected
    expect_error(fn(list(a = 1L)))
  })
}
