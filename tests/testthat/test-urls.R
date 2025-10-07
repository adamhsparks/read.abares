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

# Add these dependencies to your DESCRIPTION file:
# future, future.apply, httr2

test_that("All known ABARES/ABS URLs resolve and return HTTP 200 (parallel)", {
  skip_if_offline()

  # Set up parallel processing
  future::plan(
    future::multisession,
    workers = min(4L, future::availableCores() - 1L)
  )
  on.exit(future::plan(future::sequential), add = TRUE)

  check_url_parallel <- function(this_url) {
    # Use httr2 for better connection pooling and HTTP/2 support
    resp <- httr2::request(this_url) |>
      httr2::req_method("HEAD") |> # HEAD request - no body download
      httr2::req_timeout(10L) |>
      httr2::req_retry(max_tries = 2L) |>
      httr2::req_user_agent("read.abares R package test") |>
      httr2::req_perform(verbosity = 0L)

    list(
      url = this_url,
      status = httr2::resp_status(resp),
      error = NULL
    )
  }

  # Run all requests in parallel
  all_results <- future.apply::future_lapply(
    urls_to_test,
    function(url) {
      tryCatch(
        check_url_parallel(url),
        error = function(e) {
          list(url = url, status = NA, error = conditionMessage(e))
        }
      )
    },
    future.seed = TRUE
  )

  # Process results (same as your existing code)
  failed_urls <- character(0L)
  error_urls <- character(0L)

  for (res in all_results) {
    if (!is.null(res$error)) {
      error_urls <- c(error_urls, paste(res$url, "->", res$error))
    } else if (res$status != 200L) {
      failed_urls <- c(failed_urls, paste(res$url, "-> HTTP", res$status))
    }
  }

  # Report and assert (same as existing)
  if (length(error_urls) > 0L) {
    cat("URLs with errors:\n")
    cat(paste(error_urls, collapse = "\n"), "\n")
  }

  if (length(failed_urls) > 0L) {
    cat("URLs with non-200 status:\n")
    cat(paste(failed_urls, collapse = "\n"), "\n")
  }

  expect_length(error_urls, 0L)
  expect_length(failed_urls, 0L)
})
