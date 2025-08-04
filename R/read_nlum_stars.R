#' Read national scale \dQuote{Land Use of Australia} data using stars
#'
#' Download and import national scale \dQuote{Land Use of Australia v7} GeoTIFFs
#'  as a \CRANpkg{stars} object.  Downloaded data can be cached on request.
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
#'  specify a different category to use by passing the `RAT` argument through
#'  the `...`.  To see which categories are available, please refer
#'  to the metadata for these data.  The \acronym{PDF} can be accessed in your
#'  default \acronym{PDF} viewer by using [view_nlum_metadata_pdf()].
#'
#' @param data_set A string value indicating the GeoTIFF desired for download.
#' One of:
#' \describe{
#'  \item{Y201011}{Land use of Australia 2010–11}
#'  \item{Y201516}{Land use of Australia 2015–16}
#'  \item{Y202021}{Land use of Australia 2020–21}
#'  \item{C201121}{Land use of Australia change}
#'  \item{T201011}{Land use of Australia 2010–11 thematic layers}
#'  \item{T201516}{Land use of Australia 2015–16 thematic layers}
#'  \item{T202021}{Land use of Australia 2020–21 thematic layers}
#'  \item{P201011}{Land use of Australia 2010–11 agricultural commodities probability grids}
#'  \item{P201516}{Land use of Australia 2015–16 agricultural commodities probability grids}
#'  \item{P202021}{Land use of Australia 2020–21 agricultural commodities probability grids}
#' }.
#' @param ... Additional arguments passed to [stars::read_stars], for *e.g.*,
#'  `RAT` if you wish to set the active category when loading any of the
#'  available GeoTIFF files that are encoded with a raster attribute table.
#'
#' @references
#' ABARES 2024, Land use of Australia 2010–11 to 2020–21, Australian Bureau of
#' Agricultural and Resource Economics and Sciences, Canberra, November, CC BY
#' 4.0. \doi{10.25814/w175-xh85}
#'
#' @source
#' \describe{
#'  \item{Y201011}{\url{https://www.agriculture.gov.au/sites/default/files/documents/NLUM_v7_250_ALUMV8_2010_11_alb_package_20241128.zip}}
#'  \item{Y201516}{\url{https://www.agriculture.gov.au/sites/default/files/documents/NLUM_v7_250_ALUMV8_2015_16_alb_package_20241128.zip}}
#'  \item{Y202021}{\url{https://www.agriculture.gov.au/sites/default/files/documents/NLUM_v7_250_ALUMV8_2020_21_alb_package_20241128.zip}}
#'  \item{C201021}{\url{https://www.agriculture.gov.au/sites/default/files/documents/NLUM_v7_250_CHANGE_SIMP_2011_to_2021_alb_package_20241128.zip}}
#'  \item{T201011}{\url{https://www.agriculture.gov.au/sites/default/files/documents/NLUM_v7_250_INPUTS_2010_11_geo_package_20241128.zip}}
#'  \item{T201516}{\url{https://www.agriculture.gov.au/sites/default/files/documents/NLUM_v7_250_INPUTS_2015_16_geo_package_20241128.zip}}
#'  \item{T202021}{\url{https://www.agriculture.gov.au/sites/default/files/documents/NLUM_v7_250_INPUTS_2020_21_geo_package_20241128.zip}}
#'  \item{P201011}{\url{https://www.agriculture.gov.au/sites/default/files/documents/NLUM_v7_250_AgProbabilitySurfaces_2010_11_geo_package_20241128.zip}}
#'  \item{P201516}{\url{https://www.agriculture.gov.au/sites/default/files/documents/NLUM_v7_250_AgProbabilitySurfaces_2015_16_geo_package_20241128.zip}}
#'  \item{P202021}{\url{https://www.agriculture.gov.au/sites/default/files/documents/NLUM_v7_250_AgProbabilitySurfaces_2020_21_geo_package_20241128.zip}}
#' }.
#'
#' @examplesIf interactive()
#'
#' read_nlum_stars()
#'
#' nlum_stars
#'
#' plot(nlum_stars)
#'
#' @returns a \CRANpkg{stars} object that may be one or many layers depending
#'  upon the requested data set.
#' @family nlum
#' @autoglobal
#' @export
read_nlum_stars <- function(data_set, ...) {
  data_set <- rlang::arg_match(
    data_set,
    c(
      "Y201011",
      "Y201516",
      "Y202021",
      "C201121",
      "T201011",
      "T201516",
      "T202021",
      "P201011",
      "P201516",
      "P202021"
    )
  )

  nlum <- .get_nlum(.data_set = data_set)
  return(stars::read_stars(nlum[grep("tif$", nlum)]))
}
