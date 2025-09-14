#' Displays the PDF Metadata for ABARES' "Catchment Land Use" (CLUM) Raster Files in a Native Viewer
#'
#' Each "Catchment Land Use" (\acronym{CLUM}) raster file comes with a
#'  \acronym{PDF} of metadata. This function will open and display that file
#'  using the native \acronym{PDF} viewer for any system with a graphical user
#'  interface and \acronym{PDF} viewer configured.  If the file does not exist
#'  locally, it will be fetched and displayed.
#'
#' @param commodities A `Boolean` value that indicates whether to download the
#'  catchment land scale use metadata for commodities. Defaults to `FALSE`,
#'  downloading the "Catchment Land Scale Use Metadata".
#'
#' @source
#' \describe{
#'  \item{CLUM Metadata}{https://www.agriculture.gov.au/sites/default/files/documents/CLUM_DescriptiveMetadata_December2023_v2.pdf}
#'  \item{CLUM Commodities Metadata}{https://www.agriculture.gov.au/sites/default/files/documents/CLUMC_DescriptiveMetadata_December2023.pdf}
#' }
#'
#' @examplesIf interactive()
#' view_clum_metadata_pdf()
#'
#' @returns An invisible `NULL`. Called for its side-effects, opens the system's
#'  native \acronym{PDF} viewer to display the requested metadata \acronym{PDF}
#'  document.
#'
#' @family nlum
#' @export
#' @autoglobal

view_clum_metadata_pdf <- function(commodities = FALSE) {
  if (rlang::is_interactive()) {
    clum_metadata_pdf <- fs::path(tempdir(), "clum_metadata.pdf")
    .retry_download(
      url = "https://www.agriculture.gov.au/sites/default/files/documents/CLUM_DescriptiveMetadata_December2023_v2.pdf",
      .f = clum_metadata_pdf
    )
    system(paste0('open "', clum_metadata_pdf, '"'))
  } else {
    clumc_metadata_pdf <- fs::path(tempdir(), "clumc_metadata.pdf")
    .retry_download(
      url = "https://www.agriculture.gov.au/sites/default/files/documents/CLUMC_DescriptiveMetadata_December2023.pdf",
      .f = clumc_metadata_pdf
    )
    system(paste0('open "', clumc_metadata_pdf, '"'))
  }
  return(invisible(NULL))
}
