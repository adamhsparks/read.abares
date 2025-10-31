# /inst/tools/make_agfd_tiny_nc.R
# Produces tiny valid NetCDF files for unit tests (no ABARES data).
# Requires: ncdf4

fs::dir_create(here::here(), "/inst/tools/historical_climate_prices_fixed")
library(ncdf4)

make_one <- function(path, seed = 2022) {
  set.seed(seed)
  # 2×2 coordinates (approx SE QLD)
  lat_vals <- c(-27.50, -27.00)
  lon_vals <- c(152.80, 153.00)

  dim_lat <- ncdim_def("lat", "degrees_north", lat_vals)
  dim_lon <- ncdim_def("lon", "degrees_east", lon_vals)

  # Two AGFD-style variables with CF-compliant units
  var_profit <- ncvar_def(
    "FBP_fbp_hat_ha",
    "USD ha-1",
    list(dim_lon, dim_lat),
    missval = -9999,
    prec = "float"
  )
  var_receipts <- ncvar_def(
    "R_total_hat_ha",
    "USD ha-1",
    list(dim_lon, dim_lat),
    missval = -9999,
    prec = "float"
  )

  nc <- nc_create(path, vars = list(var_profit, var_receipts))

  # Fill with synthetic values
  ncvar_put(nc, var_profit, matrix(round(runif(4, 100, 500), 2), 2, 2))
  ncvar_put(nc, var_receipts, matrix(round(runif(4, 200, 600), 2), 2, 2))

  # Minimal global attributes
  ncatt_put(nc, 0, "title", "AGFD tiny test file (CRAN-safe)")
  ncatt_put(nc, 0, "source", "Synthetic unit-test data; not ABARES")

  nc_close(nc)
}

make_one(
  here::here(
    "inst/tools/historical_climate_prices_fixed/f2022.c2022.p2022.t2022.nc"
  ),
  seed = 2022
)
make_one(
  here::here(
    "inst/tools/historical_climate_prices_fixed/f2021.c2021.p2021.t2021.nc"
  ),
  seed = 2021
)

message("Created tiny NetCDF files in historical_climate_prices_fixed/")

# Now zip the "historical_climate_prices_fixed" folder for use as a fixture and
# place in inst/extdata/ with the name, "agfd_fixture_valid_nc.zip"
