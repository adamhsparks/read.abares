# tests/testthat/helper-coverage.R

# Valid sf object when sf is present
fake_sf <- function(n = 2L) {
  if (requireNamespace("sf", quietly = TRUE)) {
    xs <- 115 + seq_len(n) * 0.01
    ys <- -31 - seq_len(n) * 0.01
    pts <- sf::st_sfc(
      lapply(seq_len(n), function(i) sf::st_point(c(xs[i], ys[i]))),
      crs = 4326
    )
    sf::st_sf(id = seq_len(n), name = c("A", "B")[seq_len(n)], geometry = pts)
  } else {
    df <- data.frame(
      id = seq_len(n),
      name = c("A", "B")[seq_len(n)],
      stringsAsFactors = FALSE
    )
    df$geometry <- I(vector("list", n))
    structure(df, class = c("sf", "data.frame"), sf_column = "geometry")
  }
}

# Minimal stars-like object
fake_stars <- function() {
  structure(list(data = array(1:4, dim = c(2, 2))), class = c("stars", "list"))
}

# Write quick CSV
write_csv_text <- function(path, text) {
  dir.create(dirname(path), showWarnings = FALSE, recursive = TRUE)
  writeLines(text, path)
  invisible(path)
}

# Minimal CSV content used by generic readers
minimal_csv <- function() {
  "x,y\n1,2\n3,4\n"
}

# A tiny trade CSV that matches expected renaming in the trade reader
trade_csv <- function() {
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
