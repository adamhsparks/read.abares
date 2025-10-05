#' Displays PDF Metadata for ABARES' "National Land Use" (NLUM) Raster Files in a Native Viewer
#'
#' Each National Land Use (\acronym{NLUM}) raster file comes with a
#'  \acronym{PDF} of metadata. This function will open and display that file
#'  using the native \acronym{PDF} viewer for any system with a graphical user
#'  interface and \acronym{PDF} viewer configured.  If the file does not exist
#'  locally, it will be fetched and displayed.
#'
#' @examplesIf interactive()
#' view_nlum_metadata_pdf()
#'
#' @returns An invisible `NULL`. Called for its side-effects, opens the system's
#'  native \acronym{PDF} viewer to display the requested metadata \acronym{PDF}
#'  document.
#'
#' @family nlum
#' @export
#' @autoglobal

view_nlum_metadata_pdf <- function() {
  if (rlang::is_interactive()) {
    .x <- fs::path(tempdir(), "nlum_metadata.pdf")
    .retry_download(
      url = "https://www.agriculture.gov.au/sites/default/files/documents/NLUM_v7_DescriptiveMetadata_20241128_0.pdf",
      dest = .x,
      dataset_id = "nlum_metadata",
      show_progress = TRUE
    )
  }
  return(invisible(NULL))
}
