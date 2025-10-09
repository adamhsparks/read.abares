test_that("read_abares_trade_regions() downloads via mocked .retry_download and reads/handles ragged rows (fill=TRUE)", {
  skip_if_offline()
  csv_text <- paste(
    c(
      "Region,State,Australian_port,Value",
      "Asia Pacific,WA,Fremantle,100",
      "North America,NSW,Sydney"
    ),
    collapse = "\n"
  )

  called <- FALSE

  with_mocked_bindings(
    .retry_download = function(
      url,
      dest,
      dataset_id = NULL,
      show_progress = TRUE
    ) {
      expect_match(url, "/client/en_AU/search/asset/1033841/2$")
      expect_identical(fs::path_file(dest), "trade_regions")

      fs::dir_create(fs::path_dir(dest), recurse = TRUE)
      writeLines(csv_text, dest, useBytes = TRUE)

      called <<- TRUE
      invisible(NULL)
    },
    {
      res <- read.abares::read_abares_trade_regions(x = NULL)

      # Ensure our mock was used
      expect_true(called)

      # Basic structure
      expect_s3_class(res, "data.table")
      expect_identical(nrow(res), 2L)

      # Column names as in the source (no renaming occurs in this function)
      expect_named(
        res,
        c("Region", "State", "Australian_port", "Value")
      )

      # Types and values
      expect_type(res$Region, "character")
      expect_type(res$State, "character")
      expect_type(res$Australian_port, "character")
      expect_true(is.numeric(res$Value) || is.integer(res$Value))

      # First row has numeric Value, second row is NA due to ragged input + fill=TRUE
      expect_identical(res$Value[1L], 100L)
      expect_true(is.na(res$Value[2L]))
    },
    .package = "read.abares"
  )
})

test_that("read_abares_trade_regions() reads a provided local file and does not download", {
  skip_if_offline()
  tmp <- withr::local_tempfile()
  writeLines(
    paste(
      c(
        "Region,State,Australian_port,Value",
        "Europe,SA,Port Adelaide,42",
        "Africa,QLD,Brisbane,7"
      ),
      collapse = "\n"
    ),
    tmp,
    useBytes = TRUE
  )

  with_mocked_bindings(
    .retry_download = function(...) {
      stop("`.retry_download()` should not be called when x != NULL")
    },
    {
      res <- read.abares::read_abares_trade_regions(x = tmp)

      expect_s3_class(res, "data.table")
      expect_identical(nrow(res), 2L)
      expect_named(
        res,
        c("Region", "State", "Australian_port", "Value")
      )

      expect_identical(res$Region, c("Europe", "Africa"))
      expect_identical(res$State, c("SA", "QLD"))
      expect_identical(res$Australian_port, c("Port Adelaide", "Brisbane"))
      expect_identical(as.numeric(res$Value), c(42, 7))
    },
    .package = "read.abares"
  )
})

test_that("read_abares_trade_regions() propagates errors from .retry_download", {
  skip_if_offline()
  with_mocked_bindings(
    .retry_download = function(...) stop("download failed", call. = FALSE),
    {
      expect_error(
        read.abares::read_abares_trade_regions(x = NULL),
        "download failed"
      )
    },
    .package = "read.abares"
  )
})
