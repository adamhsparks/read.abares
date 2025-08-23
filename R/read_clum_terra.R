#' Read Catchment Scale "Land Use of Australia" GeoTIFFs Using terra
#'
#' Download and import catchment scale "Land Use of Australia" GeoTIFFs using
#' \CRANpkg{terra} as a categorical [terra::rast()] object.
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
#' @param ... Additional arguments passed to [terra::rast()].
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
  r <- terra::rast(
    grep("[.]tif$", files, value = TRUE),
    props = TRUE,
    ...
  )
  if (data_set == "clum_50m_2023_v2") {
    terra::coltab(r) <- .create_clum_50m_coltab()
  }
  return(r)
}

#' Set CLUM Scale Update Levels
#'
#' Creates data.tables containing the raster categories for the \acronym{CLUM}
#'  scale update levels.
#'
#' @dev

.set_clum_update_levels <- function() {
  return(list(
    date_levels = data.table(
      int = 2008L:2023L,
      rast_cat = 2008L:2023L
    ),
    update_levels = data.table(
      int = 0L:1L,
      rast_cat = c("Not Updated", "Updated Since CLUM Dec. 2020 Release")
    ),
    scale_levels = data.table(
      int = c(5000L, 10000L, 20000L, 25000L, 50000L, 100000L, 250000L),
      rast_cat = c(
        "1:5,000",
        "1:10,000",
        "1:20,000",
        "1:25,000",
        "1:50,000",
        "1:100,000",
        "1:250,000"
      )
    )
  ))
}


#' Create and Apply a Colour data.frame for the clum_50m_2023_v2 Data
#'
#' Creates a `data.frame()` that contains the hexadecimal colour codes that
#' correspond with the integer values to display the map colours as published
#' by \acronym{ABARES} for the Catchment Level Land Use (\acronym{clum}) data.
#' Values are derived from the .qml file provided by \acronym{ABARES}.
#'
#'
#' @examples
#' .apply_clum_50m_col_df()
#'
#' @dev
.create_clum_50m_coltab <- function() {
  col_df <- data.table::as.data.table(
    list(
      value = c(
        0L,
        100L,
        110L,
        111L,
        112L,
        113L,
        114L,
        115L,
        116L,
        117L,
        120L,
        121L,
        122L,
        123L,
        124L,
        125L,
        130L,
        131L,
        132L,
        133L,
        134L,
        200L,
        210L,
        220L,
        221L,
        222L,
        300L,
        310L,
        311L,
        312L,
        313L,
        314L,
        320L,
        321L,
        322L,
        323L,
        324L,
        325L,
        330L,
        331L,
        332L,
        333L,
        334L,
        335L,
        336L,
        337L,
        338L,
        340L,
        341L,
        342L,
        343L,
        344L,
        345L,
        346L,
        347L,
        348L,
        349L,
        350L,
        351L,
        352L,
        353L,
        360L,
        361L,
        362L,
        363L,
        364L,
        365L,
        400L,
        410L,
        411L,
        412L,
        413L,
        414L,
        420L,
        421L,
        422L,
        423L,
        424L,
        430L,
        431L,
        432L,
        433L,
        434L,
        435L,
        436L,
        437L,
        438L,
        439L,
        440L,
        441L,
        442L,
        443L,
        444L,
        445L,
        446L,
        447L,
        448L,
        449L,
        450L,
        451L,
        452L,
        453L,
        454L,
        460L,
        461L,
        462L,
        463L,
        464L,
        465L,
        500L,
        510L,
        511L,
        512L,
        513L,
        514L,
        515L,
        520L,
        521L,
        522L,
        523L,
        524L,
        525L,
        526L,
        527L,
        528L,
        530L,
        531L,
        532L,
        533L,
        534L,
        535L,
        536L,
        537L,
        538L,
        540L,
        541L,
        542L,
        543L,
        544L,
        545L,
        550L,
        551L,
        552L,
        553L,
        554L,
        555L,
        560L,
        561L,
        562L,
        563L,
        564L,
        565L,
        566L,
        567L,
        570L,
        571L,
        572L,
        573L,
        574L,
        575L,
        580L,
        581L,
        582L,
        583L,
        584L,
        590L,
        591L,
        592L,
        593L,
        594L,
        595L,
        600L,
        610L,
        611L,
        612L,
        613L,
        614L,
        620L,
        621L,
        622L,
        623L,
        630L,
        631L,
        632L,
        633L,
        640L,
        641L,
        642L,
        643L,
        650L,
        651L,
        652L,
        653L,
        654L,
        660L,
        661L,
        662L,
        663L
      ),
      colour = c(
        "#ffffff",
        "#9666cc",
        "#9666cc",
        "#9666cc",
        "#9666cc",
        "#9666cc",
        "#9666cc",
        "#9666cc",
        "#9666cc",
        "#9666cc",
        "#c9beff",
        "#c9beff",
        "#c9beff",
        "#c9beff",
        "#c9beff",
        "#c9beff",
        "#de87dd",
        "#de87dd",
        "#de87dd",
        "#de87dd",
        "#de87dd",
        "#ffffe5",
        "#ffffe5",
        "#298944",
        "#298944",
        "#298944",
        "#ffd37f",
        "#adffb5",
        "#adffb5",
        "#adffb5",
        "#adffb5",
        "#adffb5",
        "#ffd37f",
        "#ffd37f",
        "#ffd37f",
        "#ffd37f",
        "#ffd37f",
        "#ffd37f",
        "#ffff00",
        "#ffff00",
        "#ffff00",
        "#ffff00",
        "#ffff00",
        "#ffff00",
        "#ffff00",
        "#ffff00",
        "#ffff00",
        "#ab8778",
        "#ab8778",
        "#ab8778",
        "#ab8778",
        "#ab8778",
        "#ab8778",
        "#ab8778",
        "#ab8778",
        "#ab8778",
        "#ab8778",
        "#ab8778",
        "#ab8778",
        "#ab8778",
        "#ab8778",
        "#000000",
        "#000000",
        "#000000",
        "#000000",
        "#000000",
        "#000000",
        "#ffaa00",
        "#adffb5",
        "#adffb5",
        "#adffb5",
        "#adffb5",
        "#adffb5",
        "#ffaa00",
        "#ffaa00",
        "#ffaa00",
        "#ffaa00",
        "#ffaa00",
        "#c9b854",
        "#c9b854",
        "#c9b854",
        "#c9b854",
        "#c9b854",
        "#c9b854",
        "#c9b854",
        "#c9b854",
        "#c9b854",
        "#c9b854",
        "#9c542e",
        "#9c542e",
        "#9c542e",
        "#9c542e",
        "#9c542e",
        "#9c542e",
        "#9c542e",
        "#9c542e",
        "#9c542e",
        "#9c542e",
        "#9c542e",
        "#9c542e",
        "#9c542e",
        "#9c542e",
        "#9c542e",
        "#000000",
        "#000000",
        "#000000",
        "#000000",
        "#000000",
        "#000000",
        "#9b0000",
        "#ffc9be",
        "#ffc9be",
        "#ffc9be",
        "#ffc9be",
        "#ffc9be",
        "#ffc9be",
        "#ffc9be",
        "#ffc9be",
        "#ffc9be",
        "#ffc9be",
        "#ffc9be",
        "#ffc9be",
        "#ffc9be",
        "#ffc9be",
        "#ffc9be",
        "#9b0000",
        "#9b0000",
        "#9b0000",
        "#9b0000",
        "#9b0000",
        "#9b0000",
        "#9b0000",
        "#9b0000",
        "#9b0000",
        "#ff0000",
        "#ff0000",
        "#b2b2b2",
        "#b2b2b2",
        "#b2b2b2",
        "#b2b2b2",
        "#9b0000",
        "#9b0000",
        "#9b0000",
        "#9b0000",
        "#9b0000",
        "#9b0000",
        "#9b0000",
        "#9b0000",
        "#9b0000",
        "#9b0000",
        "#9b0000",
        "#9b0000",
        "#9b0000",
        "#9b0000",
        "#9b0000",
        "#9b0000",
        "#9b0000",
        "#9b0000",
        "#9b0000",
        "#9b0000",
        "#47828f",
        "#47828f",
        "#47828f",
        "#47828f",
        "#47828f",
        "#47828f",
        "#47828f",
        "#47828f",
        "#47828f",
        "#47828f",
        "#47828f",
        "#0000ff",
        "#0000ff",
        "#0000ff",
        "#0000ff",
        "#0000ff",
        "#0000ff",
        "#0000ff",
        "#0000ff",
        "#0000ff",
        "#0000ff",
        "#0000ff",
        "#0000ff",
        "#0000ff",
        "#0000ff",
        "#0000ff",
        "#0000ff",
        "#0000ff",
        "#0000ff",
        "#0000ff",
        "#0000ff",
        "#0000ff",
        "#0000ff",
        "#0000ff",
        "#0000ff",
        "#0000ff",
        "#0000ff",
        "#0000ff"
      )
    ),
    row.names = c(NA, -198L),
    class = "data.frame"
  )
}
