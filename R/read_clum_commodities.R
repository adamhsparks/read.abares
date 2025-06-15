#' Read catchment scale Land Use of Australia commodities shape file
#'
#' Download and import national scale Land Use of Australia shapefile of
#'  commodities data, data are cached on request.
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
#' @inheritSection get_agfd Caching
#'
#' @references
#' ABARES 2024, Land use of Australia 2010–11 to 2020–21, Australian Bureau of
#' Agricultural and Resource Economics and Sciences, Canberra, October,
#' CC BY 4.0. DOI: \doi{10.25814/w175-xh85}
#'
#' @source
#' \url{https://10.25814/w175-xh85}
#'
#' @examplesIf interactive()
#'
#' cc <- read_clum_commodities()
#'
#' cc
#'
#' @returns A [sf::sf] object of the requested data set.
#' @family clum
#' @autoglobal
#' @export
read_clum_commodities <- function(cache = FALSE) {
  if (missing(cache)) {
    cache <- getOption("read.abares.cache", default = FALSE)
  }

  clum <- .get_clum(.data_set = "CLUM_Commodities_2023", .cache = cache)
  return(sf::st_read(clum, quiet = TRUE))
}
