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
  code <- toupper(.data_set)

  # Candidate stems for each dataset code.
  # First item(s) prefer the "live package" forms when known;
  # later items fall back to canonical names from the metadata.
  pkg_date <- "20241128" # release build date present on the DAFF page for v7
  stems <- switch(
    code,
    "Y202021" = c(
      sprintf("NLUM_v7_250m_ALUMV8_2020_21_alb_package_%s", pkg_date),
      "NLUM_v7_250m_ALUMV8_2020_21_alb"
    ),
    "Y201516" = c(
      sprintf("NLUM_v7_250m_ALUMV8_2015_16_alb_package_%s", pkg_date),
      "NLUM_v7_250m_ALUMV8_2015_16_alb"
    ),
    "Y201011" = c(
      sprintf("NLUM_v7_250m_ALUMV8_2010_11_alb_package_%s", pkg_date),
      "NLUM_v7_250m_ALUMV8_2010_11_alb"
    ),
    # Change product: DAFF page uses 250 + CHANGE_SIMP + _package_YYYYMMDD
    "C201121" = c(
      sprintf("NLUM_v7_250_CHANGE_SIMP_2011_to_2021_alb_package_%s", pkg_date),
      "NLUM_v7_250m_SIMP_CHANGE_2011_to_2021_alb" # canonical
    ),
    # Thematic inputs and probability grids are provided in Geographic
    "T202021" = c(
      sprintf("NLUM_v7_250m_INPUTS_2020_21_geo_package_%s", pkg_date),
      "NLUM_v7_250m_INPUTS_2020_21_geo"
    ),
    "T201516" = c(
      sprintf("NLUM_v7_250m_INPUTS_2015_16_geo_package_%s", pkg_date),
      "NLUM_v7_250m_INPUTS_2015_16_geo"
    ),
    "T201011" = c(
      sprintf("NLUM_v7_250m_INPUTS_2010_11_geo_package_%s", pkg_date),
      "NLUM_v7_250m_INPUTS_2010_11_geo"
    ),
    "P202021" = c(
      sprintf(
        "NLUM_v7_250m_AgProbabilitySurfaces_2020_21_geo_package_%s",
        pkg_date
      ),
      "NLUM_v7_250m_AgProbabilitySurfaces_2020_21_geo"
    ),
    "P201516" = c(
      sprintf(
        "NLUM_v7_250m_AgProbabilitySurfaces_2015_16_geo_package_%s",
        pkg_date
      ),
      "NLUM_v7_250m_AgProbabilitySurfaces_2015_16_geo"
    ),
    "P201011" = c(
      sprintf(
        "NLUM_v7_250m_AgProbabilitySurfaces_2010_11_geo_package_%s",
        pkg_date
      ),
      "NLUM_v7_250m_AgProbabilitySurfaces_2010_11_geo"
    ),
    cli::cli_abort("Unknown {.arg .data_set} code: {.val {code}}")
  )

  # If a local ZIP is supplied, use that (and its derived extraction folder).
  if (!is.null(.x)) {
    if (!fs::file_exists(.x)) {
      cli::cli_abort("Provided ZIP {.path {.x}} does not exist.")
    }
    target_dir <- fs::path_ext_remove(.x)
    if (!fs::dir_exists(target_dir)) {
      .unzip_file(.x)
    }
    files <- fs::dir_ls(target_dir, recurse = FALSE)
    return(structure(
      files,
      class = c("read.abares.agfd.nlum.files", class(files))
    ))
  }

  # Otherwise, try candidates in order until one succeeds.
  attempted_urls <- character(0L)
  success_zip <- NULL
  success_dir <- NULL

  for (stem in stems) {
    zip_path <- fs::path(tempdir(), sprintf("%s.zip", stem))
    dest_dir <- fs::path_ext_remove(zip_path)
    file_url <- sprintf(
      "https://www.agriculture.gov.au/sites/default/files/documents/%s.zip",
      stem
    )
    attempted_urls <- c(attempted_urls, file_url)

    # Fast path: already extracted.
    if (fs::dir_exists(dest_dir)) {
      success_zip <- zip_path
      success_dir <- dest_dir
      break
    }

    # If ZIP exists but not extracted yet, unzip it.
    if (fs::file_exists(zip_path)) {
      .unzip_file(zip_path)
      success_zip <- zip_path
      success_dir <- dest_dir
      break
    }

    # Try to download this candidate; on failure, continue to next.
    ok <- tryCatch(
      {
        .retry_download(url = file_url, .f = zip_path)
        TRUE
      },
      error = function(e) FALSE
    )

    if (isTRUE(ok)) {
      .unzip_file(zip_path)
      success_zip <- zip_path
      success_dir <- dest_dir
      break
    }
  }

  if (is.null(success_zip)) {
    # Produce a helpful error listing what was tried.
    msg <- c(
      "Tried the following URLs:",
      paste0(" • ", attempted_urls, collapse = "\n")
    )
    cli::cli_abort(
      c(
        x = "All candidate downloads failed for {.val {code}}",
        i = "{attempted_urls}"
      )
    )
  }

  files <- fs::dir_ls(success_dir, recurse = FALSE)
  structure(files, class = c("read.abares.agfd.nlum.files", class(files)))
}
