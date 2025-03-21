test_that("read_agfd_dt returns a data.table object", {
  skip_if_offline()
  skip_on_ci()
  x <- get_agfd() |>
    read_agfd_dt()

  expect_s3_class(x, c("data.table", "data.frame"))
  expect_named(
    x,
    c(
      "id",
      "farmno",
      "R_total_hat_ha",
      "C_total_hat_ha",
      "FBP_fci_hat_ha",
      "FBP_fbp_hat_ha",
      "A_wheat_hat_ha",
      "H_wheat_dot_hat",
      "A_barley_hat_ha",
      "H_barley_dot_hat",
      "A_sorghum_hat_ha",
      "H_sorghum_dot_hat",
      "A_oilseeds_hat_ha",
      "H_oilseeds_dot_hat",
      "R_wheat_hat_ha",
      "R_sorghum_hat_ha",
      "R_oilseeds_hat_ha",
      "R_barley_hat_ha",
      "Q_wheat_hat_ha",
      "Q_barley_hat_ha",
      "Q_sorghum_hat_ha",
      "Q_oilseeds_hat_ha",
      "S_wheat_cl_hat_ha",
      "S_sheep_cl_hat_ha",
      "S_sheep_births_hat_ha",
      "S_sheep_deaths_hat_ha",
      "S_beef_cl_hat_ha",
      "S_beef_births_hat_ha",
      "S_beef_deaths_hat_ha",
      "Q_beef_hat_ha",
      "Q_sheep_hat_ha",
      "Q_lamb_hat_ha",
      "R_beef_hat_ha",
      "R_sheep_hat_ha",
      "R_lamb_hat_ha",
      "C_fodder_hat_ha",
      "C_fert_hat_ha",
      "C_fuel_hat_ha",
      "C_chem_hat_ha",
      "A_total_cropped_ha",
      "FBP_pfe_hat_ha",
      "farmland_per_cell",
      "lon",
      "lat"
    )
  )

  expect_identical(
    lapply(x, typeof),
    list(
      id = "character",
      farmno = "double",
      R_total_hat_ha = "double",
      C_total_hat_ha = "double",
      FBP_fci_hat_ha = "double",
      FBP_fbp_hat_ha = "double",
      A_wheat_hat_ha = "double",
      H_wheat_dot_hat = "double",
      A_barley_hat_ha = "double",
      H_barley_dot_hat = "double",
      A_sorghum_hat_ha = "double",
      H_sorghum_dot_hat = "double",
      A_oilseeds_hat_ha = "double",
      H_oilseeds_dot_hat = "double",
      R_wheat_hat_ha = "double",
      R_sorghum_hat_ha = "double",
      R_oilseeds_hat_ha = "double",
      R_barley_hat_ha = "double",
      Q_wheat_hat_ha = "double",
      Q_barley_hat_ha = "double",
      Q_sorghum_hat_ha = "double",
      Q_oilseeds_hat_ha = "double",
      S_wheat_cl_hat_ha = "double",
      S_sheep_cl_hat_ha = "double",
      S_sheep_births_hat_ha = "double",
      S_sheep_deaths_hat_ha = "double",
      S_beef_cl_hat_ha = "double",
      S_beef_births_hat_ha = "double",
      S_beef_deaths_hat_ha = "double",
      Q_beef_hat_ha = "double",
      Q_sheep_hat_ha = "double",
      Q_lamb_hat_ha = "double",
      R_beef_hat_ha = "double",
      R_sheep_hat_ha = "double",
      R_lamb_hat_ha = "double",
      C_fodder_hat_ha = "double",
      C_fert_hat_ha = "double",
      C_fuel_hat_ha = "double",
      C_chem_hat_ha = "double",
      A_total_cropped_ha = "double",
      FBP_pfe_hat_ha = "double",
      farmland_per_cell = "double",
      lon = "double",
      lat = "double"
    )
  )
})
test_that("read_agfd_dt() fails if the input is not a proper object", {
  expect_error(read_agfd_dt(list(list.files(tempdir()))))
})
