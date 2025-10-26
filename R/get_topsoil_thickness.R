#' Get ABARES' Topsoil Thickness for "Australian Areas of Intensive Agriculture of Layer 1"
#'
#' Fetches topsoil thickness data and associated metadata from \acronym{ABARES}.
#'
#' A custom `print()` method is provided that will print the metadata associated
#'  with these data. Examples are provided for interacting with the metadata
#'  directly.
#'
#' @examples
#' x <- .get_topsoil_thickness()
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
#' @references
#' <https://data.agriculture.gov.au/geonetwork/srv/eng/catalog.search#/metadata/faa9f157-8e17-4b23-b6a7-37eb7920ead6>.
#' @source
#' <https://anrdl-integration-web-catalog-saxfirxkxt.s3-ap-southeast-2.amazonaws.com/warehouse/staiar9cl__059/staiar9cl__05911a01eg_geo___.zip>.
#'
#' @dev
.get_topsoil_thickness <- function() {
  .zip <- fs::path(tempdir(), "staiar9cl__05911a01eg_geo____.zip")
  .meta <- "staiar9cl__05911a01eg_geo____/ANZCW1202000149.txt"
  .raster <- "staiar9cl__05911a01eg_geo____/thpk_1"

  if (!fs::file_exists(.zip)) {
    .retry_download(
      "https://anrdl-integration-web-catalog-saxfirxkxt.s3-ap-southeast-2.amazonaws.com/warehouse/staiar9cl__059/staiar9cl__05911a01eg_geo____.zip",
      dest = .zip
    )
  }

  con <- unz(.zip, .meta)
  on.exit(close(con), add = TRUE)
  metadata <- paste(readLines(con), collapse = "\n")

  x <- terra::rast(paste0("/vsizip//", .zip, "/", .raster))
  x <- terra::init(x, x[]) # remove RAT legend if present

  out <- list(metadata = metadata, data = x)
  class(out) <- union("read.abares.topsoil.thickness", class(out))
  out
}
