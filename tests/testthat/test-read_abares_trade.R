# tests/testthat/test-read_abares_trade.R

has_read <- "read_abares_trade" %in% ls(getNamespace("read.abares"))
has_get <- "get_abares_trade" %in% ls(getNamespace("read.abares"))
skip_if_not(has_read || has_get)

call_trade <- function(...)
  if (has_read) read_abares_trade(...) else get_abares_trade(...)

.make_trade_csv_text <- function() {
  header <- c(
    "Fiscal_year",
    "Month",
    "YearMonth",
    "Calendar_year",
    "TradeCode",
    "Overseas_location",
    "State",
    "Australian_port",
    "Unit",
    "TradeFlow",
    "ModeOfTransport",
    "Value",
    "Quantity",
    "confidentiality_flag"
  )
  rows <- list(
    c(
      "2023-24",
      "Jan",
      "2023-01",
      "2023",
      "0101",
      "NZ",
      "WA",
      "Fremantle",
      "t",
      "Export",
      "Sea",
      "1000",
      "10",
      ""
    ),
    c(
      "2023-24",
      "Feb",
      "2023-02",
      "2023",
      "0101",
      "US",
      "WA",
      "Fremantle",
      "t",
      "Import",
      "Air",
      "2000",
      "20",
      ""
    )
  )
  paste(
    paste(header, collapse = ","),
    paste(sapply(rows, function(r) paste(r, collapse = ",")), collapse = "\n"),
    sep = "\n"
  )
}

test_that("Trade: local CSV path; no download", {
  tmp <- withr::local_tempfile(fileext = ".csv")
  writeLines(.make_trade_csv_text(), tmp)

  testthat::local_mocked_bindings(
    .retry_download = function(...) stop("should not run")
  )

  out <- call_trade(tmp)
  expect_s3_class(out, "data.table")
  expect_true(nrow(out) >= 2L)
})

test_that("Trade: x=NULL => mocked download writes a real zip that fread can read", {
  # We create a real .zip at the *exact* path the function will read.
  # Inside the zip we place a single CSV with expected header+rows.
  testthat::local_mocked_bindings(
    .retry_download = function(url, .f) {
      # Stage a CSV
      stage_dir <- withr::local_tempdir()
      csv_path <- file.path(stage_dir, "trade.csv")
      writeLines(.make_trade_csv_text(), csv_path)

      # Ensure target dir exists
      dir.create(dirname(.f), showWarnings = FALSE, recursive = TRUE)

      # Create a real .zip at .f containing trade.csv (no subdirs)
      old <- setwd(stage_dir)
      on.exit(setwd(old), add = TRUE)
      # On all platforms, utils::zip writes a proper zip; -j behaviour achieved via setwd
      utils::zip(zipfile = .f, files = basename(csv_path))
      invisible(NULL)
    }
  )

  out <- call_trade()
  expect_s3_class(out, "data.table")
  expect_true(nrow(out) >= 2L)
})

test_that("Trade: download error propagates", {
  testthat::local_mocked_bindings(
    .retry_download = function(...) stop("timeout")
  )
  expect_error(call_trade(), "timeout")
})
