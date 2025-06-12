#' Displays the PDF metadata for the Catchment Land Use (CLUM) raster files in a native viewer
#'
#' Each Catchment Land Use (CLUM) raster file comes with a PDF of metadata. This
#'  function will open and display that file using the native PDF viewer for any
#'  system with a graphical user interface and PDF viewer configured.  If the
#'  file does not exist locally, it will be fetched and displayed.
#'
#' @param Commodities A `Boolean` value that indicates whether to download the
#'  catchment land scale use metadata for commodities. Defaults to `FALSE`,
#'  downloading the Catchment Land Scale Use Metadata.
#'
#' @examplesIf interactive()
#' view_clum_metadata_pdf()
#'
#' @returns Called for its side-effects, opens the system's native PDF viewer to
#'  display the requested metadata PDF document.
#'
#' @family nlum
#' @export
#' @autoglobal

view_clum_metadata_pdf <- function(commodities = FALSE) {
  if (isFALSE(commodities)) {
    clum_metadata_pdf <- fs::path(
      .find_user_cache(),
      "clum",
      "CLUM_DescriptiveMetadata_December2023_v2.pdf"
    )

    if (fs::file_exists(clum_metadata_pdf)) {
      system(paste0('open "', clum_metadata_pdf, '"'))
    } else {
      cli::cli_inform("Downloading CLUM metadata PDF...")
      .retry_download(
        url = "https://www.agriculture.gov.au/sites/default/files/documents/CLUM_DescriptiveMetadata_December2023_v2.pdf",
        .f = tempfile()
      )
    }
  } else {
    clumc_metadata_pdf <- fs::path(
      .find_user_cache(),
      "clumc",
      "CLUMC_DescriptiveMetadata_December2023.pdf"
    )
  }

  if (fs::file_exists(clumc_metadata_pdf)) {
    system(paste0('open "', clumc_metadata_pdf, '"'))
  } else {
    cli::cli_inform("Downloading CLUM Commodities metadata PDF...")
    .retry_download(
      url = "https://www.agriculture.gov.au/sites/default/files/documents/CLUMC_DescriptiveMetadata_December2023.pdf",
      .f = tempfile()
    )
  }
}
