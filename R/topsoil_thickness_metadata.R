#' Prints the text file Metadata for ABARES' Topsoil Thickness for "Australian Areas of Intensive Agriculture of Layer 1"
#'
#' Prints the complete set of metadata associated with the soil thickness
#'  data in your \R console. For including the metadata in documents or other
#'  methods outside of \R, see `.get_topsoil_thickness()` for an example using
#'  [pander::pander()] to print the metadata.
#'
#' @param x An optional file path to a zip file containing the topsoil thickness
#'  data from \acronym{ABARES}.  If left as `NULL`, the default value, a copy
#'  will be downloaded from the \acronym{ABARES} website.
#'
#' @note
#' The original metadata use a title of "Soil Thickness", in the context of this
#' package, we refer to it as "Topsoil Thickness" to be consistent with the
#' actual values in the data.
#'
#' @references
#' <https://data.agriculture.gov.au/geonetwork/srv/eng/catalog.search#/metadata/faa9f157-8e17-4b23-b6a7-37eb7920ead6.
#' @source
#' <https://anrdl-integration-web-catalog-saxfirxkxt.s3-ap-southeast-2.amazonaws.com/warehouse/staiar9cl__059/staiar9cl__05911a01eg_geo___.zip>
#'
#' @returns Nothing, called for its side effects, it prints the complete
#'   metadata file to the \R console.
#'
#' @examplesIf interactive()
#' print_topsoil_thickness_metadata()
#'
#' @family topsoil thickness
#'
#' @export
topsoil_thickness_metadata <- function(x = NULL) {
  x <- .get_topsoil_thickness(.x = x)
  loc <- stringr::str_locate(
    x$metadata,
    stringr::fixed("Custodian", ignore_case = FALSE)
  )
  metadata <- stringr::str_sub(
    x$metadata,
    loc[, "start"] - 1L,
    nchar(x$metadata)
  )
  cli::cli_h1(
    "Topsoil Thickness for Australian areas of intensive agriculture of Layer 1 (A Horizon - top-soil)\n"
  )
  cli::cli_h2("Dataset ANZLIC ID ANZCW1202000149")
  cli::cli_text(metadata)
  cli::cat_line()
  return(invisible(NULL))
}
