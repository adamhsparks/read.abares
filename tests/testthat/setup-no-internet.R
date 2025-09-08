offline_fail <- function(...) {
  stop("Network access is forbidden in tests. Mock it.", call. = FALSE)
}
testthat::local_mocked_bindings(curl_download = offline_fail, .package = "curl")
testthat::local_mocked_bindings(
  download.file = offline_fail,
  .package = "utils"
)
testthat::local_mocked_bindings(
  GET = function(...) offline_fail(),
  .package = "httr"
)
testthat::local_mocked_bindings(
  req_perform = function(...) offline_fail(),
  .package = "httr2"
)
