# R script to create a smaller subset of a large spatial zip file for testing.
x <- fs::path_temp("clum_commodities.zip")

read.abares:::.retry_download(
  url = "https://data.gov.au/data/dataset/8af26be3-da5d-4255-b554-f615e950e46d/resource/b216cf90-f4f0-4d88-980f-af7d1ad746cb/download/clum_commodities_2023.zip",
  dest = x
)
clum_commodities <- sf::st_read(
  dsn = sprintf(
    "/vsizip//%s/CLUM_Commodities_2023/CLUM_Commodities_2023.shp",
    x
  )
)

clum_subset <- filter(clum_commodities, State == "ACT")

outdir <- fs::path_temp("clum_commodities_subset")

st_write(
  clum_subset,
  outdir,
  driver = "ESRI Shapefile",
  append = FALSE
)

files_to_zip <- list.files(outdir, full.names = TRUE)
zip(
  "inst/extdata/clum_commodities_2023_subset.zip",
  files = files_to_zip,
  flags = "-j"
)

# Clean up temporary files
unlink(x)
unlink(outdir, recursive = TRUE)
unlink(, recursive = TRUE)
