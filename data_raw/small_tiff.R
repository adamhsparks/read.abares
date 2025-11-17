# R script to create a smaller subset of a large GeoTIFF file for testing.

library(terra)

# 1. Download the large zip file
url <- "https://www.agriculture.gov.au/sites/default/files/documents/clum_50m_2023_v2.zip"
temp_dir <- tempdir()
dest_zip <- file.path(temp_dir, "clum_50m_2023_v2.zip")
dest_unzip <- file.path(temp_dir, "clum_data")

# Create a directory for the unzipped files
if (!dir.exists(dest_unzip)) {
  dir.create(dest_unzip)
}

# Download the file
message("Downloading large zip file...")
download.file(url, dest_zip, mode = "wb")

# 2. Unzip the file
message("Unzipping file...")
unzip(dest_zip, exdir = dest_unzip)

# Find the .tif file in the unzipped contents
tif_file <- list.files(
  dest_unzip,
  pattern = "\\.tif$",
  full.names = TRUE,
  recursive = TRUE
)
if (length(tif_file) == 0) {
  stop("No .tif file found in the unzipped folder.")
}

message(paste("Reading GeoTIFF:", basename(tif_file[1])))
clum_raster <- rast(tif_file[1])

# 3. Define a small extent to crop
# We will crop to the area around Christmas Island.
# The extent is defined by xmin, xmax, ymin, ymax in the raster's CRS.
# This raster uses GDA94 / Australian Albers (EPSG:3577).
# Let's define a small box in the middle of Australia for simplicity,
# as projecting lat/lon for Christmas Island is more complex.
# This extent represents a 50km x 50km box.
albers_extent <- ext(1.e6, 1.05e6, -3e6, -2.95e6)

# 4. Crop the raster
message("Cropping raster...")
clum_subset <- crop(clum_raster, albers_extent)

# 5. Write the subset to a new GeoTIFF file
output_tif <- "clum_subset.tif"
message(paste("Writing subset to", output_tif))
writeRaster(clum_subset, output_tif, overwrite = TRUE)

# 6. Zip the new GeoTIFF file
output_zip <- "clum_subset.zip"
zip(output_zip, files = output_tif)

message(paste("Successfully created", output_zip, "in your working directory."))

# Clean up temporary files
unlink(dest_zip)
unlink(dest_unzip, recursive = TRUE)
unlink(output_tif)
