
test_that("read_soil_thickness_stars returns a terra object", {
  skip_if_offline()
  skip_on_ci()
  x <- get_soil_thickness(cache = TRUE) |>
    read_soil_thickness_terra()
  expect_s4_class(x, "SpatRaster")
  expect_named(x, "thpk_1")
})
