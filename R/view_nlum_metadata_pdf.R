#' Displays the PDF metadata for the National Land Use (NLUM) raster files in a native viewer
#'
#' Each National Land Use (NLUM) raster file comes with a PDF of metadata. This
#'  function will open and display that file using the native PDF viewer for any
#'  system with a graphical user interface and PDF viewer configured.  If the
#'  file does not exist locally, it will be fetched and displayed.
#'
#' @examplesIf interactive()
#' view_nlum_metadata_pdf()
#'
#' @returns Called for its side-effects, opens the system's native PDF viewer to
#'  display the requested metadata PDF document.
#'
#' @family nlum
#' @export
#' @autoglobal

view_nlum_metadata_pdf <- function() {
  nlum_metadata_pdf <- fs::path(
    .find_user_cache(),
    "nlum",
    "NLUM_v7_DescriptiveMetadata_20241128_0.pdf"
  )

  if (fs::file_exists(nlum_metadata_pdf)) {
    system(paste0('open "', nlum_metadata_pdf, '"'))
  } else {
    cli::cli_inform("Downloading NLUM metadata PDF...")
    .retry_download(
      url = "https://www.agriculture.gov.au/sites/default/files/documents/NLUM_v7_DescriptiveMetadata_20241128_0.pdf",
      .f = tempfile()
    )
  }
}
