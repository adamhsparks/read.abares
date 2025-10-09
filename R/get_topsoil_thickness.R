#' Get ABARES' Topsoil Thickness for "Australian Areas of Intensive Agriculture of Layer 1"
#'
#' Fetches topsoil thickness data and associated metadata from \acronym{ABARES}.
#'
#' @param .x A character string passed that provides a file path to the
#'  local directory holding the unzipped files for topsoil thickness.
#' @note
#' A custom `print()` method is provided that will print the metadata associated
#'  with these data. Examples are provided for interacting with the metadata
#'  directly.
#'
#' @examples
#' x <- .get_topsoil_thickness(.x = NULL)
#'
#' x
#'
#' # Extract the metadata as an object in your R session and use it with
#' # {pander}, useful for Markdown files
#'
#' library(pander)
#' y <- x$metadata
#' pander(y)
#'
#' @returns A `read.abares.topsoil.thickness` object, which is a named `list()`
#'  with the [terra::rast()] object of the data and text file of metadata.
#'
#' @references <https://data.agriculture.gov.au/geonetwork/srv/eng/catalog.search#/metadata/faa9f157-8e17-4b23-b6a7-37eb7920ead6>
#' @source <https://anrdl-integration-web-catalog-saxfirxkxt.s3-ap-southeast-2.amazonaws.com/warehouse/staiar9cl__059/staiar9cl__05911a01eg_geo___.zip>
#'
#' @dev

.get_topsoil_thickness <- function(.x = NULL) {
  if (is.null(.x)) {
    .x <- fs::path(tempdir(), "staiar9cl__05911a01eg_geo___.zip")
    .retry_download(
      "https://anrdl-integration-web-catalog-saxfirxkxt.s3-ap-southeast-2.amazonaws.com/warehouse/staiar9cl__059/staiar9cl__05911a01eg_geo___.zip",
      dest = .x
    )
  }

  .unzip_file(.x)
  root <- fs::path_dir(.x)

  # Locate metadata file anywhere under root
  md_idx <- fs::dir_ls(
    root,
    recurse = TRUE,
    type = "file",
    regexp = "(^|/)ANZCW1202000149\\.txt$"
  )
  metadata <- readtext::readtext(md_idx[[1L]])

  # Locate raster file; accept thpk_1 or thpk_1.tif
  ras_candidates <- fs::dir_ls(
    root,
    recurse = TRUE,
    type = "file",
    regexp = "(^|/)thpk_1"
  )
  rast_path <- ras_candidates[[1L]]

  x <- terra::rast(rast_path)
  x <- terra::init(x, x[]) # remove RAT legend if present

  out <- list(metadata = metadata$text, data = x)
  class(out) <- union("read.abares.topsoil.thickness", class(out))
  return(out)
}
