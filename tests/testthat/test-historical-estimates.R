ns <- asNamespace("read.abares")
exports <- getNamespaceExports("read.abares")

# Readers to exercise if present (some branches use aliases like read_hist_nat_est)
candidates <- c(
  "read_historical_national_estimates",
  "read_hist_nat_est",
  "read_historical_state_estimates",
  "read_hist_st_est",
  "read_historical_regional_estimates"
)
present <- intersect(candidates, exports)
skip_if(length(present) == 0L, "No historical readers exported on this branch")

# Function-appropriate CSVs with the exact headers your code expects
csv_hist_nat <- function() {
  "Variable,Industry,Year,Value,RSE,Unit\nIncome,Grains,2020,100,5,AU$\nIncome,Grains,2021,110,4,AU$\n"
}
csv_hist_st <- function() {
  "Variable,Industry,Year,State,Value,RSE\nIncome,Grains,2020,WA,100,5\nIncome,Grains,2021,WA,110,4\n"
}
csv_hist_reg <- function() {
  "Variable,Industry,Year,ABARES region,Value,RSE\nIncome,Grains,2020,Region A,100,5\nIncome,Grains,2021,Region B,110,4\n"
}

csv_for <- function(name) {
  if (grepl("nat", name, TRUE)) {
    return(csv_hist_nat())
  }
  if (grepl("state|st_", name, TRUE)) {
    return(csv_hist_st())
  }
  if (grepl("regional", name, TRUE)) {
    return(csv_hist_reg())
  }
  return(csv_hist_nat())
}

for (fn_name in present) {
  fn <- get(fn_name, envir = ns)

  test_that(paste0(fn_name, ": x provided uses local CSV; no download"), {
    tmp <- withr::local_tempfile(fileext = ".csv")
    writeLines(csv_for(fn_name), tmp)

    testthat::local_mocked_bindings(.retry_download = function(...) {
      stop("should not run")
    })
    out <- fn(tmp)

    expect_true(data.table::is.data.table(out) || is.data.frame(out))
    expect_true(NROW(out) >= 0)
  })

  test_that(paste0(fn_name, ": x=NULL flows through mocked download"), {
    testthat::local_mocked_bindings(.retry_download = function(url, .f) {
      writeLines(csv_for(fn_name), .f)
      invisible(NULL)
    })
    out <- fn()
    expect_true(data.table::is.data.table(out) || is.data.frame(out))
  })
}
