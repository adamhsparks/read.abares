#' Displays the PDF metadata for the National Land Use raster files in a native viewer
#'
#' Each National Land Use raster file comes with a PDF of metadata. This
#'  function will open and display that file using the native PDF viewer for any
#'  system.
#' @examplesIf interactive()
#' view_nlum_metadata_pdf()
#' @returns Called for its side-effects, opens the system's native PDF viewer to
#'  display the requested metadata file.
#' @export
#' @autoglobal

view_nlum_metadata_pdf <- function() {
  nlum_metadata_pdf_path <- fs::path(
    .find_user_cache(),
    "nlum",
    "NLUM_v7_DescriptiveMetadata_20241128_0.pdf"
  )
  system(paste0('open "', nlum_metadata_pdf_path, '"'))
}
