test_that("reads from a provided local zip file and returns a terra rast object", {
  skip_if_offline()

  # Create a valid dummy raster
  temp_dir <- withr::local_tempdir()
  tif_path <- fs::path(
    temp_dir,
    "topsoil_thick/staiar9cl__05911a01eg_geo___",
    "thpk_1.tif"
  )
  fs::dir_create(fs::path_dir(tif_path))
  r <- terra::rast(nrows = 10, ncols = 10, vals = 1:100)
  terra::writeRaster(r, tif_path, overwrite = TRUE)

  # Create dummy metadata
  txt_path <- fs::path(
    temp_dir,
    "topsoil_thick/staiar9cl__05911a01eg_geo___",
    "ANZCW1202000149.txt"
  )
  writeLines("Custodian: CSIRO Land & Water", txt_path)

  zip_path <- fs::path(temp_dir, "topsoil_thick.zip")
  utils::zip(zipfile = zip_path, files = c(tif_path, txt_path), flags = "-j")

  with_mocked_bindings(
    {
      out <- read_topsoil_thickness_terra(x = zip_path)
      expect_s4_class(out, "SpatRaster")
    },
    .get_topsoil_thickness = function(.x = NULL) {
      r <- terra::rast(tif_path)
      r <- terra::init(r, r[])
      metadata <- readtext::readtext(txt_path)
      list(
        metadata = metadata$text,
        data = r
      )
    }
  )
})

test_that("downloads when x is NULL and returns terra rast object", {
  skip_if_offline()

  temp_dir <- withr::local_tempdir()
  tif_path <- fs::path(
    temp_dir,
    "topsoil_thick/staiar9cl__05911a01eg_geo___",
    "thpk_1.tif"
  )
  fs::dir_create(fs::path_dir(tif_path))
  r <- terra::rast(nrows = 10, ncols = 10, vals = 1:100)
  terra::writeRaster(r, tif_path, overwrite = TRUE)

  txt_path <- fs::path(
    temp_dir,
    "topsoil_thick/staiar9cl__05911a01eg_geo___",
    "ANZCW1202000149.txt"
  )
  writeLines("Custodian: CSIRO Land & Water", txt_path)

  zip_path <- fs::path(temp_dir, "topsoil_thick.zip")

  with_mocked_bindings(
    {
      out <- read_topsoil_thickness_terra(x = NULL)
      expect_s4_class(out, "SpatRaster")
    },
    .get_topsoil_thickness = function(.x = NULL) {
      r <- terra::rast(tif_path)
      r <- terra::init(r, r[])
      metadata <- readtext::readtext(txt_path)
      list(
        metadata = metadata$text,
        data = r
      )
    },
    .retry_download = function(url, .f) {
      file.create(.f)
      invisible(.f)
    },
    .unzip_file = function(x) NULL
  )
})

test_that("errors cleanly when file does not exist", {
  skip_if_offline()

  bogus <- fs::path(tempdir(), "no-such-topsoil.zip")
  if (fs::file_exists(bogus)) {
    fs::file_delete(bogus)
  }

  with_mocked_bindings(
    {
      expect_error(
        read_topsoil_thickness_terra(x = bogus),
        regexp = "cannot open|does not exist|Failed to open|cannot find",
        ignore.case = TRUE
      )
    },
    .get_topsoil_thickness = function(.x = NULL) {
      stop("Failed to open file")
    }
  )
})
