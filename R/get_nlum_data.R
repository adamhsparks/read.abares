#' Get ABARES' National Scale "Land Use of Australia" Data
#'
#' Internal helper used by read_nlum_terra()/read_nlum_stars().
#' Downloads the requested NLUM GeoTIFF ZIP (if needed), unzips into
#' a deterministic folder, and returns the list of extracted files.
#'
#' @param .data_set One of: Y201011, Y201516, Y202021, C201121, T201011,
#'  T201516, T202021, P201011, P201516, P202021.
#' @param .x Optional path to a local ZIP to use instead of downloading.
#' @returns A `read.abares.agfd.nlum.files` vector of file paths.
#' @references
#'  - Product page & downloads: https://www.agriculture.gov.au/abares/aclump/land-use/land-use-of-australia-2010-11-to-2020-21
#'  - Metadata with canonical names: https://www.agriculture.gov.au/sites/default/files/documents/NLUM_v7_DescriptiveMetadata_20241128_0.pdf
#' @autoglobal
#' @dev
.get_nlum <- function(.data_set, .x = NULL) {
  # ---- normalise dataset code (alias) ----
  code <- toupper(.data_set)

  # ---- compose canonical filename stem (see metadata/product page) ----
  ds <- switch(
    code,
    "Y202021" = "NLUM_v7_250m_ALUMV8_2020_21_alb",
    "Y201516" = "NLUM_v7_250m_ALUMV8_2015_16_alb",
    "Y201011" = "NLUM_v7_250m_ALUMV8_2010_11_alb",
    "C201121" = "NLUM_v7_250_CHANGE_SIMP_2011_to_2021_alb",
    "T202021" = "NLUM_v7_250m_INPUTS_2020_21_geo",
    "T201516" = "NLUM_v7_250m_INPUTS_2015_16_geo",
    "T201011" = "NLUM_v7_250m_INPUTS_2010_11_geo",
    "P202021" = "NLUM_v7_250m_AgProbabilitySurfaces_2020_21_geo",
    "P201516" = "NLUM_v7_250m_AgProbabilitySurfaces_2015_16_geo",
    "P201011" = "NLUM_v7_250m_AgProbabilitySurfaces_2010_11_geo",
    cli::cli_abort("Unknown {.arg .data_set} code: {.val {code}}")
  )

  # ---- decide ZIP path & extracted folder path ----
  if (is.null(.x)) {
    .x <- fs::path(tempdir(), sprintf("%s.zip", ds))
  } else if (!fs::file_exists(.x)) {
    cli::cli_abort("Provided ZIP {.path {.x}} does not exist.")
  }
  target_dir <- fs::path_ext_remove(.x) # unzip_file writes here

  # ---- download if needed (then unzip) ----
  if (!fs::dir_exists(target_dir)) {
    if (!fs::file_exists(.x)) {
      file_url <- sprintf(
        "https://www.agriculture.gov.au/sites/default/files/documents/%s.zip",
        ds
      )
      .retry_download(url = file_url, .f = .x)
    }
    .unzip_file(.x)
  }

  if (!fs::dir_exists(target_dir)) {
    cli::cli_abort(
      "Expected extracted folder {.path {target_dir}} not found after unzip."
    )
  }

  files <- fs::dir_ls(target_dir, recurse = FALSE)
}
