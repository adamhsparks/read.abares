#' Read ABARES' Catchment Scale "Land Use of Australia" Data Using Stars
#'
#' Download and import catchment scale "Land Use of Australia" GeoTIFFs as a
#'  \CRANpkg{stars} object.
#'
#' @details From the
#' [ABARES documentation](https://www.agriculture.gov.au/sites/default/files/documents/CLUM_DescriptiveMetadata_December2023_v2.pdf)
#' "The Catchment Scale Land Use of Australia – Update December 2023
#' version 2 dataset is the national compilation of catchment scale land use
#' data available for Australia (CLUM), as at December 2023. It replaces the
#' Catchment Scale Land Use of Australia – Update December 2020. It is a
#' seamless raster dataset that combines land use data for all state and
#' territory jurisdictions, compiled at a resolution of 50 metres by 50 metres.
#' The CLUM data shows a single dominant land use for a given area, based on the
#' primary management objective of the land manager (as identified by state and
#' territory agencies). Land use is classified according to the Australian Land
#' Use and Management Classification version 8. It has been compiled from vector
#' land use datasets collected as part of state and territory mapping programs
#' and other authoritative sources, through the Australian Collaborative Land
#' Use and Management Program. Catchment scale land use data was produced by
#' combining land tenure and other types of land use information including,
#' fine-scale satellite data, ancillary datasets, and information collected in
#' the field. The date of mapping (2008 to 2023) and scale of mapping (1:5,000
#' to 1:250,000) vary, reflecting the source data, capture date and scale.
#' Date and scale of mapping are provided in supporting datasets."
#'  -- \acronym{ABARES}, 2024-06-27
#' @note
#' The raster will load with the default category for each data set, but you can
#'  specify a different category to use by passing the `RAT` argument through
#'  the `...`.  To see which categories are available, please refer
#'  to the metadata for these data.  The \acronym{PDF} can be accessed in your
#'  default \acronym{PDF} viewer by using [view_nlum_metadata_pdf()].
#'
#' @param data_set A string value indicating the data desired for download. One
#' of:
#' \describe{
#'  \item{clum_50m_2023_v2}{Catchment Scale Land Use of Australia – Update December 2023 version 2}
#'  \item{scale_date_update}{Catchment Scale Land Use of Australia - Date and Scale of Mapping}
#' }.
#' @inheritParams read_agfd_dt
#' @inheritParams @read_aagis_regions
#' @param ... Additional arguments passed to [stars::read_stars()], for *e.g.*,
#'  `RAT` if you wish to set the active category when loading any of the
#'  available GeoTIFF files that are encoded with a raster attribute table.
#'
#' @references
#' ABARES 2024, Catchment Scale Land Use of Australia – Update December 2023
#'  version 2, Australian Bureau of Agricultural and Resource Economics and
#'  Sciences, Canberra, June, CC BY 4.0, DOI: \doi{10.25814/2w2p-ph98}
#'
#' @source
#' \doi{10.25814/2w2p-ph98}
#'
#' @examplesIf interactive()
#'
#' clum_stars <- read_clum_stars(data_set = "clum_50m_2023_v2")
#'
#' clum_stars
#'
#' plot(clum_stars)
#'
#' @returns a \CRANpkg{stars} object that may be one or many layers depending
#'  upon the requested data set.
#' @family clum
#' @autoglobal
#' @export

read_clum_stars <- function(
  data_set = "clum_50m_2023_v2",
  x = NULL,
  ...
) {
  if (length(data_set) != 1L || !is.character(data_set) || is.na(data_set)) {
    cli::cli_abort("{.var data_set} must be a single character string value.")
  }
  data_set <- rlang::arg_match0(
    data_set,
    c("clum_50m_2023_v2", "scale_date_update")
  )

  x <- .get_clum(
    .data_set = data_set,
    .x = x
  )

  return(stars::read_stars(x, ...))
}
