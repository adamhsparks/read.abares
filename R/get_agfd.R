#' Fetch Australian Gridded Farm Data
#'
#' @param fixed `Boolean` Download fixed historical climate prices?  Defaults
#'  to `FALSE`, downloads the data from ABARES farmpredict (Hughes *et al.*
#'  2022). Using `TRUE` will download simulations where global output and input
#'  price indexes are fixed at values from the most recently completed financial
#'  year.
#' @param class `character` Return an object that is a [terra::rast()] object,
#'   \dQuote{terra}, or a [`stars`] object, \dQuote{stars}.  Defaults to
#'   \dQuote{terra}.
#'
#' @references N. Hughes, W.Y. Soh, C. Boult, K. Lawson, Defining drought from
#'  the perspective of Australian farmers, Climate Risk Management, Volume 35,
#'  2022, 100420, ISSN 2212-0963, DOI
#'  [10.1016/j.crm.2022.100420](https://doi.org/10.1016/j.crm.2022.100420).
#'
#' @examplesIf interactive()
#' agfd <- get_agdf()
#'
#' @export

get_agdf <- function(fixed = FALSE, class = "terra") {
  cache_dir <-  tools::R_user_dir(package = "agfd", which = "cache")
  if (dir.exists(cache_dir)) {
    files <- list.files(cache_dir, full.names = TRUE)
    return(.read_agdf_nc(class))

  } else {
    agfd_file <- file.path(file.path(tempdir(), "agfd.zip"))

    if (isTRUE(fixed)) {
      url <- "https://daff.ent.sirsidynix.net.au/client/en_AU/search/asset/1036161/2"
    } else
      url <- "https://daff.ent.sirsidynix.net.au/client/en_AU/search/asset/1036161/3"

    curl::curl_download(url = url,
                        destfile = agfd_file,
                        quiet = FALSE)

    withr::with_dir(tempdir(), utils::untar(agfd_file, exdir = tempdir()))
    files <- list.files(file.path(tempdir(), "historical_climate_and_prices"),
                        full.names = TRUE)
  }
}
