#' Get ABARES' Catchment Scale "Land Use of Australia" Data
#'
#' An internal function used by [read_clum_terra()] and [read_clum_stars()] that
#'  downloads catchment level land use data files.
#'
#' @param .data_set A string value indicating the data desired for download.
#' One of:
#' \describe{
#'  \item{clum_50m_2023_v2}{Catchment Scale Land Use of Australia – Update December 2023 version 2}
#'  \item{scale_date_update}{Catchment Scale Land Use of Australia - Date and Scale of Mapping}
#' }.
#' @param .x A user specified path to a local zip file containing the data.
#'
#' @references
#' ABARES 2024, Catchment Scale Land Use of Australia – Update December 2023
#' version 2, Australian Bureau of Agricultural and Resource Economics and
#' Sciences, Canberra, June, CC BY 4.0, DOI: \doi{10.25814/2w2p-ph98}.
#'
#' @source
#' * Land Use: \doi{10.25814/2w2p-ph98},
#' * Commodities: \doi{10.25814/zfjz-jt75}.
#'
#' @examples
#' clum_update <- .get_clum(.data_set = "scale_date_update", .x = NULL)
#'
#' clum_update
#'
#' @returns A list of files containing a spatial data file of or files related
#' to Australian catchment scale land use data.
#'
#' @autoglobal
#' @dev

.get_clum <- function(.data_set, .x) {
  if (is.null(.x)) {
    .x <- fs::path(tempdir(), sprintf("%s.zip", .data_set))

    if (!fs::file_exists(.x)) {
      file_url <-
        "https://data.gov.au/data/dataset/8af26be3-da5d-4255-b554-f615e950e46d/resource/"

      file_url <- switch(
        .data_set,
        "clum_50m_2023_v2" = sprintf(
          "%s6deab695-3661-4135-abf7-19f25806cfd7/download/clum_50m_2023_v2.zip",
          file_url
        ),
        "scale_date_update" = sprintf(
          "%s98b1b93f-e5e1-4cc9-90bf-29641cfc4f11/download/scale_date_update.zip",
          file_url
        )
      )

      .retry_download(
        url = file_url,
        dest = .x
      )
      .unzip_file(.x)
    }
  } else if (!is.null(.x)) {
    ds <- fs::path_file(fs::path_ext_remove(.x))
    .unzip_file(.x)
  }

  return(fs::dir_ls(
    fs::path(fs::path_dir(.x), .data_set),
    recurse = TRUE,
    glob = "*.tif"
  ))
}
