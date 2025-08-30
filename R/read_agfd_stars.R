#' Read ABARES' "Australian Gridded Farm Data" (AGFD) NCDF files with stars
#'
#' Read "Australian Gridded Farm Data" (\acronym{AGFD}) as a list of
#'  \CRANpkg{stars} objects.
#'
#' @inherit read_agfd_dt details
#' @inheritParams read_agfd_dt
#' @inheritParams read_aagis_regions
#' @inheritSection read_agfd_dt Model scenarios
#' @inheritSection read_agfd_dt Data files
#' @inheritSection read_agfd_dt Data layers
#' @inherit read_agfd_dt references
#'
#' @returns A `list` object of \CRANpkg{stars} objects of the "Australian
#' Gridded Farm Data" with the file names as the list's  objects' names.
#'
#' @examplesIf interactive()
#'
#' agfd_stars <- read_agfd_stars()
#'
#' head(agfd_stars)
#'
#' plot(agfd_stars[[1]])
#'
#' @family AGFD
#' @autoglobal
#' @export

read_agfd_stars <- function(
  fixed_prices = TRUE,
  yyyy = 1991:2003,
  x = NULL
) {
  if (any(yyyy %notin% 1991:2023)) {
    cli::cli_abort(
      "{.arg yyyy} must be between 1991 and 2023 inclusive"
    )
  }
  files <- .get_agfd(
    .fixed_prices = fixed_prices,
    .yyyy = yyyy,
    .x = x
  )
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
  s2 <- NULL
  # read one file for the message
  s1 <- list(stars::read_ncdf(
    files[1L],
    var = var
  ))

  if (length(files) > 1L) {
    # then suppress the rest of the messages
    q_read_ncdf <- purrr::quietly(stars::read_ncdf)
    s2 <- purrr::modify_depth(
      purrr::map(files[2L:length(files)], q_read_ncdf, var = var),
      1L,
      "result"
    )

    s1 <- append(s1, s2)
  }

  names(s1) <- fs::path_file(files)

  if (!is.null(s2)) {
    rm(s2)
  }
  gc()
  return(s1)
}
