#' Read ABARES' National Scale "Land Use of Australia" Data Using terra
#'
#' Download and import national scale "Land Use of Australia v7" GeoTIFFs as
#'  categorical [terra::rast()] objects.
#'
#' @details From the
#' [ABARES website](https://www.agriculture.gov.au/abares/aclump/land-use/land-use-of-australia-2010-11-to-2020-21):
#' "The _Land use of Australia 2010–11 to 2020–21_ data package consists
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
#' with updates to these time periods."
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
#' @param ... Other arguments passed to [terra::rast()].
#' @references
#' ABARES 2024, Land use of Australia 2010–11 to 2020–21, Australian Bureau of
#' Agricultural and Resource Economics and Sciences, Canberra, November, CC BY
#' 4.0. \doi{10.25814/w175-xh85}.
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
#' nlum_terra <- read_nlum_terra(data_set = "Y202021")
#'
#' nlum_terra
#'
#' plot(nlum_terra)
#'
#' @returns A \CRANpkg{terra} `SpatRaster` object that may be one or many layers
#'  depending upon the requested data set.
#' @family nlum
#' @autoglobal
#' @export
read_nlum_terra <- function(
  data_set = NULL,
  x = NULL,
  ...
) {
  # see "get_lum_files. R" for details of this fn
  y <- .get_lum_files(x, data_set, lum = "nlum")

  # Normalize path
  zip_path <- normalizePath(y$file_path, winslash = "/", mustWork = FALSE)

  # Build vsizip path - handle Unix vs Windows differently
  if (.Platform$OS.type == "windows") {
    vsi_path <- sprintf("/vsizip//%s/%s", zip_path, y$tiff)
  } else {
    # On Unix/macOS, path already starts with /, so don't double it
    vsi_path <- sprintf("/vsizip%s/%s", zip_path, y$tiff)
  }

  return(terra::rast(vsi_path, ...))
}
