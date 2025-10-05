# Known URLs used in read.abares
urls_to_test <- c(
  "https://anrdl-integration-web-catalog-saxfirxkxt.s3-ap-southeast-2.amazonaws.com/warehouse/staiar9cl__059/staiar9cl__05911a01eg_geo___.zip",
  "https://daff.ent.sirsidynix.net.au/client/en_AU/search/asset/1031941/0",
  "https://daff.ent.sirsidynix.net.au/client/en_AU/search/asset/1036161/2",
  "https://daff.ent.sirsidynix.net.au/client/en_AU/search/asset/1036161/3",
  "https://daff.ent.sirsidynix.net.au/client/en_AU/search/asset/1036420/0",
  "https://daff.ent.sirsidynix.net.au/client/en_AU/search/asset/1036421/0",
  "https://daff.ent.sirsidynix.net.au/client/en_AU/search/asset/1036422/0",
  "https://daff.ent.sirsidynix.net.au/client/en_AU/search/asset/1036423/0",
  "https://daff.ent.sirsidynix.net.au/client/en_AU/search/asset/1036424/0",
  "https://daff.ent.sirsidynix.net.au/client/en_AU/search/asset/1036425/0",
  "https://data.gov.au/data/dataset/8af26be3-da5d-4255-b554-f615e950e46d/resource/6deab695-3661-4135-abf7-19f25806cfd7/download/clum_50m_2023_v2.zip",
  "https://data.gov.au/data/dataset/8af26be3-da5d-4255-b554-f615e950e46d/resource/98b1b93f-e5e1-4cc9-90bf-29641cfc4f11/download/scale_date_update.zip",
  "https://www.abs.gov.au/statistics/industry/agriculture/australian-agriculture-broadacre-crops/2023-24/AABDC_Winter_Broadacre_202324.xlsx",
  "https://www.abs.gov.au/statistics/industry/agriculture/australian-agriculture-broadacre-crops/2023-24/AABDC_Summer_202324.xlsx",
  "https://www.abs.gov.au/statistics/industry/agriculture/australian-agriculture-broadacre-crops/2023-24/AABDC_Sugarcane_202324.xlsx",
  "https://www.abs.gov.au/statistics/industry/agriculture/australian-agriculture-broadacre-crops/2022-23/AABDC_Winter_Broadacre_202223.xlsx",
  "https://www.abs.gov.au/statistics/industry/agriculture/australian-agriculture-broadacre-crops/2022-23/AABDC_Summer_Broadacre_202223.xlsx",
  "https://www.abs.gov.au/statistics/industry/agriculture/australian-agriculture-broadacre-crops/2022-23/AABDC_Sugarcane_202223.xlsx",
  "https://www.abs.gov.au/statistics/industry/agriculture/australian-agriculture-livestock/2023-24/AALDC_Value%20of%20livestock%20and%20products%202023-24.xlsx",
  "https://www.abs.gov.au/statistics/industry/agriculture/australian-agriculture-livestock/2023-24/AALDC_Cattle%20herd_2023_24.xlsx",
  "https://www.abs.gov.au/statistics/industry/agriculture/australian-agriculture-livestock/2023-24/AALDC_Cattle%20herd%20series_2005%20to%202024.xlsx",
  "https://www.abs.gov.au/statistics/industry/agriculture/australian-agriculture-horticulture/2022-23/AAHDC_Aust_Horticulture_202223.xlsx",
  "https://www.abs.gov.au/statistics/industry/agriculture/australian-agriculture-horticulture/2023-24/AAHDC_Aust_Horticulture_202324.xlsx",
  "https://www.agriculture.gov.au/sites/default/files/documents/aagis_asgs16v1_g5a.shp_.zip",
  "https://www.agriculture.gov.au/sites/default/files/documents/CLUM_DescriptiveMetadata_December2023_v2.pdf",
  "https://www.agriculture.gov.au/sites/default/files/documents/fdp-BySize-ByPerformance.csv",
  "https://www.agriculture.gov.au/sites/default/files/documents/fdp-national-historical.csv",
  "https://www.agriculture.gov.au/sites/default/files/documents/fdp-performance-by-size.csv",
  "https://www.agriculture.gov.au/sites/default/files/documents/fdp-regional-historical.csv",
  "https://www.agriculture.gov.au/sites/default/files/documents/fdp-state-historical.csv",
  "https://www.agriculture.gov.au/sites/default/files/documents/NLUM_v7_250_AgProbabilitySurfaces_2010_11_geo_package_20241128.zip",
  "https://www.agriculture.gov.au/sites/default/files/documents/NLUM_v7_250_AgProbabilitySurfaces_2015_16_geo_package_20241128.zip",
  "https://www.agriculture.gov.au/sites/default/files/documents/NLUM_v7_250_AgProbabilitySurfaces_2020_21_geo_package_20241128.zip",
  "https://www.agriculture.gov.au/sites/default/files/documents/NLUM_v7_250_ALUMV8_2010_11_alb_package_20241128.zip",
  "https://www.agriculture.gov.au/sites/default/files/documents/NLUM_v7_250_ALUMV8_2015_16_alb_package_20241128.zip",
  "https://www.agriculture.gov.au/sites/default/files/documents/NLUM_v7_250_ALUMV8_2020_21_alb_package_20241128.zip",
  "https://www.agriculture.gov.au/sites/default/files/documents/NLUM_v7_250_CHANGE_SIMP_2011_to_2021_alb_package_20241128.zip",
  "https://www.agriculture.gov.au/sites/default/files/documents/NLUM_v7_250_INPUTS_2010_11_geo_package_20241128.zip",
  "https://www.agriculture.gov.au/sites/default/files/documents/NLUM_v7_250_INPUTS_2015_16_geo_package_20241128.zip",
  "https://www.agriculture.gov.au/sites/default/files/documents/NLUM_v7_250_INPUTS_2020_21_geo_package_20241128.zip",
  "https://www.agriculture.gov.au/sites/default/files/documents/NLUM_v7_DescriptiveMetadata_20241128_0.pdf"
)

#' Create a curl Handle for read.abares to use
#'
#' @returns A [curl::handle] object with polite headers and options set.
#' @dev
set_curl_handle <- function() {
  user_agent <- getOption("read.abares.user_agent", "read.abares R package")
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
    failonerror = FALSE, # Changed to FALSE to handle status codes manually
    timeout = getOption("read.abares.timeout", 7200L),
    accept_encoding = "" # allow gzip/deflate/br for headers
  )
  return(h)
}

# Helper to check DNS resolution (simplified approach)
check_dns <- function(host) {
  tryCatch(
    {
      # Simple ping-like check using curl itself
      test_url <- paste0("https://", host)
      h <- curl::new_handle()
      curl::handle_setopt(
        h,
        connecttimeout_ms = 5000L,
        nobody = TRUE, # HEAD request only
        failonerror = FALSE
      )
      result <- curl::curl_fetch_memory(test_url, handle = h)
      return(TRUE)
    },
    error = function(e) {
      # Check if it's a DNS-related error
      return(
        !grepl("Could not resolve host|Name or service not known", e$message)
      )
    }
  )
}

# Helper to check a single URL
check_url <- function(this_url) {
  is_s3 <- grepl("s3[-.]", this_url)
  host <- sub("^https?://([^/]+).*", "\\1", this_url)

  # Skip DNS check for S3 URLs as they're usually reliable
  if (!is_s3) {
    dns_ok <- check_dns(host)
    if (!dns_ok) {
      return(list(
        url = this_url, # Fixed: was 'url' but should be 'this_url'
        status = NA,
        error = paste("DNS resolution failed for", host)
      ))
    }
  }

  result <- tryCatch(
    curl::curl_fetch_memory(this_url, handle = set_curl_handle()),
    error = function(e) e
  )

  if (inherits(result, "error")) {
    return(list(url = this_url, status = NA, error = conditionMessage(result)))
  } else {
    return(list(url = this_url, status = result$status_code, error = NULL))
  }
}

# Test for URL availability
test_that("All known ABARES/ABS URLs resolve and return HTTP 200", {
  skip_if_offline()

  batch_size <- 5L # Reduced batch size to be more conservative
  delay_between_batches <- 3L # Increased delay

  all_results <- list()

  for (i in seq(1L, length(urls_to_test), by = batch_size)) {
    batch_end <- min(i + batch_size - 1L, length(urls_to_test))
    batch <- urls_to_test[i:batch_end]

    cat(
      "Testing batch",
      ceiling(i / batch_size),
      "of",
      ceiling(length(urls_to_test) / batch_size),
      "\n"
    )

    batch_results <- lapply(batch, check_url)
    all_results <- c(all_results, batch_results)

    # Add delay between batches (except for the last batch)
    if (batch_end < length(urls_to_test)) {
      Sys.sleep(delay_between_batches)
    }
  }

  # Process all results at once for better test reporting
  failed_urls <- character(0L)
  error_urls <- character(0L)

  for (res in all_results) {
    if (!is.null(res$error)) {
      error_urls <- c(error_urls, paste(res$url, "->", res$error))
    } else if (res$status != 200L) {
      failed_urls <- c(failed_urls, paste(res$url, "-> HTTP", res$status))
    }
  }

  # Report all failures at once
  if (length(error_urls) > 0L) {
    cat("URLs with errors:\n")
    cat(paste(error_urls, collapse = "\n"), "\n")
  }

  if (length(failed_urls) > 0L) {
    cat("URLs with non-200 status:\n")
    cat(paste(failed_urls, collapse = "\n"), "\n")
  }

  # Final assertions
  expect_length(
    error_urls,
    0L,
  )
  expect_length(
    failed_urls,
    0L,
  )
})

# Additional test for individual URL checking function
test_that("check_url function works correctly", {
  # Test with a reliable URL
  result <- check_url("https://httpbin.org/status/200")
  expect_null(result$error)
  expect_identical(result$status, 200L)

  # Test with a 404 URL
  result_404 <- check_url("https://httpbin.org/status/404")
  expect_null(result_404$error)
  expect_identical(result_404$status, 404L)
})

# Test for curl handle creation
test_that("set_curl_handle creates valid handle", {
  handle <- set_curl_handle()
  expect_s3_class(handle, "curl_handle")
})
