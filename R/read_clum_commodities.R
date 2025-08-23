#' Read ABARES catchment scale \dQuote{Land Use of Australia} commodities shapefile
#'
#' Download catchment level land use commodity data shapefile and import it into
#' your active \R session after correcting invalid geometries.
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
#' clum_commodities <- get_clum_commodities()
#'
#' clum_commodities
#'
#' @returns An [sf::sf()] object.
#'
#' @autoglobal
#' @export

read_clum_commodities <- function() {
  .data_set <- "clum_commodities"
  talktalk <- !(getOption("read.abares.verbosity") %in% c("quiet", "minimal"))

  download_file <- fs::path(tempdir(), "clum", sprintf("%s.zip", .data_set))

  # this is where the zip file is downloaded
  download_dir <- fs::path_dir(download_file)

  file_url <-
    .retry_download(
      url = "https://data.gov.au/data/dataset/8af26be3-da5d-4255-b554-f615e950e46d/resource/b216cf90-f4f0-4d88-980f-af7d1ad746cb/download/clum_commodities_2023.zip",
      .f = download_file
    )

  tryCatch(
    {
      withr::with_dir(
        download_dir,
        utils::unzip(zipfile = download_file, exdir = download_dir)
      )
      clum_commodities <- sf::st_read(
        fs::path(clum_dir, "CLUM_Commodities_2023.shp"),
        quiet = talktalk
      )
      clum_commodities <- sf::st_make_valid(x)
    },
    error = function(e) {
      fs::file_delete(c(download_file, download_dir, clum_dir))
      cli::cli_abort(
        "There was an issue with the downloaded file. I've deleted
           this bad version of the downloaded file, please retry.",
        call = rlang::caller_env()
      )
    }
  )
  return(clum_commodities)
}
