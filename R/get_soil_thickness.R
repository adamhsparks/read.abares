#' Download Soil Thickness for Australian Areas of Intensive Agriculture of Layer 1
#'
#' @param cache `Boolean` Cache the soil thickness data files after download
#' using [tools::R_user_dir] to identify the proper directory for storing user
#' data in a cache for this package. Defaults to `TRUE`, caching the files
#' locally. If `FALSE`, this function uses `tempdir()` and the files are deleted
#' upon closing of the \R session.
#'
#' @examplesIf interactive()
#' get_soil_thickness()
#'
#' @return A character string with the file path of the resulting \acronym{ESRI}
#'  Grid file
#'
#' @export

get_soil_thickness <- function(cache = TRUE) {
  # this should be turned into a generic function and shared between functions internally
  download_file <- data.table::fifelse(cache,
                                       file.path(.find_user_cache(), "soil_thick.zip"),
                                       file.path(file.path(tempdir(), "soil_thick.zip")))

  # this is where the zip file is downloaded
  download_dir <- dirname(download_file)

  # this is where the zip files are unzipped in `soil_thick_dir`
  soil_thick_adf_dir <- file.path(download_dir, "soil_thickness_adf")

  # only download if the files aren't already local
  if (!dir.exists(file.path(download_dir, "soil_thickness"))) {
    # if caching is enabled but the {abares} cache dir doesn't exist, create it
    if (cache) {
      dir.create(soil_thick_adf_dir, recursive = TRUE)
    }
    url <- "https://anrdl-integration-web-catalog-saxfirxkxt.s3-ap-southeast-2.amazonaws.com/warehouse/staiar9cl__059/staiar9cl__05911a01eg_geo___.zip"
    curl::curl_download(url = url,
                        destfile = download_file,
                        quiet = FALSE)

    withr::with_dir(download_dir,
                    utils::unzip(download_file,
                                 exdir = file.path(download_dir)))
    file.rename(file.path(download_dir, "staiar9cl__05911a01eg_geo___/"),
                file.path(download_dir, "soil_thickness"))
    unlink(download_file)
  }
  return(file.path(download_dir, "soil_thickness/thpk_1"))
}
