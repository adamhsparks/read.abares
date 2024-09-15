
<!-- README.md is generated from README.Rmd. Please edit that file -->

# {abares}: Simple downloading and importing of ABARES Data

An R package for automated downloading, parsing and formatting of data
from the Australian Bureau of Agricultural and Resource Economics and
Sciences (ABARES) including the:

- [Historical National Estimates, Historical State Estimates, Historical
  Regional Estimates, Estimates by Size, Estimates by Performance
  Category](https://www.agriculture.gov.au/abares/data/farm-data-portal#data-download);
- the [Australian Gridded Farm Data (AGFD)
  set](https://www.agriculture.gov.au/abares/research-topics/surveys/farm-survey-data/australian-gridded-farm-data);
  and the - [Australian Agricultural and Grazing Industries Survey
  (AAGIS)](https://www.agriculture.gov.au/abares/research-topics/surveys/farm-survey-data)
  region mapping files.

The files are freely available as CSV files, zip archives of NetCDF
files or a zip archive of a geospatial shape file. {abares} facilitates
downloading, caching and importing these files in your R session with
your choice of the class of the resulting object(s).

## Get Started

### Installation

{abares} is not available through CRAN (yet). But you can install it
like so:

``` r
if (!require("remotes"))
  install.packages("remotes")
remotes::install_git("https://codeberg.org/adamhsparks/abares")
```

### Using {abares}

#### Estimates

You can download the CSV files directly in your R session as illustrated
below.

``` r
library(abares)

get_hist_nat_est()
#>                                 Variable  Year  Value   RSE      Industry
#>                                   <char> <int>  <num> <int>        <char>
#>     1: AI stud fees and herd testing ($)  1990    790    39 All Broadacre
#>     2:           Accounting services ($)  1990   2850     4 All Broadacre
#>     3:             Advisory services ($)  1990    280    37 All Broadacre
#>     4:        Age of owner manager (yrs)  1990     53     1 All Broadacre
#>     5:               Age of spouse (yrs)  1990     49     1 All Broadacre
#>    ---                                                                   
#> 30059:                Wheat receipts ($)  2022  11100    40    Sheep-Beef
#> 30060:                    Wheat sold (t)  2022     32    44    Sheep-Beef
#> 30061:            Wool cut per head (kg)  2022      4     5    Sheep-Beef
#> 30062:                Wool produced (kg)  2022  12294    31    Sheep-Beef
#> 30063:                 Wool receipts ($)  2022 150100    41    Sheep-Beef

get_hist_sta_est()
#>                                  Variable  Year   Value   RSE             State
#>                                    <char> <int>   <num> <int>            <char>
#>      1: AI stud fees and herd testing ($)  1990   210.0   118   New South Wales
#>      2:           Accounting services ($)  1990  2740.0     7   New South Wales
#>      3:             Advisory services ($)  1990   190.0   105   New South Wales
#>      4:        Age of owner manager (yrs)  1990    55.0     2   New South Wales
#>      5:               Age of spouse (yrs)  1990    52.0     2   New South Wales
#>     ---                                                                        
#> 184454:                Wheat receipts ($)  2022     0.0    NA Western Australia
#> 184455:                    Wheat sold (t)  2022     0.0    NA Western Australia
#> 184456:            Wool cut per head (kg)  2022     3.5     5 Western Australia
#> 184457:                Wool produced (kg)  2022  9126.0    22 Western Australia
#> 184458:                 Wool receipts ($)  2022 84500.0    22 Western Australia
#>              Industry
#>                <char>
#>      1: All Broadacre
#>      2: All Broadacre
#>      3: All Broadacre
#>      4: All Broadacre
#>      5: All Broadacre
#>     ---              
#> 184454:    Sheep-Beef
#> 184455:    Sheep-Beef
#> 184456:    Sheep-Beef
#> 184457:    Sheep-Beef
#> 184458:    Sheep-Beef

get_hist_reg_est()
#>                                  Variable  Year    ABARES region Value   RSE
#>                                    <char> <int>           <char> <num> <int>
#>      1: AI stud fees and herd testing ($)  1990 NSW Central West    90    68
#>      2:           Accounting services ($)  1990 NSW Central West  2420    19
#>      3:             Advisory services ($)  1990 NSW Central West   120    80
#>      4:        Age of owner manager (yrs)  1990 NSW Central West    57     5
#>      5:               Age of spouse (yrs)  1990 NSW Central West    51     4
#>     ---                                                                     
#> 142796:                Wheat receipts ($)  2022 WA The Kimberley     0    NA
#> 142797:                    Wheat sold (t)  2022 WA The Kimberley     0    NA
#> 142798:            Wool cut per head (kg)  2022 WA The Kimberley    NA    NA
#> 142799:                Wool produced (kg)  2022 WA The Kimberley     0    NA
#> 142800:                 Wool receipts ($)  2022 WA The Kimberley     0    NA
```

#### AGFD Data

You can download files and pipe directly into the class object that you
desire for the AGFD data.

``` r
library(abares)

## A list of {stars} objects
sta <- get_agfd(cache = TRUE) |>
  read_agfd_stars() |> 
  head()
#> no 'var' specified, using farmno, R_total_hat_ha, C_total_hat_ha, FBP_fci_hat_ha, FBP_fbp_hat_ha, A_wheat_hat_ha, H_wheat_dot_hat, A_barley_hat_ha, H_barley_dot_hat, A_sorghum_hat_ha, H_sorghum_dot_hat, A_oilseeds_hat_ha, H_oilseeds_dot_hat, R_wheat_hat_ha, R_sorghum_hat_ha, R_oilseeds_hat_ha, R_barley_hat_ha, Q_wheat_hat_ha, Q_barley_hat_ha, Q_sorghum_hat_ha, Q_oilseeds_hat_ha, S_wheat_cl_hat_ha, S_sheep_cl_hat_ha, S_sheep_births_hat_ha, S_sheep_deaths_hat_ha, S_beef_cl_hat_ha, S_beef_births_hat_ha, S_beef_deaths_hat_ha, Q_beef_hat_ha, Q_sheep_hat_ha, Q_lamb_hat_ha, R_beef_hat_ha, R_sheep_hat_ha, R_lamb_hat_ha, C_fodder_hat_ha, C_fert_hat_ha, C_fuel_hat_ha, C_chem_hat_ha, A_total_cropped_ha, FBP_pfe_hat_ha, farmland_per_cell
#> other available variables:
#>  lon, lat
#> Will return stars object with 612226 cells.
#> No projection information found in nc file. 
#>  Coordinate variable units found to be degrees, 
#>  assuming WGS84 Lat/Lon.
#> no 'var' specified, using farmno, R_total_hat_ha, C_total_hat_ha, FBP_fci_hat_ha, FBP_fbp_hat_ha, A_wheat_hat_ha, H_wheat_dot_hat, A_barley_hat_ha, H_barley_dot_hat, A_sorghum_hat_ha, H_sorghum_dot_hat, A_oilseeds_hat_ha, H_oilseeds_dot_hat, R_wheat_hat_ha, R_sorghum_hat_ha, R_oilseeds_hat_ha, R_barley_hat_ha, Q_wheat_hat_ha, Q_barley_hat_ha, Q_sorghum_hat_ha, Q_oilseeds_hat_ha, S_wheat_cl_hat_ha, S_sheep_cl_hat_ha, S_sheep_births_hat_ha, S_sheep_deaths_hat_ha, S_beef_cl_hat_ha, S_beef_births_hat_ha, S_beef_deaths_hat_ha, Q_beef_hat_ha, Q_sheep_hat_ha, Q_lamb_hat_ha, R_beef_hat_ha, R_sheep_hat_ha, R_lamb_hat_ha, C_fodder_hat_ha, C_fert_hat_ha, C_fuel_hat_ha, C_chem_hat_ha, A_total_cropped_ha, FBP_pfe_hat_ha, farmland_per_cell
#> other available variables:
#>  lon, lat
#> Will return stars object with 612226 cells.
#> No projection information found in nc file. 
#>  Coordinate variable units found to be degrees, 
#>  assuming WGS84 Lat/Lon.
#> no 'var' specified, using farmno, R_total_hat_ha, C_total_hat_ha, FBP_fci_hat_ha, FBP_fbp_hat_ha, A_wheat_hat_ha, H_wheat_dot_hat, A_barley_hat_ha, H_barley_dot_hat, A_sorghum_hat_ha, H_sorghum_dot_hat, A_oilseeds_hat_ha, H_oilseeds_dot_hat, R_wheat_hat_ha, R_sorghum_hat_ha, R_oilseeds_hat_ha, R_barley_hat_ha, Q_wheat_hat_ha, Q_barley_hat_ha, Q_sorghum_hat_ha, Q_oilseeds_hat_ha, S_wheat_cl_hat_ha, S_sheep_cl_hat_ha, S_sheep_births_hat_ha, S_sheep_deaths_hat_ha, S_beef_cl_hat_ha, S_beef_births_hat_ha, S_beef_deaths_hat_ha, Q_beef_hat_ha, Q_sheep_hat_ha, Q_lamb_hat_ha, R_beef_hat_ha, R_sheep_hat_ha, R_lamb_hat_ha, C_fodder_hat_ha, C_fert_hat_ha, C_fuel_hat_ha, C_chem_hat_ha, A_total_cropped_ha, FBP_pfe_hat_ha, farmland_per_cell
#> other available variables:
#>  lon, lat
#> Will return stars object with 612226 cells.
#> No projection information found in nc file. 
#>  Coordinate variable units found to be degrees, 
#>  assuming WGS84 Lat/Lon.
#> no 'var' specified, using farmno, R_total_hat_ha, C_total_hat_ha, FBP_fci_hat_ha, FBP_fbp_hat_ha, A_wheat_hat_ha, H_wheat_dot_hat, A_barley_hat_ha, H_barley_dot_hat, A_sorghum_hat_ha, H_sorghum_dot_hat, A_oilseeds_hat_ha, H_oilseeds_dot_hat, R_wheat_hat_ha, R_sorghum_hat_ha, R_oilseeds_hat_ha, R_barley_hat_ha, Q_wheat_hat_ha, Q_barley_hat_ha, Q_sorghum_hat_ha, Q_oilseeds_hat_ha, S_wheat_cl_hat_ha, S_sheep_cl_hat_ha, S_sheep_births_hat_ha, S_sheep_deaths_hat_ha, S_beef_cl_hat_ha, S_beef_births_hat_ha, S_beef_deaths_hat_ha, Q_beef_hat_ha, Q_sheep_hat_ha, Q_lamb_hat_ha, R_beef_hat_ha, R_sheep_hat_ha, R_lamb_hat_ha, C_fodder_hat_ha, C_fert_hat_ha, C_fuel_hat_ha, C_chem_hat_ha, A_total_cropped_ha, FBP_pfe_hat_ha, farmland_per_cell
#> other available variables:
#>  lon, lat
#> Will return stars object with 612226 cells.
#> No projection information found in nc file. 
#>  Coordinate variable units found to be degrees, 
#>  assuming WGS84 Lat/Lon.
#> no 'var' specified, using farmno, R_total_hat_ha, C_total_hat_ha, FBP_fci_hat_ha, FBP_fbp_hat_ha, A_wheat_hat_ha, H_wheat_dot_hat, A_barley_hat_ha, H_barley_dot_hat, A_sorghum_hat_ha, H_sorghum_dot_hat, A_oilseeds_hat_ha, H_oilseeds_dot_hat, R_wheat_hat_ha, R_sorghum_hat_ha, R_oilseeds_hat_ha, R_barley_hat_ha, Q_wheat_hat_ha, Q_barley_hat_ha, Q_sorghum_hat_ha, Q_oilseeds_hat_ha, S_wheat_cl_hat_ha, S_sheep_cl_hat_ha, S_sheep_births_hat_ha, S_sheep_deaths_hat_ha, S_beef_cl_hat_ha, S_beef_births_hat_ha, S_beef_deaths_hat_ha, Q_beef_hat_ha, Q_sheep_hat_ha, Q_lamb_hat_ha, R_beef_hat_ha, R_sheep_hat_ha, R_lamb_hat_ha, C_fodder_hat_ha, C_fert_hat_ha, C_fuel_hat_ha, C_chem_hat_ha, A_total_cropped_ha, FBP_pfe_hat_ha, farmland_per_cell
#> other available variables:
#>  lon, lat
#> Will return stars object with 612226 cells.
#> No projection information found in nc file. 
#>  Coordinate variable units found to be degrees, 
#>  assuming WGS84 Lat/Lon.
#> no 'var' specified, using farmno, R_total_hat_ha, C_total_hat_ha, FBP_fci_hat_ha, FBP_fbp_hat_ha, A_wheat_hat_ha, H_wheat_dot_hat, A_barley_hat_ha, H_barley_dot_hat, A_sorghum_hat_ha, H_sorghum_dot_hat, A_oilseeds_hat_ha, H_oilseeds_dot_hat, R_wheat_hat_ha, R_sorghum_hat_ha, R_oilseeds_hat_ha, R_barley_hat_ha, Q_wheat_hat_ha, Q_barley_hat_ha, Q_sorghum_hat_ha, Q_oilseeds_hat_ha, S_wheat_cl_hat_ha, S_sheep_cl_hat_ha, S_sheep_births_hat_ha, S_sheep_deaths_hat_ha, S_beef_cl_hat_ha, S_beef_births_hat_ha, S_beef_deaths_hat_ha, Q_beef_hat_ha, Q_sheep_hat_ha, Q_lamb_hat_ha, R_beef_hat_ha, R_sheep_hat_ha, R_lamb_hat_ha, C_fodder_hat_ha, C_fert_hat_ha, C_fuel_hat_ha, C_chem_hat_ha, A_total_cropped_ha, FBP_pfe_hat_ha, farmland_per_cell
#> other available variables:
#>  lon, lat
#> Will return stars object with 612226 cells.
#> No projection information found in nc file. 
#>  Coordinate variable units found to be degrees, 
#>  assuming WGS84 Lat/Lon.
#> no 'var' specified, using farmno, R_total_hat_ha, C_total_hat_ha, FBP_fci_hat_ha, FBP_fbp_hat_ha, A_wheat_hat_ha, H_wheat_dot_hat, A_barley_hat_ha, H_barley_dot_hat, A_sorghum_hat_ha, H_sorghum_dot_hat, A_oilseeds_hat_ha, H_oilseeds_dot_hat, R_wheat_hat_ha, R_sorghum_hat_ha, R_oilseeds_hat_ha, R_barley_hat_ha, Q_wheat_hat_ha, Q_barley_hat_ha, Q_sorghum_hat_ha, Q_oilseeds_hat_ha, S_wheat_cl_hat_ha, S_sheep_cl_hat_ha, S_sheep_births_hat_ha, S_sheep_deaths_hat_ha, S_beef_cl_hat_ha, S_beef_births_hat_ha, S_beef_deaths_hat_ha, Q_beef_hat_ha, Q_sheep_hat_ha, Q_lamb_hat_ha, R_beef_hat_ha, R_sheep_hat_ha, R_lamb_hat_ha, C_fodder_hat_ha, C_fert_hat_ha, C_fuel_hat_ha, C_chem_hat_ha, A_total_cropped_ha, FBP_pfe_hat_ha, farmland_per_cell
#> other available variables:
#>  lon, lat
#> Will return stars object with 612226 cells.
#> No projection information found in nc file. 
#>  Coordinate variable units found to be degrees, 
#>  assuming WGS84 Lat/Lon.
#> no 'var' specified, using farmno, R_total_hat_ha, C_total_hat_ha, FBP_fci_hat_ha, FBP_fbp_hat_ha, A_wheat_hat_ha, H_wheat_dot_hat, A_barley_hat_ha, H_barley_dot_hat, A_sorghum_hat_ha, H_sorghum_dot_hat, A_oilseeds_hat_ha, H_oilseeds_dot_hat, R_wheat_hat_ha, R_sorghum_hat_ha, R_oilseeds_hat_ha, R_barley_hat_ha, Q_wheat_hat_ha, Q_barley_hat_ha, Q_sorghum_hat_ha, Q_oilseeds_hat_ha, S_wheat_cl_hat_ha, S_sheep_cl_hat_ha, S_sheep_births_hat_ha, S_sheep_deaths_hat_ha, S_beef_cl_hat_ha, S_beef_births_hat_ha, S_beef_deaths_hat_ha, Q_beef_hat_ha, Q_sheep_hat_ha, Q_lamb_hat_ha, R_beef_hat_ha, R_sheep_hat_ha, R_lamb_hat_ha, C_fodder_hat_ha, C_fert_hat_ha, C_fuel_hat_ha, C_chem_hat_ha, A_total_cropped_ha, FBP_pfe_hat_ha, farmland_per_cell
#> other available variables:
#>  lon, lat
#> Will return stars object with 612226 cells.
#> No projection information found in nc file. 
#>  Coordinate variable units found to be degrees, 
#>  assuming WGS84 Lat/Lon.
#> no 'var' specified, using farmno, R_total_hat_ha, C_total_hat_ha, FBP_fci_hat_ha, FBP_fbp_hat_ha, A_wheat_hat_ha, H_wheat_dot_hat, A_barley_hat_ha, H_barley_dot_hat, A_sorghum_hat_ha, H_sorghum_dot_hat, A_oilseeds_hat_ha, H_oilseeds_dot_hat, R_wheat_hat_ha, R_sorghum_hat_ha, R_oilseeds_hat_ha, R_barley_hat_ha, Q_wheat_hat_ha, Q_barley_hat_ha, Q_sorghum_hat_ha, Q_oilseeds_hat_ha, S_wheat_cl_hat_ha, S_sheep_cl_hat_ha, S_sheep_births_hat_ha, S_sheep_deaths_hat_ha, S_beef_cl_hat_ha, S_beef_births_hat_ha, S_beef_deaths_hat_ha, Q_beef_hat_ha, Q_sheep_hat_ha, Q_lamb_hat_ha, R_beef_hat_ha, R_sheep_hat_ha, R_lamb_hat_ha, C_fodder_hat_ha, C_fert_hat_ha, C_fuel_hat_ha, C_chem_hat_ha, A_total_cropped_ha, FBP_pfe_hat_ha, farmland_per_cell
#> other available variables:
#>  lon, lat
#> Will return stars object with 612226 cells.
#> No projection information found in nc file. 
#>  Coordinate variable units found to be degrees, 
#>  assuming WGS84 Lat/Lon.
#> no 'var' specified, using farmno, R_total_hat_ha, C_total_hat_ha, FBP_fci_hat_ha, FBP_fbp_hat_ha, A_wheat_hat_ha, H_wheat_dot_hat, A_barley_hat_ha, H_barley_dot_hat, A_sorghum_hat_ha, H_sorghum_dot_hat, A_oilseeds_hat_ha, H_oilseeds_dot_hat, R_wheat_hat_ha, R_sorghum_hat_ha, R_oilseeds_hat_ha, R_barley_hat_ha, Q_wheat_hat_ha, Q_barley_hat_ha, Q_sorghum_hat_ha, Q_oilseeds_hat_ha, S_wheat_cl_hat_ha, S_sheep_cl_hat_ha, S_sheep_births_hat_ha, S_sheep_deaths_hat_ha, S_beef_cl_hat_ha, S_beef_births_hat_ha, S_beef_deaths_hat_ha, Q_beef_hat_ha, Q_sheep_hat_ha, Q_lamb_hat_ha, R_beef_hat_ha, R_sheep_hat_ha, R_lamb_hat_ha, C_fodder_hat_ha, C_fert_hat_ha, C_fuel_hat_ha, C_chem_hat_ha, A_total_cropped_ha, FBP_pfe_hat_ha, farmland_per_cell
#> other available variables:
#>  lon, lat
#> Will return stars object with 612226 cells.
#> No projection information found in nc file. 
#>  Coordinate variable units found to be degrees, 
#>  assuming WGS84 Lat/Lon.
#> no 'var' specified, using farmno, R_total_hat_ha, C_total_hat_ha, FBP_fci_hat_ha, FBP_fbp_hat_ha, A_wheat_hat_ha, H_wheat_dot_hat, A_barley_hat_ha, H_barley_dot_hat, A_sorghum_hat_ha, H_sorghum_dot_hat, A_oilseeds_hat_ha, H_oilseeds_dot_hat, R_wheat_hat_ha, R_sorghum_hat_ha, R_oilseeds_hat_ha, R_barley_hat_ha, Q_wheat_hat_ha, Q_barley_hat_ha, Q_sorghum_hat_ha, Q_oilseeds_hat_ha, S_wheat_cl_hat_ha, S_sheep_cl_hat_ha, S_sheep_births_hat_ha, S_sheep_deaths_hat_ha, S_beef_cl_hat_ha, S_beef_births_hat_ha, S_beef_deaths_hat_ha, Q_beef_hat_ha, Q_sheep_hat_ha, Q_lamb_hat_ha, R_beef_hat_ha, R_sheep_hat_ha, R_lamb_hat_ha, C_fodder_hat_ha, C_fert_hat_ha, C_fuel_hat_ha, C_chem_hat_ha, A_total_cropped_ha, FBP_pfe_hat_ha, farmland_per_cell
#> other available variables:
#>  lon, lat
#> Will return stars object with 612226 cells.
#> No projection information found in nc file. 
#>  Coordinate variable units found to be degrees, 
#>  assuming WGS84 Lat/Lon.
#> no 'var' specified, using farmno, R_total_hat_ha, C_total_hat_ha, FBP_fci_hat_ha, FBP_fbp_hat_ha, A_wheat_hat_ha, H_wheat_dot_hat, A_barley_hat_ha, H_barley_dot_hat, A_sorghum_hat_ha, H_sorghum_dot_hat, A_oilseeds_hat_ha, H_oilseeds_dot_hat, R_wheat_hat_ha, R_sorghum_hat_ha, R_oilseeds_hat_ha, R_barley_hat_ha, Q_wheat_hat_ha, Q_barley_hat_ha, Q_sorghum_hat_ha, Q_oilseeds_hat_ha, S_wheat_cl_hat_ha, S_sheep_cl_hat_ha, S_sheep_births_hat_ha, S_sheep_deaths_hat_ha, S_beef_cl_hat_ha, S_beef_births_hat_ha, S_beef_deaths_hat_ha, Q_beef_hat_ha, Q_sheep_hat_ha, Q_lamb_hat_ha, R_beef_hat_ha, R_sheep_hat_ha, R_lamb_hat_ha, C_fodder_hat_ha, C_fert_hat_ha, C_fuel_hat_ha, C_chem_hat_ha, A_total_cropped_ha, FBP_pfe_hat_ha, farmland_per_cell
#> other available variables:
#>  lon, lat
#> Will return stars object with 612226 cells.
#> No projection information found in nc file. 
#>  Coordinate variable units found to be degrees, 
#>  assuming WGS84 Lat/Lon.
#> no 'var' specified, using farmno, R_total_hat_ha, C_total_hat_ha, FBP_fci_hat_ha, FBP_fbp_hat_ha, A_wheat_hat_ha, H_wheat_dot_hat, A_barley_hat_ha, H_barley_dot_hat, A_sorghum_hat_ha, H_sorghum_dot_hat, A_oilseeds_hat_ha, H_oilseeds_dot_hat, R_wheat_hat_ha, R_sorghum_hat_ha, R_oilseeds_hat_ha, R_barley_hat_ha, Q_wheat_hat_ha, Q_barley_hat_ha, Q_sorghum_hat_ha, Q_oilseeds_hat_ha, S_wheat_cl_hat_ha, S_sheep_cl_hat_ha, S_sheep_births_hat_ha, S_sheep_deaths_hat_ha, S_beef_cl_hat_ha, S_beef_births_hat_ha, S_beef_deaths_hat_ha, Q_beef_hat_ha, Q_sheep_hat_ha, Q_lamb_hat_ha, R_beef_hat_ha, R_sheep_hat_ha, R_lamb_hat_ha, C_fodder_hat_ha, C_fert_hat_ha, C_fuel_hat_ha, C_chem_hat_ha, A_total_cropped_ha, FBP_pfe_hat_ha, farmland_per_cell
#> other available variables:
#>  lon, lat
#> Will return stars object with 612226 cells.
#> No projection information found in nc file. 
#>  Coordinate variable units found to be degrees, 
#>  assuming WGS84 Lat/Lon.
#> no 'var' specified, using farmno, R_total_hat_ha, C_total_hat_ha, FBP_fci_hat_ha, FBP_fbp_hat_ha, A_wheat_hat_ha, H_wheat_dot_hat, A_barley_hat_ha, H_barley_dot_hat, A_sorghum_hat_ha, H_sorghum_dot_hat, A_oilseeds_hat_ha, H_oilseeds_dot_hat, R_wheat_hat_ha, R_sorghum_hat_ha, R_oilseeds_hat_ha, R_barley_hat_ha, Q_wheat_hat_ha, Q_barley_hat_ha, Q_sorghum_hat_ha, Q_oilseeds_hat_ha, S_wheat_cl_hat_ha, S_sheep_cl_hat_ha, S_sheep_births_hat_ha, S_sheep_deaths_hat_ha, S_beef_cl_hat_ha, S_beef_births_hat_ha, S_beef_deaths_hat_ha, Q_beef_hat_ha, Q_sheep_hat_ha, Q_lamb_hat_ha, R_beef_hat_ha, R_sheep_hat_ha, R_lamb_hat_ha, C_fodder_hat_ha, C_fert_hat_ha, C_fuel_hat_ha, C_chem_hat_ha, A_total_cropped_ha, FBP_pfe_hat_ha, farmland_per_cell
#> other available variables:
#>  lon, lat
#> Will return stars object with 612226 cells.
#> No projection information found in nc file. 
#>  Coordinate variable units found to be degrees, 
#>  assuming WGS84 Lat/Lon.
#> no 'var' specified, using farmno, R_total_hat_ha, C_total_hat_ha, FBP_fci_hat_ha, FBP_fbp_hat_ha, A_wheat_hat_ha, H_wheat_dot_hat, A_barley_hat_ha, H_barley_dot_hat, A_sorghum_hat_ha, H_sorghum_dot_hat, A_oilseeds_hat_ha, H_oilseeds_dot_hat, R_wheat_hat_ha, R_sorghum_hat_ha, R_oilseeds_hat_ha, R_barley_hat_ha, Q_wheat_hat_ha, Q_barley_hat_ha, Q_sorghum_hat_ha, Q_oilseeds_hat_ha, S_wheat_cl_hat_ha, S_sheep_cl_hat_ha, S_sheep_births_hat_ha, S_sheep_deaths_hat_ha, S_beef_cl_hat_ha, S_beef_births_hat_ha, S_beef_deaths_hat_ha, Q_beef_hat_ha, Q_sheep_hat_ha, Q_lamb_hat_ha, R_beef_hat_ha, R_sheep_hat_ha, R_lamb_hat_ha, C_fodder_hat_ha, C_fert_hat_ha, C_fuel_hat_ha, C_chem_hat_ha, A_total_cropped_ha, FBP_pfe_hat_ha, farmland_per_cell
#> other available variables:
#>  lon, lat
#> Will return stars object with 612226 cells.
#> No projection information found in nc file. 
#>  Coordinate variable units found to be degrees, 
#>  assuming WGS84 Lat/Lon.
#> no 'var' specified, using farmno, R_total_hat_ha, C_total_hat_ha, FBP_fci_hat_ha, FBP_fbp_hat_ha, A_wheat_hat_ha, H_wheat_dot_hat, A_barley_hat_ha, H_barley_dot_hat, A_sorghum_hat_ha, H_sorghum_dot_hat, A_oilseeds_hat_ha, H_oilseeds_dot_hat, R_wheat_hat_ha, R_sorghum_hat_ha, R_oilseeds_hat_ha, R_barley_hat_ha, Q_wheat_hat_ha, Q_barley_hat_ha, Q_sorghum_hat_ha, Q_oilseeds_hat_ha, S_wheat_cl_hat_ha, S_sheep_cl_hat_ha, S_sheep_births_hat_ha, S_sheep_deaths_hat_ha, S_beef_cl_hat_ha, S_beef_births_hat_ha, S_beef_deaths_hat_ha, Q_beef_hat_ha, Q_sheep_hat_ha, Q_lamb_hat_ha, R_beef_hat_ha, R_sheep_hat_ha, R_lamb_hat_ha, C_fodder_hat_ha, C_fert_hat_ha, C_fuel_hat_ha, C_chem_hat_ha, A_total_cropped_ha, FBP_pfe_hat_ha, farmland_per_cell
#> other available variables:
#>  lon, lat
#> Will return stars object with 612226 cells.
#> No projection information found in nc file. 
#>  Coordinate variable units found to be degrees, 
#>  assuming WGS84 Lat/Lon.
#> no 'var' specified, using farmno, R_total_hat_ha, C_total_hat_ha, FBP_fci_hat_ha, FBP_fbp_hat_ha, A_wheat_hat_ha, H_wheat_dot_hat, A_barley_hat_ha, H_barley_dot_hat, A_sorghum_hat_ha, H_sorghum_dot_hat, A_oilseeds_hat_ha, H_oilseeds_dot_hat, R_wheat_hat_ha, R_sorghum_hat_ha, R_oilseeds_hat_ha, R_barley_hat_ha, Q_wheat_hat_ha, Q_barley_hat_ha, Q_sorghum_hat_ha, Q_oilseeds_hat_ha, S_wheat_cl_hat_ha, S_sheep_cl_hat_ha, S_sheep_births_hat_ha, S_sheep_deaths_hat_ha, S_beef_cl_hat_ha, S_beef_births_hat_ha, S_beef_deaths_hat_ha, Q_beef_hat_ha, Q_sheep_hat_ha, Q_lamb_hat_ha, R_beef_hat_ha, R_sheep_hat_ha, R_lamb_hat_ha, C_fodder_hat_ha, C_fert_hat_ha, C_fuel_hat_ha, C_chem_hat_ha, A_total_cropped_ha, FBP_pfe_hat_ha, farmland_per_cell
#> other available variables:
#>  lon, lat
#> Will return stars object with 612226 cells.
#> No projection information found in nc file. 
#>  Coordinate variable units found to be degrees, 
#>  assuming WGS84 Lat/Lon.
#> no 'var' specified, using farmno, R_total_hat_ha, C_total_hat_ha, FBP_fci_hat_ha, FBP_fbp_hat_ha, A_wheat_hat_ha, H_wheat_dot_hat, A_barley_hat_ha, H_barley_dot_hat, A_sorghum_hat_ha, H_sorghum_dot_hat, A_oilseeds_hat_ha, H_oilseeds_dot_hat, R_wheat_hat_ha, R_sorghum_hat_ha, R_oilseeds_hat_ha, R_barley_hat_ha, Q_wheat_hat_ha, Q_barley_hat_ha, Q_sorghum_hat_ha, Q_oilseeds_hat_ha, S_wheat_cl_hat_ha, S_sheep_cl_hat_ha, S_sheep_births_hat_ha, S_sheep_deaths_hat_ha, S_beef_cl_hat_ha, S_beef_births_hat_ha, S_beef_deaths_hat_ha, Q_beef_hat_ha, Q_sheep_hat_ha, Q_lamb_hat_ha, R_beef_hat_ha, R_sheep_hat_ha, R_lamb_hat_ha, C_fodder_hat_ha, C_fert_hat_ha, C_fuel_hat_ha, C_chem_hat_ha, A_total_cropped_ha, FBP_pfe_hat_ha, farmland_per_cell
#> other available variables:
#>  lon, lat
#> Will return stars object with 612226 cells.
#> No projection information found in nc file. 
#>  Coordinate variable units found to be degrees, 
#>  assuming WGS84 Lat/Lon.
#> no 'var' specified, using farmno, R_total_hat_ha, C_total_hat_ha, FBP_fci_hat_ha, FBP_fbp_hat_ha, A_wheat_hat_ha, H_wheat_dot_hat, A_barley_hat_ha, H_barley_dot_hat, A_sorghum_hat_ha, H_sorghum_dot_hat, A_oilseeds_hat_ha, H_oilseeds_dot_hat, R_wheat_hat_ha, R_sorghum_hat_ha, R_oilseeds_hat_ha, R_barley_hat_ha, Q_wheat_hat_ha, Q_barley_hat_ha, Q_sorghum_hat_ha, Q_oilseeds_hat_ha, S_wheat_cl_hat_ha, S_sheep_cl_hat_ha, S_sheep_births_hat_ha, S_sheep_deaths_hat_ha, S_beef_cl_hat_ha, S_beef_births_hat_ha, S_beef_deaths_hat_ha, Q_beef_hat_ha, Q_sheep_hat_ha, Q_lamb_hat_ha, R_beef_hat_ha, R_sheep_hat_ha, R_lamb_hat_ha, C_fodder_hat_ha, C_fert_hat_ha, C_fuel_hat_ha, C_chem_hat_ha, A_total_cropped_ha, FBP_pfe_hat_ha, farmland_per_cell
#> other available variables:
#>  lon, lat
#> Will return stars object with 612226 cells.
#> No projection information found in nc file. 
#>  Coordinate variable units found to be degrees, 
#>  assuming WGS84 Lat/Lon.
#> no 'var' specified, using farmno, R_total_hat_ha, C_total_hat_ha, FBP_fci_hat_ha, FBP_fbp_hat_ha, A_wheat_hat_ha, H_wheat_dot_hat, A_barley_hat_ha, H_barley_dot_hat, A_sorghum_hat_ha, H_sorghum_dot_hat, A_oilseeds_hat_ha, H_oilseeds_dot_hat, R_wheat_hat_ha, R_sorghum_hat_ha, R_oilseeds_hat_ha, R_barley_hat_ha, Q_wheat_hat_ha, Q_barley_hat_ha, Q_sorghum_hat_ha, Q_oilseeds_hat_ha, S_wheat_cl_hat_ha, S_sheep_cl_hat_ha, S_sheep_births_hat_ha, S_sheep_deaths_hat_ha, S_beef_cl_hat_ha, S_beef_births_hat_ha, S_beef_deaths_hat_ha, Q_beef_hat_ha, Q_sheep_hat_ha, Q_lamb_hat_ha, R_beef_hat_ha, R_sheep_hat_ha, R_lamb_hat_ha, C_fodder_hat_ha, C_fert_hat_ha, C_fuel_hat_ha, C_chem_hat_ha, A_total_cropped_ha, FBP_pfe_hat_ha, farmland_per_cell
#> other available variables:
#>  lon, lat
#> Will return stars object with 612226 cells.
#> No projection information found in nc file. 
#>  Coordinate variable units found to be degrees, 
#>  assuming WGS84 Lat/Lon.
#> no 'var' specified, using farmno, R_total_hat_ha, C_total_hat_ha, FBP_fci_hat_ha, FBP_fbp_hat_ha, A_wheat_hat_ha, H_wheat_dot_hat, A_barley_hat_ha, H_barley_dot_hat, A_sorghum_hat_ha, H_sorghum_dot_hat, A_oilseeds_hat_ha, H_oilseeds_dot_hat, R_wheat_hat_ha, R_sorghum_hat_ha, R_oilseeds_hat_ha, R_barley_hat_ha, Q_wheat_hat_ha, Q_barley_hat_ha, Q_sorghum_hat_ha, Q_oilseeds_hat_ha, S_wheat_cl_hat_ha, S_sheep_cl_hat_ha, S_sheep_births_hat_ha, S_sheep_deaths_hat_ha, S_beef_cl_hat_ha, S_beef_births_hat_ha, S_beef_deaths_hat_ha, Q_beef_hat_ha, Q_sheep_hat_ha, Q_lamb_hat_ha, R_beef_hat_ha, R_sheep_hat_ha, R_lamb_hat_ha, C_fodder_hat_ha, C_fert_hat_ha, C_fuel_hat_ha, C_chem_hat_ha, A_total_cropped_ha, FBP_pfe_hat_ha, farmland_per_cell
#> other available variables:
#>  lon, lat
#> Will return stars object with 612226 cells.
#> No projection information found in nc file. 
#>  Coordinate variable units found to be degrees, 
#>  assuming WGS84 Lat/Lon.
#> no 'var' specified, using farmno, R_total_hat_ha, C_total_hat_ha, FBP_fci_hat_ha, FBP_fbp_hat_ha, A_wheat_hat_ha, H_wheat_dot_hat, A_barley_hat_ha, H_barley_dot_hat, A_sorghum_hat_ha, H_sorghum_dot_hat, A_oilseeds_hat_ha, H_oilseeds_dot_hat, R_wheat_hat_ha, R_sorghum_hat_ha, R_oilseeds_hat_ha, R_barley_hat_ha, Q_wheat_hat_ha, Q_barley_hat_ha, Q_sorghum_hat_ha, Q_oilseeds_hat_ha, S_wheat_cl_hat_ha, S_sheep_cl_hat_ha, S_sheep_births_hat_ha, S_sheep_deaths_hat_ha, S_beef_cl_hat_ha, S_beef_births_hat_ha, S_beef_deaths_hat_ha, Q_beef_hat_ha, Q_sheep_hat_ha, Q_lamb_hat_ha, R_beef_hat_ha, R_sheep_hat_ha, R_lamb_hat_ha, C_fodder_hat_ha, C_fert_hat_ha, C_fuel_hat_ha, C_chem_hat_ha, A_total_cropped_ha, FBP_pfe_hat_ha, farmland_per_cell
#> other available variables:
#>  lon, lat
#> Will return stars object with 612226 cells.
#> No projection information found in nc file. 
#>  Coordinate variable units found to be degrees, 
#>  assuming WGS84 Lat/Lon.
#> no 'var' specified, using farmno, R_total_hat_ha, C_total_hat_ha, FBP_fci_hat_ha, FBP_fbp_hat_ha, A_wheat_hat_ha, H_wheat_dot_hat, A_barley_hat_ha, H_barley_dot_hat, A_sorghum_hat_ha, H_sorghum_dot_hat, A_oilseeds_hat_ha, H_oilseeds_dot_hat, R_wheat_hat_ha, R_sorghum_hat_ha, R_oilseeds_hat_ha, R_barley_hat_ha, Q_wheat_hat_ha, Q_barley_hat_ha, Q_sorghum_hat_ha, Q_oilseeds_hat_ha, S_wheat_cl_hat_ha, S_sheep_cl_hat_ha, S_sheep_births_hat_ha, S_sheep_deaths_hat_ha, S_beef_cl_hat_ha, S_beef_births_hat_ha, S_beef_deaths_hat_ha, Q_beef_hat_ha, Q_sheep_hat_ha, Q_lamb_hat_ha, R_beef_hat_ha, R_sheep_hat_ha, R_lamb_hat_ha, C_fodder_hat_ha, C_fert_hat_ha, C_fuel_hat_ha, C_chem_hat_ha, A_total_cropped_ha, FBP_pfe_hat_ha, farmland_per_cell
#> other available variables:
#>  lon, lat
#> Will return stars object with 612226 cells.
#> No projection information found in nc file. 
#>  Coordinate variable units found to be degrees, 
#>  assuming WGS84 Lat/Lon.
#> no 'var' specified, using farmno, R_total_hat_ha, C_total_hat_ha, FBP_fci_hat_ha, FBP_fbp_hat_ha, A_wheat_hat_ha, H_wheat_dot_hat, A_barley_hat_ha, H_barley_dot_hat, A_sorghum_hat_ha, H_sorghum_dot_hat, A_oilseeds_hat_ha, H_oilseeds_dot_hat, R_wheat_hat_ha, R_sorghum_hat_ha, R_oilseeds_hat_ha, R_barley_hat_ha, Q_wheat_hat_ha, Q_barley_hat_ha, Q_sorghum_hat_ha, Q_oilseeds_hat_ha, S_wheat_cl_hat_ha, S_sheep_cl_hat_ha, S_sheep_births_hat_ha, S_sheep_deaths_hat_ha, S_beef_cl_hat_ha, S_beef_births_hat_ha, S_beef_deaths_hat_ha, Q_beef_hat_ha, Q_sheep_hat_ha, Q_lamb_hat_ha, R_beef_hat_ha, R_sheep_hat_ha, R_lamb_hat_ha, C_fodder_hat_ha, C_fert_hat_ha, C_fuel_hat_ha, C_chem_hat_ha, A_total_cropped_ha, FBP_pfe_hat_ha, farmland_per_cell
#> other available variables:
#>  lon, lat
#> Will return stars object with 612226 cells.
#> No projection information found in nc file. 
#>  Coordinate variable units found to be degrees, 
#>  assuming WGS84 Lat/Lon.
#> no 'var' specified, using farmno, R_total_hat_ha, C_total_hat_ha, FBP_fci_hat_ha, FBP_fbp_hat_ha, A_wheat_hat_ha, H_wheat_dot_hat, A_barley_hat_ha, H_barley_dot_hat, A_sorghum_hat_ha, H_sorghum_dot_hat, A_oilseeds_hat_ha, H_oilseeds_dot_hat, R_wheat_hat_ha, R_sorghum_hat_ha, R_oilseeds_hat_ha, R_barley_hat_ha, Q_wheat_hat_ha, Q_barley_hat_ha, Q_sorghum_hat_ha, Q_oilseeds_hat_ha, S_wheat_cl_hat_ha, S_sheep_cl_hat_ha, S_sheep_births_hat_ha, S_sheep_deaths_hat_ha, S_beef_cl_hat_ha, S_beef_births_hat_ha, S_beef_deaths_hat_ha, Q_beef_hat_ha, Q_sheep_hat_ha, Q_lamb_hat_ha, R_beef_hat_ha, R_sheep_hat_ha, R_lamb_hat_ha, C_fodder_hat_ha, C_fert_hat_ha, C_fuel_hat_ha, C_chem_hat_ha, A_total_cropped_ha, FBP_pfe_hat_ha, farmland_per_cell
#> other available variables:
#>  lon, lat
#> Will return stars object with 612226 cells.
#> No projection information found in nc file. 
#>  Coordinate variable units found to be degrees, 
#>  assuming WGS84 Lat/Lon.
#> no 'var' specified, using farmno, R_total_hat_ha, C_total_hat_ha, FBP_fci_hat_ha, FBP_fbp_hat_ha, A_wheat_hat_ha, H_wheat_dot_hat, A_barley_hat_ha, H_barley_dot_hat, A_sorghum_hat_ha, H_sorghum_dot_hat, A_oilseeds_hat_ha, H_oilseeds_dot_hat, R_wheat_hat_ha, R_sorghum_hat_ha, R_oilseeds_hat_ha, R_barley_hat_ha, Q_wheat_hat_ha, Q_barley_hat_ha, Q_sorghum_hat_ha, Q_oilseeds_hat_ha, S_wheat_cl_hat_ha, S_sheep_cl_hat_ha, S_sheep_births_hat_ha, S_sheep_deaths_hat_ha, S_beef_cl_hat_ha, S_beef_births_hat_ha, S_beef_deaths_hat_ha, Q_beef_hat_ha, Q_sheep_hat_ha, Q_lamb_hat_ha, R_beef_hat_ha, R_sheep_hat_ha, R_lamb_hat_ha, C_fodder_hat_ha, C_fert_hat_ha, C_fuel_hat_ha, C_chem_hat_ha, A_total_cropped_ha, FBP_pfe_hat_ha, farmland_per_cell
#> other available variables:
#>  lon, lat
#> Will return stars object with 612226 cells.
#> No projection information found in nc file. 
#>  Coordinate variable units found to be degrees, 
#>  assuming WGS84 Lat/Lon.
#> no 'var' specified, using farmno, R_total_hat_ha, C_total_hat_ha, FBP_fci_hat_ha, FBP_fbp_hat_ha, A_wheat_hat_ha, H_wheat_dot_hat, A_barley_hat_ha, H_barley_dot_hat, A_sorghum_hat_ha, H_sorghum_dot_hat, A_oilseeds_hat_ha, H_oilseeds_dot_hat, R_wheat_hat_ha, R_sorghum_hat_ha, R_oilseeds_hat_ha, R_barley_hat_ha, Q_wheat_hat_ha, Q_barley_hat_ha, Q_sorghum_hat_ha, Q_oilseeds_hat_ha, S_wheat_cl_hat_ha, S_sheep_cl_hat_ha, S_sheep_births_hat_ha, S_sheep_deaths_hat_ha, S_beef_cl_hat_ha, S_beef_births_hat_ha, S_beef_deaths_hat_ha, Q_beef_hat_ha, Q_sheep_hat_ha, Q_lamb_hat_ha, R_beef_hat_ha, R_sheep_hat_ha, R_lamb_hat_ha, C_fodder_hat_ha, C_fert_hat_ha, C_fuel_hat_ha, C_chem_hat_ha, A_total_cropped_ha, FBP_pfe_hat_ha, farmland_per_cell
#> other available variables:
#>  lon, lat
#> Will return stars object with 612226 cells.
#> No projection information found in nc file. 
#>  Coordinate variable units found to be degrees, 
#>  assuming WGS84 Lat/Lon.
#> no 'var' specified, using farmno, R_total_hat_ha, C_total_hat_ha, FBP_fci_hat_ha, FBP_fbp_hat_ha, A_wheat_hat_ha, H_wheat_dot_hat, A_barley_hat_ha, H_barley_dot_hat, A_sorghum_hat_ha, H_sorghum_dot_hat, A_oilseeds_hat_ha, H_oilseeds_dot_hat, R_wheat_hat_ha, R_sorghum_hat_ha, R_oilseeds_hat_ha, R_barley_hat_ha, Q_wheat_hat_ha, Q_barley_hat_ha, Q_sorghum_hat_ha, Q_oilseeds_hat_ha, S_wheat_cl_hat_ha, S_sheep_cl_hat_ha, S_sheep_births_hat_ha, S_sheep_deaths_hat_ha, S_beef_cl_hat_ha, S_beef_births_hat_ha, S_beef_deaths_hat_ha, Q_beef_hat_ha, Q_sheep_hat_ha, Q_lamb_hat_ha, R_beef_hat_ha, R_sheep_hat_ha, R_lamb_hat_ha, C_fodder_hat_ha, C_fert_hat_ha, C_fuel_hat_ha, C_chem_hat_ha, A_total_cropped_ha, FBP_pfe_hat_ha, farmland_per_cell
#> other available variables:
#>  lon, lat
#> Will return stars object with 612226 cells.
#> No projection information found in nc file. 
#>  Coordinate variable units found to be degrees, 
#>  assuming WGS84 Lat/Lon.
#> no 'var' specified, using farmno, R_total_hat_ha, C_total_hat_ha, FBP_fci_hat_ha, FBP_fbp_hat_ha, A_wheat_hat_ha, H_wheat_dot_hat, A_barley_hat_ha, H_barley_dot_hat, A_sorghum_hat_ha, H_sorghum_dot_hat, A_oilseeds_hat_ha, H_oilseeds_dot_hat, R_wheat_hat_ha, R_sorghum_hat_ha, R_oilseeds_hat_ha, R_barley_hat_ha, Q_wheat_hat_ha, Q_barley_hat_ha, Q_sorghum_hat_ha, Q_oilseeds_hat_ha, S_wheat_cl_hat_ha, S_sheep_cl_hat_ha, S_sheep_births_hat_ha, S_sheep_deaths_hat_ha, S_beef_cl_hat_ha, S_beef_births_hat_ha, S_beef_deaths_hat_ha, Q_beef_hat_ha, Q_sheep_hat_ha, Q_lamb_hat_ha, R_beef_hat_ha, R_sheep_hat_ha, R_lamb_hat_ha, C_fodder_hat_ha, C_fert_hat_ha, C_fuel_hat_ha, C_chem_hat_ha, A_total_cropped_ha, FBP_pfe_hat_ha, farmland_per_cell
#> other available variables:
#>  lon, lat
#> Will return stars object with 612226 cells.
#> No projection information found in nc file. 
#>  Coordinate variable units found to be degrees, 
#>  assuming WGS84 Lat/Lon.
#> no 'var' specified, using farmno, R_total_hat_ha, C_total_hat_ha, FBP_fci_hat_ha, FBP_fbp_hat_ha, A_wheat_hat_ha, H_wheat_dot_hat, A_barley_hat_ha, H_barley_dot_hat, A_sorghum_hat_ha, H_sorghum_dot_hat, A_oilseeds_hat_ha, H_oilseeds_dot_hat, R_wheat_hat_ha, R_sorghum_hat_ha, R_oilseeds_hat_ha, R_barley_hat_ha, Q_wheat_hat_ha, Q_barley_hat_ha, Q_sorghum_hat_ha, Q_oilseeds_hat_ha, S_wheat_cl_hat_ha, S_sheep_cl_hat_ha, S_sheep_births_hat_ha, S_sheep_deaths_hat_ha, S_beef_cl_hat_ha, S_beef_births_hat_ha, S_beef_deaths_hat_ha, Q_beef_hat_ha, Q_sheep_hat_ha, Q_lamb_hat_ha, R_beef_hat_ha, R_sheep_hat_ha, R_lamb_hat_ha, C_fodder_hat_ha, C_fert_hat_ha, C_fuel_hat_ha, C_chem_hat_ha, A_total_cropped_ha, FBP_pfe_hat_ha, farmland_per_cell
#> other available variables:
#>  lon, lat
#> Will return stars object with 612226 cells.
#> No projection information found in nc file. 
#>  Coordinate variable units found to be degrees, 
#>  assuming WGS84 Lat/Lon.
#> no 'var' specified, using farmno, R_total_hat_ha, C_total_hat_ha, FBP_fci_hat_ha, FBP_fbp_hat_ha, A_wheat_hat_ha, H_wheat_dot_hat, A_barley_hat_ha, H_barley_dot_hat, A_sorghum_hat_ha, H_sorghum_dot_hat, A_oilseeds_hat_ha, H_oilseeds_dot_hat, R_wheat_hat_ha, R_sorghum_hat_ha, R_oilseeds_hat_ha, R_barley_hat_ha, Q_wheat_hat_ha, Q_barley_hat_ha, Q_sorghum_hat_ha, Q_oilseeds_hat_ha, S_wheat_cl_hat_ha, S_sheep_cl_hat_ha, S_sheep_births_hat_ha, S_sheep_deaths_hat_ha, S_beef_cl_hat_ha, S_beef_births_hat_ha, S_beef_deaths_hat_ha, Q_beef_hat_ha, Q_sheep_hat_ha, Q_lamb_hat_ha, R_beef_hat_ha, R_sheep_hat_ha, R_lamb_hat_ha, C_fodder_hat_ha, C_fert_hat_ha, C_fuel_hat_ha, C_chem_hat_ha, A_total_cropped_ha, FBP_pfe_hat_ha, farmland_per_cell
#> other available variables:
#>  lon, lat
#> Will return stars object with 612226 cells.
#> No projection information found in nc file. 
#>  Coordinate variable units found to be degrees, 
#>  assuming WGS84 Lat/Lon.
#> no 'var' specified, using farmno, R_total_hat_ha, C_total_hat_ha, FBP_fci_hat_ha, FBP_fbp_hat_ha, A_wheat_hat_ha, H_wheat_dot_hat, A_barley_hat_ha, H_barley_dot_hat, A_sorghum_hat_ha, H_sorghum_dot_hat, A_oilseeds_hat_ha, H_oilseeds_dot_hat, R_wheat_hat_ha, R_sorghum_hat_ha, R_oilseeds_hat_ha, R_barley_hat_ha, Q_wheat_hat_ha, Q_barley_hat_ha, Q_sorghum_hat_ha, Q_oilseeds_hat_ha, S_wheat_cl_hat_ha, S_sheep_cl_hat_ha, S_sheep_births_hat_ha, S_sheep_deaths_hat_ha, S_beef_cl_hat_ha, S_beef_births_hat_ha, S_beef_deaths_hat_ha, Q_beef_hat_ha, Q_sheep_hat_ha, Q_lamb_hat_ha, R_beef_hat_ha, R_sheep_hat_ha, R_lamb_hat_ha, C_fodder_hat_ha, C_fert_hat_ha, C_fuel_hat_ha, C_chem_hat_ha, A_total_cropped_ha, FBP_pfe_hat_ha, farmland_per_cell
#> other available variables:
#>  lon, lat
#> Will return stars object with 612226 cells.
#> No projection information found in nc file. 
#>  Coordinate variable units found to be degrees, 
#>  assuming WGS84 Lat/Lon.
#> no 'var' specified, using farmno, R_total_hat_ha, C_total_hat_ha, FBP_fci_hat_ha, FBP_fbp_hat_ha, A_wheat_hat_ha, H_wheat_dot_hat, A_barley_hat_ha, H_barley_dot_hat, A_sorghum_hat_ha, H_sorghum_dot_hat, A_oilseeds_hat_ha, H_oilseeds_dot_hat, R_wheat_hat_ha, R_sorghum_hat_ha, R_oilseeds_hat_ha, R_barley_hat_ha, Q_wheat_hat_ha, Q_barley_hat_ha, Q_sorghum_hat_ha, Q_oilseeds_hat_ha, S_wheat_cl_hat_ha, S_sheep_cl_hat_ha, S_sheep_births_hat_ha, S_sheep_deaths_hat_ha, S_beef_cl_hat_ha, S_beef_births_hat_ha, S_beef_deaths_hat_ha, Q_beef_hat_ha, Q_sheep_hat_ha, Q_lamb_hat_ha, R_beef_hat_ha, R_sheep_hat_ha, R_lamb_hat_ha, C_fodder_hat_ha, C_fert_hat_ha, C_fuel_hat_ha, C_chem_hat_ha, A_total_cropped_ha, FBP_pfe_hat_ha, farmland_per_cell
#> other available variables:
#>  lon, lat
#> Will return stars object with 612226 cells.
#> No projection information found in nc file. 
#>  Coordinate variable units found to be degrees, 
#>  assuming WGS84 Lat/Lon.

## A {terra} `rast` object
ter <- get_agfd(cache = TRUE) |>
  read_agfd_terra() |> 
  head()

## A list of {tidync} objects
tnc <- get_agfd(cache = TRUE) |>
  read_agfd_tidync() |> 
  head()

## A {data.table} object
dtb <- get_agfd(cache = TRUE) |>
  read_agfd_dt() |> 
  head()
```

## Features

### Caching

{abares} supports caching the files using
`tools::R_user_dir(package = "agfd", which = "cache")` to save the files
in a standardised location across platforms so you don’t have to worry
about where the files went or if they’re still there. When requesting
the files, {abares} will first check if they are available locally.
Caching is not mandatory, you can just work with the downloaded files in
`tempdir()`, which is cleaned up when your R session ends. Due to the
large file sizes, `get_agfd()` will always check first if the files are
available locally, either cached or in your current R session’s
`tempdir()` to save time by not downloading again if they are available
already.

### Multiple Classes Supported

{abares} supports multiple classes of objects to support your workflow.
Select from spatial classes:

- [{stars}](https://CRAN.R-project.org/package=stars),
- [{terra}](https://CRAN.R-project.org/package=terra) or
- [{tidync}](https://CRAN.R-project.org/package=tidync)

or data.frame objects:

- [{tibble}](https://CRAN.R-project.org/package=tibble), or
- [{data.table}](https://CRAN.R-project.org/package=data.table)

## Description of the Australian Farm Gridded Data

Directly from the DAFF website:

> The Australian Gridded Farm Data are a set of national scale maps
> containing simulated data on historical broadacre farm business
> outcomes including farm profitability on an 0.05-degree (approximately
> 5 km) grid.

> These data have been produced by ABARES as part of the ongoing
> Australian Agricultural Drought Indicator (AADI) project (previously
> known as the Drought Early Warning System Project) and were derived
> using ABARES farmpredict model, which in turn is based on ABARES
> Agricultural and Grazing Industries Survey (AAGIS) data.

> These maps provide estimates of farm business profit, revenue, costs
> and production by location (grid cell) and year for the period 1990-91
> to 2022-23. The data do not include actual observed outcomes but
> rather model predicted outcomes for representative or ‘typical’
> broadacre farm businesses at each location considering likely farm
> characteristics and prevailing weather conditions and commodity
> prices.

> The Australian Gridded Farm Data remain under active development, and
> as such should be considered experimental.

– Australian Department of Agriculture, Fisheries and Forestry.

## Metadata

Please report any [issues or
bugs](https://codeberg.org/adamhsparks/agfd/issues).

License: [MIT](LICENSE.md)

Citing the data: Please refer to the ABARES website,
<https://www.agriculture.gov.au/abares/products/citations> on how to
cite this data when you use it.
