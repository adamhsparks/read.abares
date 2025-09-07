skip_if_not("read_topsoil_thickness_stars" %in% ls(getNamespace("read.abares")))
testthat::skip_if_not_installed("stars")

test_that("soil_thickness: happy path with stars::read_stars mocked", {
  # The function expects a special class on `files`; emulate it
  files <- c("a.tif", "b.tif")
  class(files) <- c("read.abares.soil.thickness.files", class(files))

  # Return a tiny stars object (no disk I/O)
  testthat::local_mocked_bindings(
    read_stars = function(...) build_dummy_stars(),
    .package = "stars"
  )

  out <- read_topsoil_thickness_stars(files)
  expect_true(inherits(out, "stars"))
})

test_that("soil_thickness: wrong class for files errors cleanly", {
  # no special class => should error
  bad <- c("a.tif", "b.tif")
  expect_error(read_topsoil_thickness_stars(bad))
})
