testthat::test_that("parse_abs_production_data (horticulture, multiple sheets) returns unified wide data.table with expected columns, types, and values", {
  testthat::skip_if_offline()

  # Build a horticulture-style sheet:
  #  - Title row BEFORE header (so pre-header rows are dropped)
  #  - Header row: "Region codes" | "Region" | "Data item" | "2022-23" | "2023-24"
  #  - Include the string "Horticulture" somewhere to trigger the horticulture branch
  make_hort_sheet <- function(values, include_marker = TRUE) {
    title <- data.frame(
      A = "",
      B = "Some Horticulture Title",
      C = "",
      D = "",
      E = "",
      stringsAsFactors = FALSE
    )
    header <- data.frame(
      A = "Region codes",
      B = "Region",
      C = "Data item",
      D = "2022-23",
      E = "2023-24",
      stringsAsFactors = FALSE
    )
    body <- data.frame(
      A = values$code,
      B = values$region,
      C = values$item,
      D = values$y1,
      E = values$y2,
      stringsAsFactors = FALSE
    )
    trailer <- data.frame(
      A = "",
      B = "",
      C = "Units: tonnes",
      D = "",
      E = "",
      stringsAsFactors = FALSE
    )

    sheet <- rbind(title, header, body, trailer)
    if (include_marker) {
      sheet <- rbind(
        sheet,
        data.frame(
          A = "",
          B = "Horticulture – notes",
          C = "",
          D = "",
          E = "",
          stringsAsFactors = FALSE
        )
      )
    }
    names(sheet) <- LETTERS[1:5]
    sheet
  }

  hort1 <- make_hort_sheet(list(
    code = c("0", "1", "2"),
    region = c("Australia", "NSW", "VIC"),
    item = c("Apples - tonnes", "Apples - tonnes", "Apples - tonnes"),
    y1 = c("100", "200", "."),
    y2 = c("110", "np", "310")
  ))
  hort2 <- make_hort_sheet(list(
    code = c("0", "1", "2"),
    region = c("Australia", "NSW", "VIC"),
    item = c("Citrus - tonnes", "Citrus - tonnes", "Citrus - tonnes"),
    y1 = c("500", "600", "700"),
    y2 = c("510", "np", "710")
  ))

  wf <- withr::local_tempfile(fileext = ".xlsx")
  writexl::write_xlsx(
    x = list(
      Cover = data.frame(X = "no data", stringsAsFactors = FALSE), # dropped
      `Hort apples` = hort1,
      `Hort citrus` = hort2,
      Notes = data.frame(X = "copyright", stringsAsFactors = FALSE) # dropped
    ),
    path = wf
  )
  withr::defer({
    if (fs::file_exists(wf)) fs::file_delete(wf)
  })

  res <- parse_abs_production_data(wf)

  # Class & core columns
  testthat::expect_s3_class(res, "data.table")
  testthat::expect_true(all(
    c("region", "region_code", "commodity", "units") %in% names(res)
  ))
  testthat::expect_identical(
    names(res)[1:4],
    c("region", "region_code", "commodity", "units")
  )

  # Year columns (wide format)
  testthat::expect_true(all(c("2022-23", "2023-24") %in% names(res)))

  # Factor coercion for region and region_code
  testthat::expect_true(is.factor(res[["region"]]))
  testthat::expect_true(is.factor(res[["region_code"]]))

  # Numeric coercion for year columns
  if (ncol(res) >= 5) {
    for (j in 5:ncol(res)) {
      testthat::expect_type(res[[j]], "double")
    }
  }

  # Split of "Data item" into commodity + units
  testthat::expect_true(all(res$units %in% "tonnes"))
  testthat::expect_true(all(res$commodity %in% c("Apples", "Citrus")))

  # NA handling: "np" and "." -> NA
  apples_nsw <- res[res$commodity == "Apples" & res$region == "NSW"]
  apples_vic <- res[res$commodity == "Apples" & res$region == "VIC"]
  testthat::expect_true(is.na(apples_nsw[["2023-24"]][1])) # "np"
  testthat::expect_true(is.na(apples_vic[["2022-23"]][1])) # "."

  # Specific values: Apples / Australia / 2023-24 = 110
  apples_au <- res[res$commodity == "Apples" & res$region == "Australia"]
  testthat::expect_equal(apples_au[["2023-24"]][1], 110, tolerance = 1e-8)

  # Row count in wide format: 2 sheets * 3 regions = 6
  testthat::expect_equal(nrow(res), 6)
})

testthat::test_that("parse_abs_production_data (horticulture, single sheet) returns a single wide table with correct coercions", {
  testthat::skip_if_offline()

  sheet <- rbind(
    data.frame(
      A = "",
      B = "Some Horticulture Title",
      C = "",
      D = "",
      E = "",
      stringsAsFactors = FALSE
    ),
    data.frame(
      A = "Region codes",
      B = "Region",
      C = "Data item",
      D = "2022-23",
      E = "2023-24"
    ),
    data.frame(
      A = "0",
      B = "Australia",
      C = "Sugar cane - tonnes",
      D = "1000",
      E = "1100"
    ),
    data.frame(
      A = "1",
      B = "NSW",
      C = "Sugar cane - tonnes",
      D = "2000",
      E = "np"
    ),
    data.frame(
      A = "",
      B = "Horticulture",
      C = "",
      D = "",
      E = "",
      stringsAsFactors = FALSE
    )
  )
  names(sheet) <- LETTERS[1:5]

  wf <- withr::local_tempfile(fileext = ".xlsx")
  writexl::write_xlsx(
    list(
      Cover = data.frame(X = "xx"), # dropped
      `Cane` = sheet, # kept
      Notes = data.frame(X = "yy") # dropped
    ),
    path = wf
  )
  withr::defer({
    if (fs::file_exists(wf)) fs::file_delete(wf)
  })

  res <- parse_abs_production_data(wf)

  testthat::expect_s3_class(res, "data.table")
  testthat::expect_true(all(
    c("region", "region_code", "commodity", "units") %in% names(res)
  ))
  testthat::expect_identical(
    names(res)[1:4],
    c("region", "region_code", "commodity", "units")
  )
  testthat::expect_true(all(c("2022-23", "2023-24") %in% names(res)))
  testthat::expect_true(all(res$commodity %in% "Sugar cane"))
  testthat::expect_true(all(res$units %in% "tonnes"))
  testthat::expect_true(is.factor(res[["region"]]))
  testthat::expect_true(is.factor(res[["region_code"]]))
  if (ncol(res) >= 5) {
    for (j in 5:ncol(res)) {
      testthat::expect_type(res[[j]], "double")
    }
  }
  # Wide rows: 2 regions retained
  testthat::expect_equal(nrow(res), 2)
})

testthat::test_that("parse_abs_production_data (non-horticulture) handles 'Region' in first column and returns tidy wide output", {
  testthat::skip_if_offline()

  # Non-horticulture branch: header row has 'Region' in the first column (A)
  broad <- rbind(
    data.frame(
      A = "Some Broadacre Title",
      B = "",
      C = "",
      D = "",
      E = "",
      stringsAsFactors = FALSE
    ),
    data.frame(
      A = "Region",
      B = "Region codes",
      C = "Data item",
      D = "2022-23",
      E = "2023-24"
    ),
    data.frame(
      A = "Australia",
      B = "0",
      C = "Wheat - tonnes",
      D = "100",
      E = "110"
    ),
    data.frame(A = "NSW", B = "1", C = "Wheat - tonnes", D = "200", E = "."),
    data.frame(A = "VIC", B = "2", C = "Wheat - tonnes", D = "300", E = "np")
  )
  names(broad) <- LETTERS[1:5]

  wf <- withr::local_tempfile(fileext = ".xlsx")
  writexl::write_xlsx(
    list(
      Cover = data.frame(X = "xx"), # dropped
      `Broad` = broad, # kept
      Notes = data.frame(X = "yy") # dropped
    ),
    path = wf
  )
  withr::defer({
    if (fs::file_exists(wf)) fs::file_delete(wf)
  })

  res <- parse_abs_production_data(wf)

  testthat::expect_s3_class(res, "data.table")
  testthat::expect_true(all(
    c("region", "region_code", "commodity", "units") %in% names(res)
  ))
  testthat::expect_identical(
    names(res)[1:4],
    c("region", "region_code", "commodity", "units")
  )
  testthat::expect_true(all(c("2022-23", "2023-24") %in% names(res)))
  testthat::expect_true(all(res$commodity %in% "Wheat"))
  testthat::expect_true(all(res$units %in% "tonnes"))
  testthat::expect_true(is.factor(res[["region"]]))
  testthat::expect_true(is.factor(res[["region_code"]]))

  # Specific value check for Australia 2023-24
  wheat_au <- res[res$commodity == "Wheat" & res$region == "Australia"]
  testthat::expect_equal(wheat_au[["2023-24"]][1], 110, tolerance = 1e-8)

  # NA handling for NSW "." and VIC "np"
  wheat_nsw <- res[res$commodity == "Wheat" & res$region == "NSW"]
  wheat_vic <- res[res$commodity == "Wheat" & res$region == "VIC"]
  testthat::expect_true(is.na(wheat_nsw[["2023-24"]][1]))
  testthat::expect_true(is.na(wheat_vic[["2023-24"]][1]))

  # Wide rows: 3 regions retained
  testthat::expect_identical(nrow(res), 3L)
})

testthat::test_that("parse_abs_production_data handles header as first row (no pre-header) in both branches", {
  testthat::skip_if_offline()

  # Horticulture-like with header already first row
  hort_first_row_header <- rbind(
    data.frame(
      A = "Region codes",
      B = "Region",
      C = "Data item",
      D = "2022-23",
      E = "2023-24"
    ),
    data.frame(
      A = "0",
      B = "Australia",
      C = "Apples - tonnes",
      D = "10",
      E = "11"
    ),
    data.frame(A = "1", B = "NSW", C = "Apples - tonnes", D = "20", E = "21"),
    data.frame(
      A = "",
      B = "Horticulture",
      C = "",
      D = "",
      E = "",
      stringsAsFactors = FALSE
    )
  )
  names(hort_first_row_header) <- LETTERS[1:5]

  # Non-horticulture with header already first row
  broad_first_row_header <- rbind(
    data.frame(
      A = "Region",
      B = "Region codes",
      C = "Data item",
      D = "2022-23",
      E = "2023-24"
    ),
    data.frame(
      A = "Australia",
      B = "0",
      C = "Wheat - tonnes",
      D = "1",
      E = "2"
    ),
    data.frame(A = "NSW", B = "1", C = "Wheat - tonnes", D = "3", E = "4")
  )
  names(broad_first_row_header) <- LETTERS[1:5]

  wf1 <- withr::local_tempfile(fileext = ".xlsx")
  writexl::write_xlsx(
    list(
      Cover = data.frame(X = "xx"),
      `Hort` = hort_first_row_header,
      Notes = data.frame(X = "yy")
    ),
    path = wf1
  )
  withr::defer({
    if (fs::file_exists(wf1)) fs::file_delete(wf1)
  })
  res1 <- parse_abs_production_data(wf1)
  testthat::expect_true(all(
    c("region", "region_code", "commodity", "units") %in% names(res1)
  ))
  testthat::expect_identical(
    names(res1)[1:4],
    c("region", "region_code", "commodity", "units")
  )
  testthat::expect_identical(nrow(res1), 2L)

  wf2 <- withr::local_tempfile(fileext = ".xlsx")
  writexl::write_xlsx(
    list(
      Cover = data.frame(X = "xx"),
      `Broad` = broad_first_row_header,
      Notes = data.frame(X = "yy")
    ),
    path = wf2
  )
  withr::defer({
    if (fs::file_exists(wf2)) fs::file_delete(wf2)
  })
  res2 <- parse_abs_production_data(wf2)
  testthat::expect_true(all(
    c("region", "region_code", "commodity", "units") %in% names(res2)
  ))
  testthat::expect_identical(
    names(res2)[1:4],
    c("region", "region_code", "commodity", "units")
  )
  testthat::expect_identical(nrow(res2), 2L)
})

testthat::test_that(".find_years extracts financial years and calls the expected ABS URLs", {
  testthat::skip_if_offline()

  fake_page <- paste(
    "Australian agriculture horticulture 2018-19 and 2019-20, 2020-21;",
    "new data in 2022-23 and 2023-24. Note unrelated 1999-00 also present.",
    sep = " "
  )

  base_url <- "https://www.abs.gov.au/statistics/industry/agriculture/"
  expected <- c(
    "2018-19",
    "2019-20",
    "2020-21",
    "2022-23",
    "2023-24",
    "1999-00"
  )

  # horticulture
  {
    last_url <- NULL
    getter <- function(url) {
      last_url <<- url
      fake_page
    }
    testthat::with_mocked_bindings(
      {
        out <- .find_years("horticulture")
        testthat::expect_identical(
          last_url,
          paste0(base_url, "australian-agriculture-horticulture")
        )
        testthat::expect_identical(out, expected)
      },
      .package = "htm2txt",
      gettxt = getter
    )
  }

  # broadacre
  {
    last_url <- NULL
    getter <- function(url) {
      last_url <<- url
      fake_page
    }
    testthat::with_mocked_bindings(
      {
        out <- .find_years("broadacre")
        testthat::expect_identical(
          last_url,
          paste0(base_url, "australian-agriculture-broadacre-crops")
        )
        testthat::expect_equal(out, expected)
      },
      .package = "htm2txt",
      gettxt = getter
    )
  }

  # livestock
  {
    last_url <- NULL
    getter <- function(url) {
      last_url <<- url
      fake_page
    }
    testthat::with_mocked_bindings(
      {
        out <- .find_years("livestock")
        testthat::expect_identical(
          last_url,
          paste0(base_url, "australian-agriculture-livestock")
        )
        testthat::expect_identical(out, expected)
      },
      .package = "htm2txt",
      gettxt = getter
    )
  }
})

testthat::test_that(".find_years errors for unknown data_set key", {
  testthat::skip_if_offline()
  testthat::expect_error(.find_years("unknown_data_set"))
})
