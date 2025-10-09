test_that("print_topsoil_thickness_metadata displays complete metadata", {
  skip_if_offline()
  # Create metadata with Custodian marker
  metadata_content <- paste(
    "Some initial content",
    "Custodian: CSIRO Land & Water",
    "Additional metadata content",
    "More details about the dataset",
    sep = "\n"
  )

  mock_obj <- structure(
    list(
      metadata = metadata_content,
      data = terra::rast(nrows = 2, ncols = 2)
    ),
    class = c("read.abares.topsoil.thickness", "list")
  )

  expect_snapshot({
    print_topsoil_thickness_metadata(mock_obj)
  })
})

test_that("print_topsoil_thickness_metadata returns invisible NULL", {
  skip_if_offline()
  mock_obj <- structure(
    list(
      metadata = "Some content\nCustodian: Test\nMore content",
      data = terra::rast(nrows = 2, ncols = 2)
    ),
    class = c("read.abares.topsoil.thickness", "list")
  )

  returned_obj <- withVisible(print_topsoil_thickness_metadata(mock_obj))
  expect_null(returned_obj$value)
  expect_false(returned_obj$visible)
})
