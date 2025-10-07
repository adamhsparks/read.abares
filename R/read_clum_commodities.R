#' Read ABARES' Catchment Scale "Land Use of Australia" Commodities Shapefile
#'
#' Download catchment level land use commodity data shapefile and import it into
#' your active \R session after correcting invalid geometries.
#'
#' @inheritParams read_aagis_regions
#'
#' @references
#' ABARES 2024, Catchment Scale Land Use of Australia – Update December 2023
#' version 2, Australian Bureau of Agricultural and Resource Economics and
#' Sciences, Canberra, June, CC BY 4.0, DOI: \doi{10.25814/2w2p-ph98}.
#'
#' @source
#' <https://data.gov.au/data/dataset/catchment-scale-land-use-of-australia-and-commodities-update-december-2023/resource/b216cf90-f4f0-4d88-980f-af7d1ad746cb>
#'
#' @examplesIf interactive()
#' clum_commodities <- get_clum_commodities()
#'
#' clum_commodities
#'
#' @returns An [sf::sf()] object.
#'
#' @autoglobal
#' @export

read_clum_commodities <- function(x = NULL) {
  talktalk <- !(getOption("read.abares.verbosity") %in% c("quiet", "minimal"))

  if (is.null(x)) {
    x <- fs::path(tempdir(), "clum_commodities.zip")

    .retry_download(
      url = "https://data.gov.au/data/dataset/8af26be3-da5d-4255-b554-f615e950e46d/resource/b216cf90-f4f0-4d88-980f-af7d1ad746cb/download/clum_commodities_2023.zip",
      dest = x,
      dataset_id = "clum_commodities",
      show_progress = TRUE
    )
    .unzip_file(x)
  }
  clum_commodities <- sf::st_read(
    fs::path(tempdir(), "CLUM_Commodities_2023"),
    quiet = talktalk
  )
  return(sf::st_make_valid(clum_commodities))
}
