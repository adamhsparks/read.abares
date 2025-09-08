# Helper to generate tiny on-the-fly fixtures for topsoil thickness tests.
# No caching assumptions; we only write to temp paths for the mocked download.

make_fake_topsoil_tif <- function(vals = c(10, 20, 30, 40)) {
  testthat::skip_if_not_installed("terra")
  tf <- tempfile(fileext = ".tif")

  r <- terra::rast(
    ncols = 2, nrows = 2,
    xmin = 0, xmax = 2, ymin = 0, ymax = 2,
    crs = "EPSG:4326"
  )
  terra::values(r) <- vals
  terra::writeRaster(r, tf, overwrite = TRUE)
  tf
}

# Pack a single .tif into a .zip (for implementations that download ZIPs)
zip_with_tif <- function(tif) {
  zf <- tempfile(fileext = ".zip")
  old <- setwd(tempdir())
  on.exit(setwd(old), add = TRUE)
  file.copy(tif, "topsoil.tif", overwrite = TRUE)
  utils::zip(zipfile = zf, files = "topsoil.tif")
  unlink("topsoil.tif")
  zf
}

# A flexible mock for .retry_download that writes either a .tif or .zip
# depending on the requested destfile (no real network).
mock_retry_download_factory <- function(src_tif) {
  function(.f, ...) {
    dots <- list(...)
    # Choose destination
    destfile <- dots$destfile
    if (is.null(destfile)) {
      # Fall back to URL basename or a default under tempdir()
      url <- if (!is.null(dots$url)) dots$url else "topsoil_thickness.tif"
      bn  <- basename(url)
      if (!grepl("\\.(tif|tiff|zip)$", bn, ignore.case = TRUE)) {
        bn <- paste0(bn, ".tif")
      }
      destfile <- file.path(tempdir(), bn)
    } else {
      dir.create(dirname(destfile), recursive = TRUE, showWarnings = FALSE)
    }

    if (grepl("\\.zip$", destfile, ignore.case = TRUE)) {
      zf <- zip_with_tif(src_tif)
      file.copy(zf, destfile, overwrite = TRUE)
    } else {
      file.copy(src_tif, destfile, overwrite = TRUE)
    }
    invisible(destfile)
  }
}
