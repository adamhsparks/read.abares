#' Read national scale Land Use of Australia GeoTIFFs using terra
#'
#' Download and import national scale Land Use of Australia GeoTIFFs using
#'  \CRANpkg{terra} as a categorical [terra::rast] object.  Data can be cached
#'  on request.
#'
#' @details From the
#' [ABARES website](https://www.agriculture.gov.au/abares/aclump/land-use/land-use-of-australia-2010-11-to-2020-21):
#' \dQuote{The _Land use of Australia 2010–11 to 2020–21_ data package consists
#' of seamless continental rasters that present land use at national scale for
#' 2010–11, 2015–16 and 2020–21 and the associated change between each target
#' period.  Non-agricultural land uses are mapped using 7 thematic layers,
#' derived from existing datasets provided by state and territory jurisdictions
#' and external agencies. These 7 layers are: protected areas, topographic
#' features, land tenure, forest type, catchment scale land use, urban
#' boundaries, and stock routes. The agricultural land uses are based on the
#' Australian Bureau of Statistics’ 2010–11, 2015–16 and 2020–21 agricultural
#' census data; with spatial distributions modelled using Terra Moderate
#' Resolution Imaging Spectroradiometer (\acronym{MODIS}) satellite imagery and
#' training data, assisted by spatial constraint layers for cultivation,
#' horticulture, and irrigation.
#'    Land use is specified according to the Australian Land Use and Management
#' (\acronym{ALUM}) Classification version 8. The same method is applied to all
#' target periods using representative national datasets for each period, where
#' available. All rasters are in GeoTIFF format with geographic coordinates in
#' Geocentric Datum of Australian 1994 (GDA94) and a 0.002197 degree
#' (~250&nbsp;metre) cell size.
#'    The _Land use of Australia 2010–11 to 2020–21_ data package is a product
#' of the Australian Collaborative Land Use and Management Program. This data
#' package replaces the Land use of Australia 2010–11 to 2015–16 data package,
#' with updates to these time periods.}
#'  -- \acronym{ABARES}, 2024-11-28
#'
#' @note
#' The raster will load with the default category for each data set, but you can
#'  specify a different category to use through [terra::activeCat()].  To see
#'  which categories are available, please refer to the metadata for these data.
#'  The PDF can be accessed in your default web browser by using
#'  [view_nlum_metadata_pdf()].
#'
#' @inheritParams read_nlum_stars
#' @inheritParams get_agfd
#' @param ... Additional arguments passed to [terra::rast], for *e.g.*,
#'  `activeCat` if you wished to set the active category when loading any of the
#'  available GeoTIFF files that are encoded with a raster attribute table.
#'
#' @inheritSection get_agfd Caching
#'
#' @references
#' ABARES 2024, Land use of Australia 2010–11 to 2020–21, Australian Bureau of
#' Agricultural and Resource Economics and Sciences, Canberra, November, CC BY
#' 4.0. \doi{10.25814/w175-xh85}
#'
#' @source
#' \url{https://doi.org/10.25814/w175-xh85}
#'
#' @examplesIf interactive()
#'
#' read_nlum_terra(data_set = "Y202021", active_cat = "")
#'
#' nlum_terra
#'
#' plot(nlum_terra)
#'
#' @returns A [terra::rast] object that may be one or many layers depending upon
#'  the requested data set.
#' @family nlum
#' @autoglobal
#' @export
read_nlum_terra <- function(
  data_set = c(
    "Y201011",
    "Y201516",
    "C201021",
    "T201011",
    "T201516",
    "T202021",
    "P201011",
    "P201516",
    "P202021"
  ),
  cache = FALSE,
  ...
) {
  if (missing(cache)) {
    cache <- getOption("read.abares.cache", default = FALSE)
  }

  rlang::arg_match(
    data_set,
    c(
      "Y201011",
      "Y201516",
      "C201021",
      "T201011",
      "T201516",
      "T202021",
      "P201011",
      "P201516",
      "P202021"
    )
  )

  nlum <- .get_nlum(.data_set = data_set, .cache = cache)
  return(terra::rast(nlum[grep("tif$", nlum, ...)]))
}
