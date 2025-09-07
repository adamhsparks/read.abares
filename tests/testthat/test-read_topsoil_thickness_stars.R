test_that("soil_thickness: happy path (mock .get_topsoil_thickness)", {
  fake_stars <- structure(list(dummy = TRUE), class = "stars")
  out <- NULL
  with_mocked_bindings(
    {
      out <<- read_topsoil_thickness_stars(files = "ignored.zip")
    },
    .get_topsoil_thickness = function(.x) fake_stars,
    .package = "read.abares"
  )
  expect_s3_class(out, "stars")
})

test_that("soil_thickness: error path (mocked failure from .get_topsoil_thickness)", {
  with_mocked_bindings(
    {
      expect_error(
        read_topsoil_thickness_stars(files = "ignored.zip"),
        regexp = "issue|download|zip|retry|unzip",
        ignore.case = TRUE
      )
    },
    .get_topsoil_thickness = function(.x) stop("mocked failure"),
    .package = "read.abares"
  )
})
