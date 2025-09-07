# tests/testthat/helper-mocks.R

# Valid sf object (uses sf if installed)
fake_sf <- function(n = 2L) {
  if (requireNamespace("sf", quietly = TRUE)) {
    xs <- 115L + seq_len(n) * 0.01
    ys <- -31L - seq_len(n) * 0.01
    pts <- sf::st_sfc(
      lapply(seq_len(n), function(i) sf::st_point(c(xs[i], ys[i]))),
      crs = 4326
    )
    sf::st_sf(id = seq_len(n), name = c("A", "B")[seq_len(n)], geometry = pts)
  } else {
    # Fallback: tests that need sf skip if not installed
    d <- data.frame(
      id = seq_len(n),
      name = c("A", "B")[seq_len(n)],
      stringsAsFactors = FALSE
    )
    d$geometry <- I(vector("list", n))
    structure(d, class = c("sf", "data.frame"), sf_column = "geometry")
  }
}

# Minimal stars-like object for type assertions.
fake_stars <- function() {
  structure(
    list(data = array(1L:4L, dim = c(2L, 2L))),
    class = c("stars", "list")
  )
}

# Write a tiny CSV quickly.
write_csv_payload <- function(path, text = NULL, d = NULL) {
  if (!is.null(text)) {
    writeLines(text, path)
  } else {
    stopifnot(!is.null(d))
    con <- file(path, open = "w", encoding = "UTF-8")
    on.exit(close(con), add = TRUE)
    write.table(d, con, sep = ",", row.names = FALSE, col.names = TRUE)
  }
  invisible(path)
}
