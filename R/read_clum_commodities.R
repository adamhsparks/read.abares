#' Read ABARES' Catchment Scale "Land Use of Australia" Commodities Shapefile
#'
#' Download (if desired) catchment level land use commodity data shapefile and
#'  import it into your active \R session after correcting invalid geometries.
#'
#' @inheritParams read_aagis_regions
#'
#' @references
#' ABARES 2024, Catchment Scale Land Use of Australia – Update December 2023
#' version 2, Australian Bureau of Agricultural and Resource Economics and
#' Sciences, Canberra, June, CC BY 4.0, DOI: \doi{10.25814/2w2p-ph98}.
#'
#' @source
#' \doi{10.25814/zfjz-jt75}
#'
#' @examplesIf interactive()
#' clum_commodities <- read_clum_commodities()
#'
#' clum_commodities
#'
#' @returns An [sf::sf()] object.
#'
#' @autoglobal
#' @export

read_clum_commodities <- function(x = NULL) {
  if (is.null(x)) {
    x <- fs::path_temp("clum_commodities.zip")

    .retry_download(
      url = "https://data.gov.au/data/dataset/8af26be3-da5d-4255-b554-f615e950e46d/resource/b216cf90-f4f0-4d88-980f-af7d1ad746cb/download/clum_commodities_2023.zip",
      dest = x
    )
  }
  clum_commodities <- sf::st_read(
    dsn = sprintf(
      "/vsizip//%s/CLUM_Commodities_2023/CLUM_Commodities_2023.shp",
      x
    ),
    quiet = !(getOption("read.abares.verbosity") %in% c("quiet", "minimal"))
  )
  return(sf::st_make_valid(clum_commodities))
}
