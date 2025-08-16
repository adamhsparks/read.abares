#' Read catchment scale \dQuote{Land Use of Australia} GeoTIFFs using terra
#'
#' Download and import catchment scale \dQuote{Land Use of Australia} GeoTIFFs
#'  using \CRANpkg{terra} as a categorical [terra::rast()] object.  Downloaded
#'  data can be cached on request.
#'
#' @details From the
#' [ABARES documentation](https://www.agriculture.gov.au/sites/default/files/documents/CLUM_DescriptiveMetadata_December2023_v2.pdf)
#' \dQuote{The Catchment Scale Land Use of Australia – Update December 2023
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
#' Date and scale of mapping are provided in supporting datasets.}
#'  -- \acronym{ABARES}, 2024-06-27
#'
#' @section Active categories:
#' The catchment scale land use data set is a categorical raster with many
#'  categories.  The raster will load with the default category for each data
#'  set, but you can specify a different category to use through
#'  [terra::activeCat()] after loading.  To see which categories are available,
#'  please refer to the metadata for these data.  The PDF can be accessed in
#'  your default web browser by using [view_clum_metadata_pdf()].
#'
#' @section Map colours:
#' Where \acronym{ABARES} has provided a style guide, it will be applied by
#'  default to the raster object. Not all GeoTiff files have a colour guide
#'  available.
#'
#' @inheritParams read_clum_stars
#' @param ... Additional arguments passed to [terra::rast()], for *e.g.*,
#'  `activeCat` if you wished to set the active category when loading any of the
#'  available GeoTIFF files that are encoded with a raster attribute table.
#'
#' @references
#' ABARES 2024, Catchment Scale Land Use of Australia – Update December 2023
#'  version 2, Australian Bureau of Agricultural and Resource Economics and
#'  Sciences, Canberra, June, CC BY 4.0, DOI: \doi{10.25814/2w2p-ph98}
#'
#' @source
#' \describe{
#'  \item{Catchment Scale Land Use of Australia v2 GeoTiff}{\url{https://www.agriculture.gov.au/sites/default/files/documents/clum_50m_2023_v2.zip}}
#'  \item{Date and Scale of Mapping Shapefile GeoTIFF}{\url{https://data.gov.au/data/dataset/8af26be3-da5d-4255-b554-f615e950e46d/resource/98b1b93f-e5e1-4cc9-90bf-29641cfc4f11/download/scale_date_update.zip}}
#' }
#'
#' @examplesIf interactive()
#'
#' clum_terra <- read_clum_terra(data_set = "clum_50m_2023_v2")
#'
#' clum_terra
#'
#' plot(clum_terra)
#'
#' @returns A [terra::rast()] object that may be one or many layers depending
#'  upon the requested data set.
#' @family clum
#' @autoglobal
#' @export
read_clum_terra <- function(
  data_set = "clum_50m_2023_v2",
  files = NULL,
  ...
) {
  data_set <- rlang::arg_match0(
    data_set,
    c("clum_50m_2023_v2", "scale_date_update")
  )

  if (is.null(files)) {
    files <- .get_clum(
      .data_set = data_set
    )
  }
  r <- terra::rast(files[grep("[.]tif$", files)], ...)
  if (data_set == "clum_50m_2023_v2") {
    terra::coltab(r) <- .create_clum_50m_coltab()
  }
  return(r)
}
