# Tiny helpers to create synthetic httr2 responses for offline tests.
# See: https://httr2.r-lib.org/reference/response.html
mk_resp_json <- function(
  x,
  status = 200,
  url = "https://example.test/endpoint",
  method = "GET"
) {
  httr2::response_json(
    status_code = status,
    url = url,
    method = method,
    body = x
  )
}

mk_resp_text <- function(
  text,
  status = 200,
  url = "https://example.test/file.csv",
  method = "GET",
  content_type = "text/plain; charset=utf-8"
) {
  httr2::response(
    status_code = status,
    url = url,
    method = method,
    headers = list(`Content-Type` = content_type),
    body = charToRaw(enc2utf8(text))
  )
}

mk_resp_error <- function(
  status = 404,
  url = "https://example.test/missing",
  method = "GET"
) {
  httr2::response(
    status_code = status,
    url = url,
    method = method
  )
}
