test_that("read_soil_thickness_stars returns a stars object", {
  x <- get_soil_thickness(cache = TRUE) |>
    read_soil_thickness_stars()
  expect_s3_class(x, "stars")
  expect_named(x, "thpk_1")
})
