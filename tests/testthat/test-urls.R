library(curl)

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

# Split into batches to avoid overwhelming servers
batch_size <- 10L
delay_between_batches <- 2L # seconds

# Helper to check a single URL
check_url <- function(this_url) {
  is_s3 <- grepl("s3[-.]", this_url)
  host <- sub("^https?://([^/]+).*", "\\1", this_url)

  if (!is_s3) {
    resolved <- tryCatch(nslookup(host, error = FALSE), error = function(e) {
      NULL
    })
    if (is.null(resolved) || length(resolved) == 0L) {
      return(list(
        url = url,
        status = NA,
        error = paste("DNS resolution failed for", host)
      ))
    }
  }

  result <- tryCatch(
    curl_fetch_memory(this_url, handle = set_curl_handle()),
    error = function(e) e
  )

  if (inherits(result, "error")) {
    return(list(url = this_url, status = NA, error = conditionMessage(result)))
  } else {
    return(list(url = this_url, status = result$status_code, error = NULL))
  }
}

# Run in batches
test_that("All known ABARES/ABS URLs resolve and return HTTP 200", {
  skip_if_offline()

  for (i in seq(1L, length(urls_to_test), by = batch_size)) {
    batch <- urls_to_test[i:min(i + batch_size - 1L, length(urls_to_test))]
    results <- lapply(batch, check_url)

    for (res in results) {
      if (!is.null(res$error)) {
        fail(paste("Failed to fetch URL:", res$url, "\nError:", res$error))
      } else {
        expect_equal(
          res$status,
          200,
          info = paste(
            "Unexpected HTTP status",
            res$status,
            "for URL:",
            res$url
          )
        )
      }
    }

    if (i + batch_size - 1L < length(urls_to_test)) {
      Sys.sleep(delay_between_batches)
    }
  }
})
