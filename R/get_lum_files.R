#' Unified CLUM and NLUM Checks and Downloading Automation
#'
#' Checks user inputs for CLUM and NLUM functions and validates inputs. If
#'  no file is provided, downloads the data set. If `x` is provided, checks that
#'  the file exists and has the proper files in it. Calls the respective CLUM or
#'  NLUM download function.
#'
#' @param data_set A user provided string value.
#' @param data_set A user provided string value.
#' @param lum A string value indicating whether to process 'clum' or 'nlum'
#'  data.
#'
#' @examples
#' # for NLUM data download
#' .get_lum_files(x = NULL, data_set = "Y202021", lum = "nlum")
#'
#' # for CLUM data download
#' .get_lum_files(x = NULL, data_set = "clum_50m_2023_v2", lum = "clum")
#'
#' @returns A list object containing the path to the zip file and the filename
#'  of the GeoTIFF contained in the zip file.
#' @dev
#'

.get_lum_files <- function(x, data_set, lum) {
  # Ensure only one of x or data_set is provided
  if (!xor(is.null(x), is.null(data_set))) {
    cli::cli_abort("You must provide only either `x` or `data_set`.")
  }

  # Case 1: data_set provided, download file
  if (is.null(x)) {
    if (!is.character(data_set) || is.na(data_set)) {
      cli::cli_abort(
        "{.var data_set} must be a single non-missing character string."
      )
    }
    x <- switch(
      lum,
      nlum = .get_nlum(.data_set = data_set),
      clum = .get_clum(.data_set = data_set)
    )
  }

  # Case 2: x provided, local file
  if (!fs::file_exists(x)) {
    cli::cli_abort("The provided file path {.var x} does not exist.")
  }

  # Validate zip contents via helper
  tiff <- .check_zip_has_tiff(x)

  return(list(tiff = tiff, file_path = x))
}

# Helper: validate that a zip contains .tif files
.check_zip_has_tiff <- function(zipfile) {
  if (!fs::file_exists(zipfile)) {
    cli::cli_abort("The provided file path {.var zipfile} does not exist.")
  }
  zip_list <- utils::unzip(zipfile, list = TRUE)$Name
  tiff <- grep("\\.tif$", zip_list, value = TRUE)
  if (length(tiff) == 0L) {
    cli::cli_abort(
      "The provided .zip file does not appear to contain any .tif files."
    )
  }
  return(tiff)
}
