write_csv_payload <- function(path, text) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  con <- file(path, open = "wb")
  on.exit(close(con), add = TRUE)
  writeBin(charToRaw(enc2utf8(text)), con)
  normalizePath(path, mustWork = TRUE)
}
