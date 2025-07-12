#' Read catchment scale \dQuote{Land Use of Australia} commodities shape file
#'
#' Download and import catchment scale \dQuote{Land Use of Australia} shapefile
#'  of commodities data. Data are cached on request.
#'
#' @details From the
#' [ABARES website](https://www.agriculture.gov.au/abares/aclump/land-use/land-use-of-australia-2010-11-to-2020-21):
#' \dQuote{The Catchment Scale Land Use of Australia – Commodities – Update
#' December 2023 dataset shows the location and extent of select commodities,
#' where mapped. This dataset replaces the Catchment Scale Land Use of Australia
#' – Commodities – Update December 2020. This dataset is the fourth national
#' compilation of catchment scale commodity data for Australia (CLUMC), current
#' as at December 2023. It has been compiled from vector land use datasets
#' collected as part of state and territory mapping programs and other
#' authoritative sources through the Australian Collaborative Land Use and
#' Management Program (\acronym{ACLUMP}). The commodities data complements the
#' Catchment Scale Land Use of Australia – Update December 2023 dataset
#' (\acronym{ABARES} 2024).
#'
#' This dataset comprises more than 176 thousand features representing 185,
#' predominantly agricultural, commodities over 63 million hectares.}
#'  -- \acronym{ABARES}, 2024-11-28
#'
#' @references
#' ABARES 2024, Catchment Scale Land Use of Australia – Commodities – Update
#'  December 2023, Australian Bureau of Agricultural and Resource Economics and
#' Sciences, Canberra, February CC BY 4.0. DOI: \doi{10.25814/zfjz-jt75}
#'
#' @source
#' \url{https://data.gov.au/data/dataset/catchment-scale-land-use-of-australia-and-commodities-update-december-2023/resource/b216cf90-f4f0-4d88-980f-af7d1ad746cb}
#'
#' @examplesIf interactive()
#'
#' cc <- read_clum_commodities()
#'
#' cc
#'
#' @returns An [sf::sf()] object of the requested data set.
#' @family clum
#' @autoglobal
#' @export
read_clum_commodities <- function() {
  if (
    getOption("read.abares.verbosity") == "quiet" ||
      getOption("read.abares.verbosity") == "minimal"
  ) {
    talktalk <- FALSE
  } else {
    talktalk <- TRUE
  }
  clum <- .get_clum(.data_set = "CLUM_Commodities_2023")
  return(sf::st_read(clum, quiet = talktalk))
}
