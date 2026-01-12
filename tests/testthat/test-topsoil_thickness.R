make_fake_topsoil_zip <- function() {
  # Create base directory for test
  test_dir <- fs::path(fs::path_temp(), "test_topsoil")
  fs::dir_create(test_dir, showWarnings = FALSE, recurse = TRUE)

  # Create the expected subdirectory structure
  subdir <- fs::path(test_dir, "staiar9cl__05911a01eg_geo___")
  fs::dir_create(subdir, showWarnings = FALSE)

  # Create a trivial raster
  r <- terra::rast(nrows = 2, ncols = 2, vals = 1:4)

  # Write it as ESRI Grid into "thpk_1" subdirectory
  grid_dir <- fs::path(subdir, "thpk_1")
  terra::writeRaster(
    r,
    grid_dir,
    overwrite = TRUE,
    filetype = "AAIGrid",
    NAflag = -9999
  )

  # Metadata file alongside the grid
  txt_file <- file.path(subdir, "ANZCW1202000149.txt")
  writeLines("Fake metadata line", txt_file)

  # Create zip file
  zipfile <- fs::path(fs::path_temp(), "test_topsoil.zip")

  # Use utils::zip and change directory to ensure correct structure
  curr_dir <- getwd()
  on.exit(setwd(curr_dir), add = TRUE)
  setwd(test_dir)

  # Zip the subdirectory with recursive flag
  utils::zip(zipfile, files = "staiar9cl__05911a01eg_geo___", flags = "-r9Xq")

  return(zipfile)
}

zipfile <- make_fake_topsoil_zip()

test_that("read_topsoil_thickness_stars returns a stars object with correct dimensions", {
  result <- read_topsoil_thickness_stars(x = zipfile)
  expect_s3_class(result, "stars")
  expect_identical(unname(dim(result)), c(2L, 2L))
})

test_that("read_topsoil_thickness_stars works with NULL x and mocked download", {
  fake_retry_download <- function(url, dest) {
    file.copy(zipfile, dest, overwrite = TRUE)
  }
  with_mocked_bindings(
    result <- read_topsoil_thickness_stars(x = NULL),
    .retry_download = fake_retry_download
  )
  expect_s3_class(result, "stars")
  expect_identical(unname(dim(result)), c(2L, 2L))
})

test_that("read_topsoil_thickness_terra returns a SpatRaster with correct dimensions", {
  result <- read_topsoil_thickness_terra(x = zipfile)
  expect_s4_class(result, "SpatRaster")
  expect_identical(dim(result), c(2, 2, 1))
})

test_that("read_topsoil_thickness_terra works with NULL x and mocked download", {
  fake_retry_download <- function(url, dest) {
    file.copy(zipfile, dest, overwrite = TRUE)
  }
  with_mocked_bindings(
    result <- read_topsoil_thickness_terra(x = NULL),
    .retry_download = fake_retry_download
  )
  expect_s4_class(result, "SpatRaster")
  expect_identical(dim(result), c(2, 2, 1))
})


test_that("print_topsoil_thickness_metadata prints headings and metadata when x is NULL", {
  ns <- asNamespace("read.abares")

  fake_obj <- list(metadata = "Custodian: ABARES\nOther metadata")
  fake_get <- function(.x = NULL) fake_obj

  with_mocked_bindings(
    {
      output <- testthat::capture_messages({
        result <- print_topsoil_thickness_metadata()
        expect_null(result) # invisible(NULL)
      })
      # collapse vector of messages into one string
      output <- paste(output, collapse = "\n")

      expect_match(
        output,
        "Topsoil Thickness for Australian areas of intensive agriculture"
      )
      expect_match(output, "Dataset ANZLIC ID ANZCW1202000149")
      expect_match(output, "Custodian: ABARES")
    },
    .get_topsoil_thickness = fake_get,
    .env = ns
  )
})

test_that("print_topsoil_thickness_metadata works with provided x", {
  ns <- asNamespace("read.abares")

  fake_obj <- list(metadata = "Custodian: ABARES\nExtra notes")
  fake_get <- function(.x = "local.zip") fake_obj

  with_mocked_bindings(
    {
      output <- testthat::capture_messages({
        result <- print_topsoil_thickness_metadata(x = "local.zip")
        expect_null(result)
      })
      output <- paste(output, collapse = "\n")

      expect_match(output, "Custodian: ABARES")
      expect_match(output, "Topsoil Thickness")
    },
    .get_topsoil_thickness = fake_get,
    .env = ns
  )
})

test_that("print_topsoil_thickness_metadata handles metadata without Custodian gracefully", {
  ns <- asNamespace("read.abares")

  fake_obj <- list(metadata = "No custodian info here")
  fake_get <- function(.x = NULL) fake_obj

  with_mocked_bindings(
    {
      output <- testthat::capture_messages({
        result <- print_topsoil_thickness_metadata()
        expect_null(result)
      })
      output <- paste(output, collapse = "\n")

      # Should still print headings even if Custodian not found
      expect_match(output, "Topsoil Thickness")
      expect_match(output, "Dataset ANZLIC ID ANZCW1202000149")
    },
    .get_topsoil_thickness = fake_get,
    .env = ns
  )
})
