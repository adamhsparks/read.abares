# Package index

## AAGIS Regions

Fetch and read the ABARES Agricultural and Grazing Industries Survey
(AAGIS) regions shapefile

- [`read_aagis_regions()`](https://adamhsparks.github.io/read.abares/reference/read_aagis_regions.md)
  : Read ABARES' "Australian Agricultural and Grazing Industries Survey"
  (AAGIS) Region Mapping Files

## ABS data

Fetch and read agricultural data provided by the Australian Bureau of
Statistics

- [`read_abs_broadacre_data()`](https://adamhsparks.github.io/read.abares/reference/read_abs_broadacre_data.md)
  : Get ABS' Broadacre Crops Production and Value by Australia, State
  and Territory by Year
- [`read_abs_horticulture_data()`](https://adamhsparks.github.io/read.abares/reference/read_abs_horticulture_data.md)
  : Get ABS' Horticulture Crops Production and Value by Australia, State
  and Territory by Year
- [`read_abs_livestock_data()`](https://adamhsparks.github.io/read.abares/reference/read_abs_livestock_data.md)
  : Read ABS' Livestock Production and Value by Australia, State and
  Territory by Year

## AGFD

Fetch and read the Australian Gridded Farm Data (AGFD) NetCDF files

- [`read_agfd_dt()`](https://adamhsparks.github.io/read.abares/reference/read_agfd_dt.md)
  : Read ABARES' "Australian Gridded Farm Data" (AGFD) NCDF Files as a
  data.table Object
- [`read_agfd_stars()`](https://adamhsparks.github.io/read.abares/reference/read_agfd_stars.md)
  : Read ABARES' "Australian Gridded Farm Data" (AGFD) NCDF files with
  stars
- [`read_agfd_terra()`](https://adamhsparks.github.io/read.abares/reference/read_agfd_terra.md)
  : Read ABARES' "Australian Gridded Farm Data" (AGFD) NCDF Files with
  terra
- [`read_agfd_tidync()`](https://adamhsparks.github.io/read.abares/reference/read_agfd_tidync.md)
  : Read ABARES' "Australian Gridded Farm Data" (AGFD) NCDF Files with
  tidync

## Estimates

Fetch and read the ABARES Estimates data

- [`read_estimates_by_performance_category()`](https://adamhsparks.github.io/read.abares/reference/read_estimates_by_performance_category.md)
  [`read_est_by_perf_cat()`](https://adamhsparks.github.io/read.abares/reference/read_estimates_by_performance_category.md)
  : Read ABARES' "Estimates by Performance"
- [`read_estimates_by_size()`](https://adamhsparks.github.io/read.abares/reference/read_estimates_by_size.md)
  [`read_est_by_size()`](https://adamhsparks.github.io/read.abares/reference/read_estimates_by_size.md)
  : Read ABARES' "Estimates by Size"
- [`read_historical_national_estimates()`](https://adamhsparks.github.io/read.abares/reference/read_historical_national_estimates.md)
  [`read_hist_nat_est()`](https://adamhsparks.github.io/read.abares/reference/read_historical_national_estimates.md)
  : Read ABARES' "Historical National Estimates"
- [`read_historical_regional_estimates()`](https://adamhsparks.github.io/read.abares/reference/read_historical_regional_estimates.md)
  [`read_hist_reg_est()`](https://adamhsparks.github.io/read.abares/reference/read_historical_regional_estimates.md)
  : Read ABARES' "Historical Regional Estimates"
- [`read_historical_state_estimates()`](https://adamhsparks.github.io/read.abares/reference/read_historical_state_estimates.md)
  [`read_hist_st_est()`](https://adamhsparks.github.io/read.abares/reference/read_historical_state_estimates.md)
  : Read ABARES' "Historical State Estimates"

## Historical Agricultural Forecast Database

Fetch and read the agricultural forecast database

- [`read_historical_forecast_database()`](https://adamhsparks.github.io/read.abares/reference/read_historical_forecast_database.md)
  [`read_historical_forecast()`](https://adamhsparks.github.io/read.abares/reference/read_historical_forecast_database.md)
  : Read ABARES' "Historical Forecast Database"

## Land Use

National (NLUM) and catchment (CLUM) level land use data

### Fetch and read land use related GeoTIFF files

- [`read_clum_stars()`](https://adamhsparks.github.io/read.abares/reference/read_clum_stars.md)
  : Read ABARES' Catchment Scale "Land Use of Australia" Data Using
  Stars
- [`read_clum_terra()`](https://adamhsparks.github.io/read.abares/reference/read_clum_terra.md)
  : Read ABARES' Catchment Scale "Land Use of Australia" GeoTIFFs Using
  terra
- [`read_nlum_stars()`](https://adamhsparks.github.io/read.abares/reference/read_nlum_stars.md)
  : Read ABARES' National Scale "Land Use of Australia" Data Using stars
- [`read_nlum_terra()`](https://adamhsparks.github.io/read.abares/reference/read_nlum_terra.md)
  : Read ABARES' National Scale "Land Use of Australia" Data Using terra

### CLUM Commodities

Fetch and read the catchment level commodities shapefile

- [`read_clum_commodities()`](https://adamhsparks.github.io/read.abares/reference/read_clum_commodities.md)
  : Read ABARES' Catchment Scale "Land Use of Australia" Commodities
  Shapefile

### Meta

Information about the CLUM and NLUM data sets

- [`view_clum_metadata_pdf()`](https://adamhsparks.github.io/read.abares/reference/view_clum_metadata_pdf.md)
  : Displays the PDF Metadata for ABARES' "Catchment Land Use" (CLUM)
  Raster Files in a Native Viewer
- [`view_nlum_metadata_pdf()`](https://adamhsparks.github.io/read.abares/reference/view_nlum_metadata_pdf.md)
  : Displays PDF Metadata for ABARES' "National Land Use" (NLUM) Raster
  Files in a Native Viewer

## Topsoil Thickness

Soil Thickness for Australian areas of intensive agriculture of Layer 1
(A Horizon - top-soil) (derived from soil mapping)

### Fetch and read soil thickness GeoTIFF files

- [`read_topsoil_thickness_stars()`](https://adamhsparks.github.io/read.abares/reference/read_topsoil_thickness_stars.md)
  : Read ABARES' "Soil Thickness for Australian Areas of Intensive
  Agriculture of Layer 1" with stars
- [`read_topsoil_thickness_terra()`](https://adamhsparks.github.io/read.abares/reference/read_topsoil_thickness_terra.md)
  : Read ABARES' "Soil Thickness for Australian Areas of Intensive
  Agriculture of Layer 1" with terra

### Meta

View metadata associated with soil thickness data

- [`print_topsoil_thickness_metadata()`](https://adamhsparks.github.io/read.abares/reference/print_topsoil_thickness_metadata.md)
  : Displays the text file Metadata for ABARES' Topsoil Thickness for
  "Australian Areas of Intensive Agriculture of Layer 1"

## Trade

Fetch and read ABARES Australian agricultural export data

- [`read_abares_trade()`](https://adamhsparks.github.io/read.abares/reference/read_abares_trade.md)
  : Read Data from the ABARES Trade Dashboard
- [`read_abares_trade_regions()`](https://adamhsparks.github.io/read.abares/reference/read_abares_trade_regions.md)
  : Read "Trade Data Regions" from the ABARES Trade Dashboard

## {read.abares} Options

Get or set package options

- [`read.abares_options()`](https://adamhsparks.github.io/read.abares/reference/read.abares_options.md)
  : Get or Set read.abares Options
