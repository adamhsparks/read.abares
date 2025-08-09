#' Get catchment scale \dQuote{Land Use of Australia} data for local use
#'
#' An internal function used by [read_clum_terra()] and [read_clum_stars()] or
#'  [read_clum_commodities()] that downloads catchment level land use data
#'  files, unzips the download file and deletes unnecessary files that are
#'  included in the download.  Data are cached on request.
#'
#' @param .data_set A string value indicating the data desired for download.
#' One of:
#' \describe{
#'  \item{clum_50m_2023_v2}{Catchment Scale Land Use of Australia – Update December 2023 version 2}
#'  \item{scale_date_update}{Catchment Scale Land Use of Australia - Date and Scale of Mapping}
#'  \item{CLUM_Commodities_2023}{Catchment Scale Land Use of Australia – Commodities – Update December 2023}
#' }.
#' @details
#' The `CLUM_50m_2023v2` and `date_CLUM2023` datasets are available as GeoTIFF
#'  files. The `CLUM_Commodities_2023` dataset is available as a shapefile.
#'  The GeoTIFF files are both saved in the same format. The
#'  `CLUM_Commodities_2023` file is saved as a GeoPackage after correcting
#'  invalid geometries.
#'
#' @references
#' ABARES 2024, Catchment Scale Land Use of Australia – Update December 2023
#' version 2, Australian Bureau of Agricultural and Resource Economics and
#' Sciences, Canberra, June, CC BY 4.0, DOI: \doi{10.25814/2w2p-ph98}.
#'
#' @source
#' \url{https://10.25814/2w2p-ph98}.
#'
#' @examplesIf interactive()
#' CLUM50m <- get_clum(data_set = "CLUM_50m")
#'
#' CLUM50m
#'
#' @returns A `read.abares.clum` object, a list of files containing a spatial
#'  data file of or related to Australian catchment scale land use data.
#'
#' @autoglobal
#' @dev

.get_clum <- function(.data_set) {
  download_file <- data.table::fifelse(
    getOption("read.abares.cache", FALSE),
    fs::path(.find_user_cache(), "clum", sprintf("%s.zip", .data_set)),
    fs::path(tempdir(), "clum", sprintf("%s.zip", .data_set))
  )

  if (
    getOption("read.abares.verbosity") == "quiet" ||
      getOption("read.abares.verbosity") == "minimal"
  ) {
    talktalk <- FALSE
  } else {
    talktalk <- TRUE
  }

  # this is where the zip file is downloaded
  download_dir <- fs::path_dir(download_file)

  # this is where the zip files are unzipped and read from
  clum_dir <- fs::path(download_dir, .data_set)

  # only download if the files aren't already local
  if (fs::dir_exists(clum_dir)) {
    clum <- fs::dir_ls(fs::path_abs(clum_dir), regexp = "[.]tif$|[.]gpkg$")
    class(clum) <- union("read.abares.clum.files", class(clum))
    return(clum)
  }

  fs::dir_create(clum_dir, recurse = TRUE)

  file_url <-
    "https://data.gov.au/data/dataset/8af26be3-da5d-4255-b554-f615e950e46d/resource/"

  file_url <- switch(
    .data_set,
    "clum_50m_2023_v2" = sprintf(
      "%s6deab695-3661-4135-abf7-19f25806cfd7/download/clum_50m_2023_v2.zip",
      file_url
    ),
    "scale_date_update" = sprintf(
      "%s98b1b93f-e5e1-4cc9-90bf-29641cfc4f11/download/scale_date_update.zip",
      file_url
    ),
    "CLUM_Commodities_2023" = sprintf(
      "%sb216cf90-f4f0-4d88-980f-af7d1ad746cb/download/clum_commodities_2023.zip",
      file_url
    )
  )

  .retry_download(
    url = file_url,
    .f = download_file
  )

  tryCatch(
    {
      withr::with_dir(
        download_dir,
        utils::unzip(zipfile = download_file, exdir = download_dir)
      )
      if (.data_set != "CLUM_Commodities_2023") {
        fs::file_delete(
          setdiff(
            fs::dir_ls(clum_dir),
            fs::dir_ls(clum_dir, regexp = "[.]tif$|[.]tif\\..+$")
          )
        )
      } else {
        # handle the commodities shape file data
        x <- sf::st_read(
          fs::path(clum_dir, "CLUM_Commodities_2023.shp"),
          quiet = talktalk
        )
        x <- sf::st_make_valid(x)

        sf::st_write(
          x,
          fs::path(clum_dir, "CLUM_Commodities_2023.gpkg"),
          quiet = talktalk
        )

        if (
          isFALSE(fs::file_exists(fs::path(
            download_dir,
            "CLUMC_DescriptiveMetadata_December2023.pdf"
          )))
        ) {
          fs::file_move(
            fs::path(
              clum_dir,
              "CLUMC_DescriptiveMetadata_December2023.pdf"
            ),
            fs::path(download_dir, "CLUMC_DescriptiveMetadata_December2023.pdf")
          )
        }

        fs::file_delete(
          setdiff(
            fs::dir_ls(clum_dir),
            fs::dir_ls(clum_dir, regexp = "[.]gpkg$")
          )
        )
      }
    },
    error = function(e) {
      cli::cli_abort(
        "There was an issue with the downloaded file. I've deleted
           this bad version of the downloaded file, please retry.",
        call = rlang::caller_env()
      )
    }
  )

  if (getOption("read.abares.cache", FALSE)) {
    fs::file_delete(download_file)
  }

  clum <- fs::dir_ls(fs::path_abs(clum_dir), regexp = "[.]tif$|[.]gpkg$")
  class(clum) <- union("read.abares.clum.files", class(clum))
  return(clum)
}


#' Prints read.abares.clum.files objects
#'
#' Custom [base::print()] method for `read.abares.clum.files` objects.
#'
#' @param x a `read.abares.agfd.clum.files` object.
#' @param ... ignored.
#' @export
#' @autoglobal
#' @noRd
print.read.abares.agfd.clum.files <- function(x, ...) {
  cli::cli_h1("Locally Available ABARES Catchment Scale Land Use Files")
  cli::cli_ul(basename(x))
  cli::cat_line()
  invisible(x)
}

#' Set CLUM scale update levels
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


#' Create and apply a colour data.frame for the clum_50m_2023_v2 data
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
