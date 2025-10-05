testthat::test_that(".get_topsoil_thickness returns expected object from local unzipped dir", {
  testthat::skip_on_cran()

  # Arrange: the function will look in fs::path_dir(.x)
  # So pass .x = <root>/topsoil_thick.zip and place files under <root>/topsoil_thick/staiar9...
  root <- withr::local_tempdir()
  zip_path <- fs::path(root, "topsoil_thick.zip")

  geo_dir <- fs::path(root, "topsoil_thick", "staiar9cl__05911a01eg_geo___")
  fs::dir_create(geo_dir)

  # Must exist with suffixes used by your code
  fs::file_create(fs::path(geo_dir, "thpk_1")) # endsWith(..., "thpk_1")
  writeLines(
    "Custodian: CSIRO Land & Water", # endsWith(..., "ANZCW1202000149.txt")
    fs::path(geo_dir, "ANZCW1202000149.txt")
  )

  # SpatRaster in-memory; we mock terra::rast() to return this
  r <- terra::rast(ncols = 2, nrows = 2, xmin = 0, xmax = 2, ymin = 0, ymax = 2)
  terra::values(r) <- as.numeric(1:4)

  # Fixed: return the directory containing the files, not the zip path
  unzip_mock <- function(x) {
    return(geo_dir) # Return the directory, not the zip path
  }

  terra_rast_mock <- function(...) r

  # Mock readtext to return expected structure
  readtext_mock <- function(file) {
    list(text = "Custodian: CSIRO Land & Water")
  }

  testthat::with_mocked_bindings(
    {
      testthat::with_mocked_bindings(
        {
          testthat::with_mocked_bindings(
            {
              res <- .get_topsoil_thickness(.x = zip_path)

              # Structure & classes
              testthat::expect_type(res, "list")
              testthat::expect_s3_class(res, "read.abares.topsoil.thickness")
              testthat::expect_true(all(c("metadata", "data") %in% names(res)))
              testthat::expect_type(res$metadata, "character")
              testthat::expect_s4_class(res$data, "SpatRaster")

              # Metadata content
              testthat::expect_match(
                res$metadata,
                "Custodian: CSIRO Land & Water",
                fixed = TRUE
              )
            },
            .package = "readtext",
            readtext = readtext_mock
          )
        },
        .package = "terra",
        rast = terra_rast_mock
      )
    },
    .unzip_file = unzip_mock
  )
})

testthat::test_that(".get_topsoil_thickness with .x = NULL uses tempdir() and returns valid object", {
  testthat::skip_on_cran()

  # Arrange: with .x = NULL the function uses tempdir()
  base_tmp <- tempdir()
  zip_path <- fs::path(base_tmp, "topsoil_thick.zip")
  geo_dir <- fs::path(base_tmp, "topsoil_thick", "staiar9cl__05911a01eg_geo___")

  fs::dir_create(geo_dir)
  withr::defer({
    if (fs::dir_exists(fs::path(base_tmp, "topsoil_thick"))) {
      fs::dir_delete(fs::path(base_tmp, "topsoil_thick"))
    }
  })
  withr::defer({
    if (fs::file_exists(zip_path)) fs::file_delete(zip_path)
  })

  fs::file_create(fs::path(geo_dir, "thpk_1"))
  writeLines(
    "Custodian: CSIRO Land & Water",
    fs::path(geo_dir, "ANZCW1202000149.txt")
  )

  r <- terra::rast(ncols = 2, nrows = 2, xmin = 0, xmax = 2, ymin = 0, ymax = 2)
  terra::values(r) <- as.numeric(1:4)

  retry_mock <- function(url, .f) {
    fs::file_create(.f)
    invisible(.f)
  }

  # Fixed: return the directory containing the files
  unzip_mock <- function(x) {
    return(geo_dir)
  }

  terra_rast_mock <- function(...) r

  # Mock readtext
  readtext_mock <- function(file) {
    list(text = "Custodian: CSIRO Land & Water")
  }

  testthat::with_mocked_bindings(
    {
      testthat::with_mocked_bindings(
        {
          testthat::with_mocked_bindings(
            {
              testthat::with_mocked_bindings(
                {
                  res <- .get_topsoil_thickness(.x = NULL)
                  testthat::expect_s3_class(
                    res,
                    "read.abares.topsoil.thickness"
                  )
                  testthat::expect_s4_class(res$data, "SpatRaster")
                  testthat::expect_match(
                    res$metadata,
                    "Custodian",
                    fixed = TRUE
                  )
                },
                .package = "readtext",
                readtext = readtext_mock
              )
            },
            .unzip_file = unzip_mock
          )
        },
        .package = "terra",
        rast = terra_rast_mock
      )
    },
    .retry_download = retry_mock
  )
})

testthat::test_that("print_topsoil_thickness_metadata snapshot", {
  testthat::skip_on_cran()

  # Make snapshot output stable across environments
  testthat::local_reproducible_output(width = 80L)
  withr::local_options(cli.num_colors = 0L)

  # Create expected directory structure
  base_tmp <- tempdir()
  zip_path <- fs::path(base_tmp, "topsoil_thick.zip")
  geo_dir <- fs::path(base_tmp, "topsoil_thick", "staiar9cl__05911a01eg_geo___")

  fs::dir_create(geo_dir)
  withr::defer({
    if (fs::dir_exists(fs::path(base_tmp, "topsoil_thick"))) {
      fs::dir_delete(fs::path(base_tmp, "topsoil_thick"))
    }
    if (fs::file_exists(zip_path)) {
      fs::file_delete(zip_path)
    }
  })

  fs::file_create(fs::path(geo_dir, "thpk_1"))
  writeLines(
    c(
      "Header line",
      "Custodian: CSIRO Land & Water",
      "More metadata..."
    ),
    fs::path(geo_dir, "ANZCW1202000149.txt")
  )

  r <- terra::rast(ncols = 2, nrows = 2, xmin = 0, xmax = 2, ymin = 0, ymax = 2)
  terra::values(r) <- as.numeric(1:4)

  retry_mock <- function(url, .f) {
    fs::file_create(.f)
    invisible(.f)
  }

  unzip_mock <- function(x) {
    return(geo_dir)
  }

  terra_rast_mock <- function(...) r

  readtext_mock <- function(file) {
    list(
      text = paste(
        c(
          "Header line",
          "Custodian: CSIRO Land & Water",
          "More metadata..."
        ),
        collapse = "\n"
      )
    )
  }

  testthat::with_mocked_bindings(
    {
      testthat::with_mocked_bindings(
        {
          testthat::with_mocked_bindings(
            {
              testthat::expect_snapshot({
                print_topsoil_thickness_metadata(NULL)
              })
            },
            .package = "readtext",
            readtext = readtext_mock
          )
        },
        .retry_download = retry_mock,
        .unzip_file = unzip_mock
      )
    },
    .package = "terra",
    rast = terra_rast_mock
  )
})
