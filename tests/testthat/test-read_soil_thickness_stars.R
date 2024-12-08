test_that("read_soil_thickness_stars returns a stars object", {
  skip_if_offline()
  skip_on_ci()
  x <- get_soil_thickness(cache = TRUE) |>
    read_soil_thickness_stars()
  expect_s3_class(x, "stars")
  expect_named(x, "thpk_1")
})
