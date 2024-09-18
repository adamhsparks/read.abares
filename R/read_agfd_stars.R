
#' Read AGFD NCDF Files
#'
#' Read Australian Gridded Farm Data, (\acronym{AGFD}) as a [stars] object.
#'
#' @param files A list of NetCDF files to import
#'
#' @return a `list` object of \CRANpkg{stars} objects of the Australian Gridded
#'  Farm Data with the file names as the list's objects' names
#'
#' @examplesIf interactive()
#' get_agfd(cache = TRUE) |>
#'   read_agfd_stars()
#'
#' @family read_agfd
#' @autoglobal |>
#' @export

read_agfd_stars <- function(files) {

  var <- c(
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
    "farmland_per_cell"
  )

  # read one file for the message
  s1 <- list(stars::read_ncdf(
    files[1],
    var = var
  ))

  # then suppress the rest of the messages
  q_read_ncdf <- purrr::quietly(stars::read_ncdf)
  s2 <- purrr::modify_depth(
    purrr::map(files[2:length(files)], q_read_ncdf, var = var),
    1, "result")

  out <- append(s1, s2)

  names(out) <-  basename(files)

  rm(s1, s2)
  gc()
  return(out)
}
