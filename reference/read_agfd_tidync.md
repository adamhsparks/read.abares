# Read ABARES' "Australian Gridded Farm Data" (AGFD) NCDF Files with tidync

Read "Australian Gridded Farm Data", (AGFD), as a list of
[`tidync::tidync()`](https://docs.ropensci.org/tidync/reference/tidync.html)
objects.

## Usage

``` r
read_agfd_tidync(yyyy = 1991:2023, fixed_prices = TRUE, x = NULL)
```

## Arguments

- yyyy:

  Returns only data for the specified year or years for climate data
  (fixed prices) or the years for historical climate and prices
  depending upon the setting of `fixed_prices`. Note that this will
  still download the entire data set, that cannot be avoided, but will
  only return the requested year(s) in your R session. Valid years are
  from 1991 to 2023 inclusive.

- fixed_prices:

  Download historical climate and prices or historical climate and fixed
  prices as described in (Hughes *et al.* 2022). Defaults to `TRUE` and
  downloads the data with historical climate and fixed prices "to
  isolate the effects of climate variability on financial incomes for
  broadacre farm businesses" (ABARES 2024). Using `TRUE` will download
  simulations where global output and input price indexes are fixed at
  values from the most recently completed financial year.

- x:

  A file path providing the file with the data to be imported. The file
  is assumed to be unarchived (*i.e.*, still zipped). This function does
  not provide any checking whether this function is the proper function
  for the provided file. Defaults to `NULL`, assuming that the file will
  be downloaded in the active R session.

## Value

A list of [tidync](https://CRAN.R-project.org/package=tidync) objects of
the "Australian Gridded Farm Data" with the NetCDF objects' names as
"year_yyyy".

## Details

From the [ABARES
website](https://www.agriculture.gov.au/abares/research-topics/surveys/farm-survey-data/australian-gridded-farm-data):
"The Australian Gridded Farm Data (AGFD) are a set of national scale
maps containing simulated data on historical broadacre farm business
outcomes including farm profitability on an 0.05-degree (approximately 5
km) grid.  
These data have been produced by ABARES as part of the ongoing
Australian Agricultural Drought Indicator (AADI) project (previously
known as the Drought Early Warning System Project) and were derived
using ABARES
[*farmpredict*](https://www.agriculture.gov.au/abares/research-topics/climate/drought/farmpredict)
model, which in turn is based on ABARES Agricultural and Grazing
Industries Survey (AAGIS) data.  
[Australian Agricultural Drought
Indicator](https://www.agriculture.gov.au/abares/research-topics/climate/australian-agricultural-drought-indicators-project)
(AADI) project (previously known as the Drought Early Warning System
Project) and were derived using ABARES
[*farmpredict*](https://www.agriculture.gov.au/abares/research-topics/climate/drought/farmpredict)
model, which in turn is based on ABARES [Agricultural and Grazing
Industries
Survey](https://www.agriculture.gov.au/abares/research-topics/surveys/farm-definitions-methods)
(AAGIS) data.  
These maps provide estimates of farm business profit, revenue, costs and
production by location (grid cell) and year for the period 1990-91 to
2022-23. The data do not include actual observed outcomes but rather
model predicted outcomes for representative or 'typical' broadacre farm
businesses at each location considering likely farm characteristics and
prevailing weather conditions and commodity prices."  
– ABARES, 2024-11-25

If you have not already downloaded the files, both sets of data are
large in file size, *i.e.*, \>1GB, and will require time to download.

## Model scenarios

### Historical Climate (fixed prices)

The Historical Climate (fixed prices) scenario is similar to that
described in Hughes *et al.* (2022) and is intended to isolate the
effects of climate variability on financial incomes for broadacre farm
businesses. In these simulations, global output and input price indexes
are fixed at values from the most recently completed financial year.
However, in these scenarios the spread between domestic and global grain
(wheat, barley and sorghum) prices, along with Australian fodder prices
are allowed to vary in response to climate data (to capture domestic
increases in grain and fodder prices in drought years, see Hughes *et
al.* 2022). A 33-year historical climate sequence (including historical
simulated crop and pasture data from the AADI project) is simulated for
each grid cell (1990-91 to 2022-23).

### Historical Climate and Prices

As part of the AADI project an additional scenario was developed
accounting for changes in both climate conditions and output and input
prices (*i.e.*, global commodity market variability). In this historical
climate and prices scenario the 33-year reference period allows for
variation in both historical climate conditions and historical prices.
For this scenario, historical price indexes were de-trended, to account
for consistent long-term trends in some real commodity prices
(particularly sheep and lamb). The resulting simulation results and
percentile indicators are intended to reflect the combined impacts of
annual climate and commodity price variability."

– Taken from Australian Bureau of Agricultural and Resource Economics
and Sciences (2024)

## Data files

Simulation output data are saved as multilayer NetCDF files, which are
named using following convention:

`f<farm year>.c<climate year>.p<price year>.t<technology year>.nc`

where:

- `<farm year>` = Financial year of farm business data is used in
  simulations.

- `<climate year>` = Financial year of climate data is used in
  simulations.

- `<price year>` = Financial year of output and input prices used in
  simulations.

- `<technology year>` = Financial year of farm 'technology' (equal to
  farm year in all simulations) Here financial years are referred to by
  the closing calendar year (*e.g.*, 2022 = 1 July 2021 to 30 June
  2022).

– Taken from Australian Bureau of Agricultural and Resource Economics
and Sciences (2024)

## Data layers

The data layers from the downloaded NetCDF files are described in Table
2 as seen in Australian Bureau of Agricultural and Resource Economics
and Sciences (2024).

Following is a copy of Table 2 for your convenience, please refer to the
full document for all methods and metadata.

|                       |           |                                                                                                               |
|-----------------------|-----------|---------------------------------------------------------------------------------------------------------------|
| **Layer**             | **Unit**  | **Description**                                                                                               |
| farmno                | \-        | Row index and column index of the grid cell in the form of YYYXXX                                             |
| A_barley_hat_ha       | \-        | Proportion of total farm area planted to barley                                                               |
| A_oilseeds_hat_ha     | \-        | Proportion of total farm area planted to canola                                                               |
| A_sorghum_hat_ha      | \-        | Proportion of total farm area planted to sorghum                                                              |
| A_total_cropped_ha    | \-        | Proportion of total farm area planted to crops                                                                |
| A_wheat_hat_ha        | \-        | Proportion of total farm area planted to wheat                                                                |
| C_chem_hat_ha         | \$/ha     | Expenditure on crop and pasture chemicals per hectare                                                         |
| C_fert_hat_ha         | \$/ha     | Expenditure on fertiliser per hectare                                                                         |
| C_fodder_hat_ha       | \$/ha     | Expenditure on fodder per hectare                                                                             |
| C_fuel_hat_ha         | \$/ha     | Expenditure on fuel, oil and grease per hectare                                                               |
| C_total_hat_ha        | \$/ha     | Total cash costs per hectare                                                                                  |
| FBP_fci_hat_ha        | \$/ha     | Farm cash income per hectare                                                                                  |
| FBP_fbp_hat_ha        | \$/ha     | Farm business profit per hectare, cash income adjusted for family labour, depreciation, and changes in stocks |
| FBP_pfe_hat_ha        | \$/ha     | Profit at full equity per hectare                                                                             |
| H_barley_dot_hat      | t/ha      | Barley yield (production per hectare planted)                                                                 |
| H_oilseeds_dot_hat    | t/ha      | Oilseeds yield (production per hectare planted)                                                               |
| H_sorghum_dot_hat     | t/ha      | Sorghum yield (production per hectare planted)                                                                |
| H_wheat_dot_hat       | t/ha      | Wheat yield (production per hectare planted)                                                                  |
| Q_barley_hat_ha       | t/ha      | Barley sold per hectare (total farm area)                                                                     |
| Q_beef_hat_ha         | Number/ha | Beef number sold per hectare                                                                                  |
| Q_lamb_hat_ha         | Number/ha | Prime lamb number sold per hectare                                                                            |
| Q_oilseeds_hat_ha     | t/ha      | Canola sold per hectare (total farm area)                                                                     |
| Q_sheep_hat_ha        | Number/ha | Sheep number sold per hectare                                                                                 |
| Q_sorghum_hat_ha      | t/ha      | Sorghum sold per hectare (total farm area)                                                                    |
| Q_wheat_hat_ha        | t/ha      | Wheat sold per hectare (total farm area)                                                                      |
| R_barley_hat_ha       | \$/ha     | Barley gross receipts per hectare                                                                             |
| R_beef_hat_ha         | \$/ha     | Beef cattle receipts per hectare                                                                              |
| R_lamb_hat_ha         | \$/ha     | Prime lamb net receipts per hectare                                                                           |
| R_oilseeds_hat_ha     | \$/ha     | Receipts for oilseeds this FY for oilseeds sold this FY or in previous FYs per hectare                        |
| R_sheep_hat_ha        | \$/ha     | Sheep gross receipts per hectare                                                                              |
| R_sorghum_hat_ha      | \$/ha     | Sorghum gross receipts per hectare                                                                            |
| R_total_hat_ha        | \$/ha     | Total farm receipts per hectare                                                                               |
| R_wheat_hat_ha        | \$/ha     | Wheat gross receipts per hectare                                                                              |
| S_beef_births_hat_ha  | Number/ha | Beef cattle births per hectare                                                                                |
| S_beef_cl_hat_ha      | Number/ha | Beef cattle on hand per hectare on 30 June                                                                    |
| S_beef_deaths_hat_ha  | Number/ha | Beef cattle deaths per hectare                                                                                |
| S_sheep_births_hat_ha | Number/ha | Sheep births per hectare                                                                                      |
| S_sheep_cl_hat_ha     | Number/ha | Sheep on hand per hectare on 30 June                                                                          |
| S_sheep_deaths_hat_ha | Number/ha | Sheep deaths per hectare                                                                                      |
| S_wheat_cl_hat_ha     | t/ha      | Wheat on hand per hectare on 30 June                                                                          |
| farmland_per_cell     | ha        | Indicative area of farmland in the grid cell                                                                  |

## References

*Australian gridded farm data*, Australian Bureau of Agricultural and
Resource Economics and Sciences, Canberra, July 2024,
[doi:10.25814/7n6z-ev41](https://doi.org/10.25814/7n6z-ev41) . [CC BY
4.0](https://creativecommons.org/licenses/by/4.0/legalcode).

N. Hughes, W.Y. Soh, C. Boult, K. Lawson, *Defining drought from the
perspective of Australian farmers*, Climate Risk Management, Volume 35,
2022, 100420, ISSN 2212-0963,
[doi:10.1016/j.crm.2022.100420](https://doi.org/10.1016/j.crm.2022.100420)
.

## See also

Other AGFD:
[`read_agfd_dt()`](https://adamhsparks.github.io/read.abares/reference/read_agfd_dt.md),
[`read_agfd_stars()`](https://adamhsparks.github.io/read.abares/reference/read_agfd_stars.md),
[`read_agfd_terra()`](https://adamhsparks.github.io/read.abares/reference/read_agfd_terra.md)

## Examples

``` r
if (FALSE) { # interactive()

agfd_tnc <- read_agfd_tidync()

head(agfd_tnc)
}
```
