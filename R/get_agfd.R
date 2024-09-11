#' Fetch Australian Gridded Farm Data
#'
#' @param fixed `numeric` Download fixed historical climate prices?  Defaults
#'  to `1`, downloads the data from ABARES farmpredict (Hughes *et al.*
#'  2022). Using `2` will download simulations where global output and input
#'  price indexes are fixed at values from the most recently completed financial
#'  year.
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

get_agdf <- function(fixed = 1) {
  agfd_file <- file.path(file.path(tempdir(), "agfd.zip"))

  if (fixed == 1) {
    url <- "https://daff.ent.sirsidynix.net.au/client/en_AU/search/asset/1036161/2"
  } else
    url <- "https://daff.ent.sirsidynix.net.au/client/en_AU/search/asset/1036161/3"

  curl::curl_download(url = url, destfile = agfd_file)

  withr::with_dir(tempdir(), utils::untar(agfd_file,
                                          exdir = tempdir(),
                                          quiet = FALSE))
}
