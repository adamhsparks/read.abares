#' Read ABARES' "Australian Gridded Farm Data" (AGFD) NCDF Files as a data.table Object
#'
#' Read "Australian Gridded Farm Data", (\acronym{AGFD}), as a
#'  [data.table::data.table()] object.
#
#' @param yyyy Returns only data for the specified year or years for climate
#'  data (fixed prices) or the years for historical climate and prices depending
#'  upon the setting of `fixed_prices`.  Note that this will still download the
#'  entire data set, that cannot be avoided, but will only return the
#'  requested year(s) in your \R session.  Valid years are from 1991 to 2023
#'  inclusive.
#' @param fixed_prices Download historical climate and prices or historical
#'  climate and fixed prices as described in  (Hughes *et al.* 2022). Defaults
#'  to `TRUE` and downloads the data with historical climate and fixed prices
#'  "to isolate the effects of climate variability on financial incomes
#'  for broadacre farm businesses" (ABARES 2024).  Using `TRUE` will download
#'  simulations where global output and input price indexes are fixed at values
#'  from the most recently completed financial year.
#' @inheritParams read_aagis_regions
#'
#' @details
#'
#' From the [ABARES website](https://www.agriculture.gov.au/abares/research-topics/surveys/farm-survey-data/australian-gridded-farm-data):
#'  "The Australian Gridded Farm Data (\acronym{AGFD}) are a set of national
#'  scale maps containing simulated data on historical broadacre farm business
#'  outcomes including farm profitability on an 0.05-degree (approximately 5 km)
#'  grid.\cr
#'  These data have been produced by \acronym{ABARES} as part of the ongoing
#'  Australian Agricultural Drought Indicator (\acronym{AADI}) project
#'  (previously known as the Drought Early Warning System Project) and were
#'  derived using \acronym{ABARES}
#'  [*farmpredict*](https://www.agriculture.gov.au/abares/research-topics/climate/drought/farmpredict)
#'  model, which in turn is based on ABARES Agricultural and Grazing Industries
#'  Survey (\acronym{AAGIS}) data.\cr
#'  [Australian Agricultural Drought Indicator](https://www.agriculture.gov.au/abares/research-topics/climate/australian-agricultural-drought-indicators-project)
#'  (\acronym{AADI}) project (previously known as the Drought Early Warning
#'  System Project) and were derived using \acronym{ABARES}
#'  [*farmpredict*](https://www.agriculture.gov.au/abares/research-topics/climate/drought/farmpredict)
#'  model, which in turn is based on ABARES [Agricultural and Grazing Industries
#'  Survey](https://www.agriculture.gov.au/abares/research-topics/surveys/farm-definitions-methods)
#'  (\acronym{AAGIS}) data.\cr
#'  These maps provide estimates of farm business profit, revenue, costs and
#'  production by location (grid cell) and year for the period 1990-91 to
#'  2022-23. The data do not include actual observed outcomes but rather model
#'  predicted outcomes for representative or 'typical' broadacre farm
#'  businesses at each location considering likely farm characteristics and
#'  prevailing weather conditions and commodity prices."\cr
#'  -- \acronym{ABARES}, 2024-11-25
#'
#' If you have not already downloaded the files, both sets of data are large in
#'  file size, *i.e.*, >1GB, and will require time to download.
#'
#' @section Model scenarios:
#'
#' ### Historical Climate (fixed prices)
#'
#' The Historical Climate (fixed prices) scenario is similar to that described
#'  in Hughes *et al.* (2022) and is intended to isolate the effects of climate
#'  variability on financial incomes for broadacre farm businesses. In these
#'  simulations, global output and input price indexes are fixed at values from
#'  the most recently completed financial year. However, in these scenarios the
#'  spread between domestic and global grain (wheat, barley and sorghum) prices,
#'  along with Australian fodder prices are allowed to vary in response to
#'  climate data (to capture domestic increases in grain and fodder prices in
#'  drought years, see Hughes *et al.* 2022). A 33-year historical climate
#'  sequence (including historical simulated crop and pasture data from the
#'  \acronym{AADI} project) is simulated for each grid cell (1990-91 to
#'  2022-23).
#'
#' ### Historical Climate and Prices
#'
#' As part of the \acronym{AADI} project an additional scenario was developed
#'  accounting for changes in both climate conditions and output and input
#'  prices (*i.e.*, global commodity market variability). In this historical
#'  climate and prices scenario the 33-year reference period allows for
#'  variation in both historical climate conditions and historical prices. For
#'  this scenario, historical price indexes were de-trended, to account for
#'  consistent long-term trends in some real commodity prices (particularly
#'  sheep and lamb). The resulting simulation results and percentile indicators
#'  are intended to reflect the combined impacts of annual climate and commodity
#'  price variability."
#'
#'   -- Taken from  \cite{Australian Bureau of Agricultural and Resource
#'    Economics and Sciences (2024)}
#'
#' @section Data files:
#'
#' Simulation output data are saved as multilayer NetCDF files, which are named
#'  using following convention:
#'
#' \var{f<farm year>.c<climate year>.p<price year>.t<technology year>.nc}
#'
#'  where:
#'  * \var{<farm year>} = Financial year of farm business data is used in simulations.
#'  * \var{<climate year>} = Financial year of climate data is used in simulations.
#'  * \var{<price year>} = Financial year of output and input prices used in simulations.
#'  * \var{<technology year>} = Financial year of farm 'technology' (equal to farm year in all simulations)
#'  Here financial years are referred to by the closing calendar year
#'   (*e.g.*, 2022 = 1 July 2021 to 30 June 2022).
#'
#'   -- Taken from  \cite{Australian Bureau of Agricultural and Resource
#'    Economics and Sciences (2024)}
#'
#' @section Data layers:
#'
#' The data layers from the downloaded NetCDF files are described in Table 2
#'  as seen in \cite{Australian Bureau of Agricultural and Resource Economics
#'  and Sciences (2024)}.
#'
#' Following is a copy of Table 2 for your convenience, please refer to the full
#' document for all methods and metadata.
#'
#' \tabular{lll}{
#'   \strong{Layer} \tab \strong{Unit} \tab \strong{Description} \cr
#'   farmno                \tab -         \tab Row index and column index of the grid cell in the form of YYYXXX                                            \cr
#'   A_barley_hat_ha       \tab -         \tab Proportion of total farm area planted to barley                                                              \cr
#'   A_oilseeds_hat_ha     \tab -         \tab Proportion of total farm area planted to canola                                                              \cr
#'   A_sorghum_hat_ha      \tab -         \tab Proportion of total farm area planted to sorghum                                                             \cr
#'   A_total_cropped_ha    \tab -         \tab Proportion of total farm area planted to crops                                                               \cr
#'   A_wheat_hat_ha        \tab -         \tab Proportion of total farm area planted to wheat                                                               \cr
#'   C_chem_hat_ha         \tab $/ha      \tab Expenditure on crop and pasture chemicals per hectare                                                        \cr
#'   C_fert_hat_ha         \tab $/ha      \tab Expenditure on fertiliser per hectare                                                                        \cr
#'   C_fodder_hat_ha       \tab $/ha      \tab Expenditure on fodder per hectare                                                                            \cr
#'   C_fuel_hat_ha         \tab $/ha      \tab Expenditure on fuel, oil and grease per hectare                                                              \cr
#'   C_total_hat_ha        \tab $/ha      \tab Total cash costs per hectare                                                                                 \cr
#'   FBP_fci_hat_ha        \tab $/ha      \tab Farm cash income per hectare                                                                                 \cr
#'   FBP_fbp_hat_ha        \tab $/ha      \tab Farm business profit per hectare, cash income adjusted for family labour, depreciation, and changes in stocks\cr
#'   FBP_pfe_hat_ha        \tab $/ha      \tab Profit at full equity per hectare                                                                            \cr
#'   H_barley_dot_hat      \tab t/ha      \tab Barley yield (production per hectare planted)                                                                \cr
#'   H_oilseeds_dot_hat    \tab t/ha      \tab Oilseeds yield (production per hectare planted)                                                              \cr
#'   H_sorghum_dot_hat     \tab t/ha      \tab Sorghum yield (production per hectare planted)                                                               \cr
#'   H_wheat_dot_hat       \tab t/ha      \tab Wheat yield (production per hectare planted)                                                                 \cr
#'   Q_barley_hat_ha       \tab t/ha      \tab Barley sold per hectare (total farm area)                                                                    \cr
#'   Q_beef_hat_ha         \tab Number/ha \tab Beef number sold per hectare                                                                                 \cr
#'   Q_lamb_hat_ha         \tab Number/ha \tab Prime lamb number sold per hectare                                                                           \cr
#'   Q_oilseeds_hat_ha     \tab t/ha      \tab Canola sold per hectare (total farm area)                                                                    \cr
#'   Q_sheep_hat_ha        \tab Number/ha \tab Sheep number sold per hectare                                                                                \cr
#'   Q_sorghum_hat_ha      \tab t/ha      \tab Sorghum sold per hectare (total farm area)                                                                   \cr
#'   Q_wheat_hat_ha        \tab t/ha      \tab Wheat sold per hectare (total farm area)                                                                     \cr
#'   R_barley_hat_ha       \tab $/ha      \tab Barley gross receipts per hectare                                                                            \cr
#'   R_beef_hat_ha         \tab $/ha      \tab Beef cattle receipts per hectare                                                                             \cr
#'   R_lamb_hat_ha         \tab $/ha      \tab Prime lamb net receipts per hectare                                                                          \cr
#'   R_oilseeds_hat_ha     \tab $/ha      \tab Receipts for oilseeds this FY for oilseeds sold this FY or in previous FYs per hectare                       \cr
#'   R_sheep_hat_ha        \tab $/ha      \tab Sheep gross receipts per hectare                                                                             \cr
#'   R_sorghum_hat_ha      \tab $/ha      \tab Sorghum gross receipts per hectare                                                                           \cr
#'   R_total_hat_ha        \tab $/ha      \tab Total farm receipts per hectare                                                                              \cr
#'   R_wheat_hat_ha        \tab $/ha      \tab Wheat gross receipts per hectare                                                                             \cr
#'   S_beef_births_hat_ha  \tab Number/ha \tab Beef cattle births per hectare                                                                               \cr
#'   S_beef_cl_hat_ha      \tab Number/ha \tab Beef cattle on hand per hectare on 30 June                                                                   \cr
#'   S_beef_deaths_hat_ha  \tab Number/ha \tab Beef cattle deaths per hectare                                                                               \cr
#'   S_sheep_births_hat_ha \tab Number/ha \tab Sheep births per hectare                                                                                     \cr
#'   S_sheep_cl_hat_ha     \tab Number/ha \tab Sheep on hand per hectare on 30 June                                                                         \cr
#'   S_sheep_deaths_hat_ha \tab Number/ha \tab Sheep deaths per hectare                                                                                     \cr
#'   S_wheat_cl_hat_ha     \tab t/ha      \tab Wheat on hand per hectare on 30 June                                                                         \cr
#'   farmland_per_cell     \tab ha        \tab Indicative area of farmland in the grid cell
#' }
#'
#' @references
#'
#' *Australian gridded farm data*, Australian Bureau of Agricultural and
#'  Resource Economics and Sciences, Canberra, July 2024,
#'  \doi{10.25814/7n6z-ev41}.
#'  [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/legalcode).
#'
#' N. Hughes, W.Y. Soh, C. Boult, K. Lawson, *Defining drought from
#'  the perspective of Australian farmers*, Climate Risk Management, Volume 35,
#'  2022, 100420, ISSN 2212-0963, \doi{10.1016/j.crm.2022.100420}.
#'
#' @source
#'   * Historical climate prices fixed -- <https://daff.ent.sirsidynix.net.au/client/en_AU/search/asset/1036161/3>,
#'   * Historical climate and prices -- <https://daff.ent.sirsidynix.net.au/client/en_AU/search/asset/1036161/2>
#'
#' @returns A [data.table::data.table()] object of the "Australian Gridded Farm
#'  Data".
#'
#' @examplesIf interactive()
#'
#' # download and import AGFD files
#' agfd_dt <- read_agfd_dt()
#'
#' agfd_dt
#'
#' @family AGFD
#' @autoglobal
#' @export

read_agfd_dt <- function(
  yyyy = 1991:2023,
  fixed_prices = TRUE,
  x = NULL
) {
  .check_agfd_yyyy(.yyyy = yyyy)

  if (is.null(x) || missing(x)) {
    files <- .get_agfd(
      .fixed_prices = fixed_prices,
      .yyyy = yyyy
    )
  } else {
    # copy the file to the tempdir for the unzip fn to work properly
    # we won't touch the original file provided this way
    files <- .copy_local_agfd_zip(x)
  }

  tnc_list <- lapply(files, tidync::tidync)
  names(tnc_list) <- fs::path_file(files)
  dat <- data.table::rbindlist(
    lapply(tnc_list, tidync::hyper_tibble),
    idcol = "id"
  )
  dat[, lat := as.numeric(dat$lat)]
  dat[, lon := as.numeric(dat$lon)]
  rm(tnc_list)
  gc()
  return(dat[])
}

#' Check AGFD years for validity
#' @param .yyyy A year value for checking
#' @dev

.check_agfd_yyyy <- function(.yyyy) {
  if (any(.yyyy %notin% 1991:2023)) {
    cli::cli_abort(
      "{.arg yyyy} must be between 1991 and 2023 inclusive"
    )
  }
  if (!any(is.numeric(.yyyy))) {
    cli::cli_abort("{.arg yyyy} must be numeric.")
  }
}
