test_that("read_abares_trade() uses .retry_download (mocked) and parses/renames correctly", {
  # Minimal CSV content with ORIGINAL column names (before renaming)
  csv_text <- paste(
    c(
      "Fiscal_year,Month,YearMonth,Calendar_year,TradeCode,Overseas_location,State,Australian_port,Unit,TradeFlow,ModeOfTransport,Value,Quantity,confidentiality_flag",
      '2020,7,"2020.07",2020,1234,"New Zealand","WA","Fremantle","kg","Export","Sea",1000,200,"N"',
      '2021,1,"2021.01",2021,5678,"Japan","NSW","Sydney","t","Import","Air",2000,50,"C"'
    ),
    collapse = "\n"
  )

  called <- FALSE

  testthat::with_mocked_bindings(
    .retry_download = function(url, dest, dataset_id, show_progress) {
      testthat::expect_match(url, "/client/en_AU/search/asset/1033841/1$")
      testthat::expect_identical(basename(dest), "abares_trade_data.zip")
      testthat::expect_identical(dataset_id, "trade")
      testthat::expect_true(show_progress)

      tmp_dir <- withr::local_tempdir()
      csv_path <- fs::path(tmp_dir, "abares_trade_data.csv")
      writeLines(csv_text, csv_path, useBytes = TRUE)

      # Use the provided helper to create a *real* zip archive
      create_zip(
        zip_path = dest,
        files_dir = tmp_dir,
        files_rel = "abares_trade_data.csv"
      )

      called <<- TRUE
      invisible(NULL)
    },
    {
      res <- read.abares::read_abares_trade(x = NULL)

      # Ensure the mock ran
      expect_true(called)

      expect_s3_class(res, "data.table")
      expect_identical(nrow(res), 2L)

      # Renamed columns should match exactly
      expected_names <- c(
        "Fiscal_year",
        "Month",
        "Year_month",
        "Calendar_year",
        "Trade_code",
        "Overseas_location",
        "State",
        "Australian_port",
        "Unit",
        "Trade_flow",
        "Mode_of_transport",
        "Value",
        "Quantity",
        "Confidentiality_flag"
      )
      expect_setequal(names(res), expected_names)

      # Key renames exist
      expect_true(all(
        c(
          "Year_month",
          "Trade_code",
          "Trade_flow",
          "Mode_of_transport",
          "Confidentiality_flag"
        ) %in%
          names(res)
      ))

      expect_s3_class(res[["Year_month"]], "Date")
      expect_identical(
        as.character(res[["Year_month"]]),
        c("2020-07-01", "2021-01-01")
      )

      expect_identical(res[["Value"]], c(1000L, 2000L))
      expect_identical(res[["Quantity"]], c(200L, 50L))
    },
    .package = "read.abares" # IMPORTANT: pass package name as a string
  )
})

test_that("read_abares_trade() reads a provided ZIP path without calling .retry_download", {
  tmp_dir <- withr::local_tempdir()
  zip_path <- fs::path(tmp_dir, "abares_trade_data.zip")

  csv_text <- paste(
    c(
      "Fiscal_year,Month,YearMonth,Calendar_year,TradeCode,Overseas_location,State,Australian_port,Unit,TradeFlow,ModeOfTransport,Value,Quantity,confidentiality_flag",
      '2019,12,"2019.12",2019,9999,"Singapore","VIC","Melbourne","kg","Export","Air",123,10,"N"'
    ),
    collapse = "\n"
  )

  writeLines(
    csv_text,
    fs::path(tmp_dir, "abares_trade_data.csv"),
    useBytes = TRUE
  )
  create_zip(
    zip_path = zip_path,
    files_dir = tmp_dir,
    files_rel = "abares_trade_data.csv"
  )

  testthat::with_mocked_bindings(
    .retry_download = function(...) {
      stop("`.retry_download()` should not be called when x != NULL")
    },
    {
      res <- read.abares::read_abares_trade(x = zip_path)

      expect_s3_class(res, "data.table")
      expect_identical(nrow(res), 1L)

      expect_true(all(
        c(
          "Year_month",
          "Trade_code",
          "Trade_flow",
          "Mode_of_transport",
          "Confidentiality_flag"
        ) %in%
          names(res)
      ))

      expect_s3_class(res[["Year_month"]], "Date")
      expect_identical(as.character(res[["Year_month"]][1L]), "2019-12-01")

      expect_identical(res$Value[1L], 123L)
      expect_identical(res$Quantity[1L], 10L)
    },
    .package = "read.abares"
  )
})
