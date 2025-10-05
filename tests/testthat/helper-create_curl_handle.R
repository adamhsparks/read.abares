#' Create a curl Handle for read.abares to use
#'
#' @returns A [curl::handle] object with polite headers and options set.
#' @dev
set_curl_handle <- function() {
  user_agent <- getOption("read.abares.user_agent")
  #user_agent <- "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0 Safari/537.36"
  h <- curl::new_handle()
  curl::handle_setheaders(
    h,
    "User-Agent" = user_agent,
    "Accept" = "application/zip, application/octet-stream;q=0.9, */*;q=0.8",
    "Accept-Language" = "en-AU,en;q=0.9",
    "Connection" = "keep-alive"
  )

  curl::handle_setopt(
    h,
    followlocation = TRUE,
    maxredirs = 10L,
    http_version = 2L,
    ssl_verifypeer = TRUE,
    ssl_verifyhost = 2L,
    connecttimeout_ms = 15000L,
    low_speed_time = 0L,
    low_speed_limit = 0L,
    tcp_keepalive = 1L,
    tcp_keepidle = 60L,
    tcp_keepintvl = 60L,
    failonerror = TRUE,
    timeout = getOption("read.abares.timeout", 7200L),
    accept_encoding = "" # allow gzip/deflate/br for headers
  )
  return(h)
}
