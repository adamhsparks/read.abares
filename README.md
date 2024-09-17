
<!-- README.md is generated from README.Rmd. Please edit that file -->

# {abares}: Simple downloading and importing of ABARES Data

<!-- badges: start -->

[![CRAN
status](https://www.r-pkg.org/badges/version/abares)](https://CRAN.R-project.org/package=abares)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
<!-- badges: end -->

An R package for automated downloading, parsing and formatting of data
from the Australian Bureau of Agricultural and Resource Economics and
Sciences including the:

- [Historical National Estimates, Historical State Estimates, Historical
  Regional Estimates, Estimates by Size, Estimates by Performance
  Category](https://www.agriculture.gov.au/abares/data/farm-data-portal#data-download);
- the [Australian Gridded Farm Data (AGFD)
  set](https://www.agriculture.gov.au/abares/research-topics/surveys/farm-survey-data/australian-gridded-farm-data);
  and the
- [Australian Agricultural and Grazing Industries Survey
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

get_hist_nat_est() |> 
  head()
#>                             Variable  Year Value   RSE      Industry
#>                               <char> <int> <num> <int>        <char>
#> 1: AI stud fees and herd testing ($)  1990   790    39 All Broadacre
#> 2:           Accounting services ($)  1990  2850     4 All Broadacre
#> 3:             Advisory services ($)  1990   280    37 All Broadacre
#> 4:        Age of owner manager (yrs)  1990    53     1 All Broadacre
#> 5:               Age of spouse (yrs)  1990    49     1 All Broadacre
#> 6:                     Agistment ($)  1990  1950    36 All Broadacre

get_hist_sta_est() |> 
  head()
#>                             Variable  Year Value   RSE           State
#>                               <char> <int> <num> <int>          <char>
#> 1: AI stud fees and herd testing ($)  1990   210   118 New South Wales
#> 2:           Accounting services ($)  1990  2740     7 New South Wales
#> 3:             Advisory services ($)  1990   190   105 New South Wales
#> 4:        Age of owner manager (yrs)  1990    55     2 New South Wales
#> 5:               Age of spouse (yrs)  1990    52     2 New South Wales
#> 6:                     Agistment ($)  1990  2790    71 New South Wales
#>         Industry
#>           <char>
#> 1: All Broadacre
#> 2: All Broadacre
#> 3: All Broadacre
#> 4: All Broadacre
#> 5: All Broadacre
#> 6: All Broadacre

get_hist_reg_est() |> 
  head()
#>                             Variable  Year    ABARES region Value   RSE
#>                               <char> <int>           <char> <num> <int>
#> 1: AI stud fees and herd testing ($)  1990 NSW Central West    90    68
#> 2:           Accounting services ($)  1990 NSW Central West  2420    19
#> 3:             Advisory services ($)  1990 NSW Central West   120    80
#> 4:        Age of owner manager (yrs)  1990 NSW Central West    57     5
#> 5:               Age of spouse (yrs)  1990 NSW Central West    51     4
#> 6:                     Agistment ($)  1990 NSW Central West   310    52
```

#### AGFD Data

You can download files and pipe directly into the class object that you
desire for the AGFD data.

``` r
library(abares)

## A list of {stars} objects
star <- get_agfd(cache = TRUE) |>
  read_agfd_stars()
#> Will return stars object with 612226 cells.
#> No projection information found in nc file. 
#>  Coordinate variable units found to be degrees, 
#>  assuming WGS84 Lat/Lon.

head(star[[1]])
#> stars object with 2 dimensions and 6 attributes
#> attribute(s):
#>                         Min.         1st Qu.         Median           Mean
#> farmno          15612.000000 233091.50000000 329567.0000000 324737.7187618
#> R_total_hat_ha      2.954396      7.88312157     21.7520529    169.5139301
#> C_total_hat_ha      1.304440      4.34079101      9.9449849     93.2210542
#> FBP_fci_hat_ha   -143.759785      3.60529967     11.5796641     76.2928759
#> FBP_fbp_hat_ha   -349.521639      3.36599833     11.5074294     60.0750936
#> A_wheat_hat_ha      0.000000      0.04062786      0.1114289      0.1365683
#>                        3rd Qu.           Max.   NA's
#> farmno          418508.5000000 669706.0000000 443899
#> R_total_hat_ha     174.8553843   2415.7556059 443899
#> C_total_hat_ha      95.7221857   1853.5385298 443899
#> FBP_fci_hat_ha      77.6748501   1186.5830232 443899
#> FBP_fbp_hat_ha      62.8596117   1240.6003218 443899
#> A_wheat_hat_ha       0.2112845      0.5047761 565224
#> dimension(s):
#>     from  to refsys              values x/y
#> lon    1 886 WGS 84 [886] 112,...,156.2 [x]
#> lat    1 691 WGS 84 [691] -44.5,...,-10 [y]

## A {terra} `rast` object
terr <- get_agfd(cache = TRUE) |>
  read_agfd_terra()

head(terr[[1]])
#> class       : SpatRaster 
#> dimensions  : 6, 886, 41  (nrow, ncol, nlyr)
#> resolution  : 0.05, 0.05  (x, y)
#> extent      : 111.975, 156.275, -10.275, -9.975  (xmin, xmax, ymin, ymax)
#> coord. ref. : lon/lat WGS 84 
#> source(s)   : memory
#> names       : farmno, R_tot~at_ha, C_tot~at_ha, FBP_f~at_ha, FBP_f~at_ha, A_whe~at_ha, ... 
#> min values  :    NaN,         NaN,         NaN,         NaN,         NaN,         NaN, ... 
#> max values  :    NaN,         NaN,         NaN,         NaN,         NaN,         NaN, ...

## A list of {tidync} objects
tdnc <- get_agfd(cache = TRUE) |>
  read_agfd_tidync()

head(tdnc[[1]])
#> $source
#> # A tibble: 1 × 2
#>   access              source                                                    
#>   <dttm>              <chr>                                                     
#> 1 2024-09-17 21:20:55 /Users/adamsparks/Library/Caches/org.R-project.R/R/abares…
#> 
#> $axis
#> # A tibble: 84 × 3
#>     axis variable       dimension
#>    <int> <chr>              <int>
#>  1     1 lon                    0
#>  2     2 lat                    1
#>  3     3 farmno                 0
#>  4     4 farmno                 1
#>  5     5 R_total_hat_ha         0
#>  6     6 R_total_hat_ha         1
#>  7     7 C_total_hat_ha         0
#>  8     8 C_total_hat_ha         1
#>  9     9 FBP_fci_hat_ha         0
#> 10    10 FBP_fci_hat_ha         1
#> # ℹ 74 more rows
#> 
#> $grid
#> # A tibble: 3 × 4
#>   grid  ndims variables         nvars
#>   <chr> <int> <list>            <int>
#> 1 D0,D1     2 <tibble [41 × 1]>    41
#> 2 D0        1 <tibble [1 × 1]>      1
#> 3 D1        1 <tibble [1 × 1]>      1
#> 
#> $dimension
#> # A tibble: 2 × 8
#>      id name  length unlim coord_dim active start count
#>   <int> <chr>  <dbl> <lgl> <lgl>     <lgl>  <int> <int>
#> 1     0 lon      886 FALSE TRUE      TRUE       1   886
#> 2     1 lat      691 FALSE TRUE      TRUE       1   691
#> 
#> $variable
#> # A tibble: 43 × 7
#>       id name            type      ndims natts dim_coord active
#>    <int> <chr>           <chr>     <int> <int> <lgl>     <lgl> 
#>  1     0 lon             NC_DOUBLE     1     2 TRUE      FALSE 
#>  2     1 lat             NC_DOUBLE     1     2 TRUE      FALSE 
#>  3     2 farmno          NC_DOUBLE     2     1 FALSE     TRUE  
#>  4     3 R_total_hat_ha  NC_DOUBLE     2     1 FALSE     TRUE  
#>  5     4 C_total_hat_ha  NC_DOUBLE     2     1 FALSE     TRUE  
#>  6     5 FBP_fci_hat_ha  NC_DOUBLE     2     1 FALSE     TRUE  
#>  7     6 FBP_fbp_hat_ha  NC_DOUBLE     2     1 FALSE     TRUE  
#>  8     7 A_wheat_hat_ha  NC_DOUBLE     2     1 FALSE     TRUE  
#>  9     8 H_wheat_dot_hat NC_DOUBLE     2     1 FALSE     TRUE  
#> 10     9 A_barley_hat_ha NC_DOUBLE     2     1 FALSE     TRUE  
#> # ℹ 33 more rows
#> 
#> $attribute
#> # A tibble: 49 × 4
#>       id name       variable       value       
#>    <int> <chr>      <chr>          <named list>
#>  1     0 _FillValue lon            <dbl [1]>   
#>  2     1 units      lon            <chr [1]>   
#>  3     0 _FillValue lat            <dbl [1]>   
#>  4     1 units      lat            <chr [1]>   
#>  5     0 _FillValue farmno         <dbl [1]>   
#>  6     0 _FillValue R_total_hat_ha <dbl [1]>   
#>  7     0 _FillValue C_total_hat_ha <dbl [1]>   
#>  8     0 _FillValue FBP_fci_hat_ha <dbl [1]>   
#>  9     0 _FillValue FBP_fbp_hat_ha <dbl [1]>   
#> 10     0 _FillValue A_wheat_hat_ha <dbl [1]>   
#> # ℹ 39 more rows

## A {data.table} object
get_agfd(cache = TRUE) |>
  read_agfd_dt() |>
  head()
#>    farmno R_total_hat_ha C_total_hat_ha FBP_fci_hat_ha FBP_fbp_hat_ha
#>     <num>          <num>          <num>          <num>          <num>
#> 1:  15612       7.636519       4.405228       3.231292       1.766127
#> 2:  21495      14.811169       9.165632       5.645538       6.178280
#> 3:  23418      24.874456      14.858595      10.015861      15.504923
#> 4:  24494      15.043653       9.326359       5.717294       7.212161
#> 5:  32429      23.630099      13.681063       9.949036       9.612778
#> 6:  32485      15.009926       9.815501       5.194425       6.582035
#>    A_wheat_hat_ha H_wheat_dot_hat A_barley_hat_ha H_barley_dot_hat
#>             <num>           <num>           <num>            <num>
#> 1:            NaN             NaN             NaN              NaN
#> 2:            NaN             NaN             NaN              NaN
#> 3:            NaN             NaN             NaN              NaN
#> 4:            NaN             NaN             NaN              NaN
#> 5:            NaN             NaN             NaN              NaN
#> 6:            NaN             NaN             NaN              NaN
#>    A_sorghum_hat_ha H_sorghum_dot_hat A_oilseeds_hat_ha H_oilseeds_dot_hat
#>               <num>             <num>             <num>              <num>
#> 1:              NaN               NaN               NaN                NaN
#> 2:              NaN               NaN               NaN                NaN
#> 3:              NaN               NaN               NaN                NaN
#> 4:              NaN               NaN               NaN                NaN
#> 5:              NaN               NaN               NaN                NaN
#> 6:              NaN               NaN               NaN                NaN
#>    R_wheat_hat_ha R_sorghum_hat_ha R_oilseeds_hat_ha R_barley_hat_ha
#>             <num>            <num>             <num>           <num>
#> 1:            NaN              NaN               NaN             NaN
#> 2:            NaN              NaN               NaN             NaN
#> 3:            NaN              NaN               NaN             NaN
#> 4:            NaN              NaN               NaN             NaN
#> 5:            NaN              NaN               NaN             NaN
#> 6:            NaN              NaN               NaN             NaN
#>    Q_wheat_hat_ha Q_barley_hat_ha Q_sorghum_hat_ha Q_oilseeds_hat_ha
#>             <num>           <num>            <num>             <num>
#> 1:            NaN             NaN              NaN               NaN
#> 2:            NaN             NaN              NaN               NaN
#> 3:            NaN             NaN              NaN               NaN
#> 4:            NaN             NaN              NaN               NaN
#> 5:            NaN             NaN              NaN               NaN
#> 6:            NaN             NaN              NaN               NaN
#>    S_wheat_cl_hat_ha S_sheep_cl_hat_ha S_sheep_births_hat_ha
#>                <num>             <num>                 <num>
#> 1:               NaN    0.000046854152        0.000048411171
#> 2:               NaN    0.000066325878        0.000057753874
#> 3:               NaN    0.000007771546        0.000007320093
#> 4:               NaN    0.000070963917        0.000062521929
#> 5:               NaN    0.000007780997        0.000006834211
#> 6:               NaN    0.000059600116        0.000053976389
#>    S_sheep_deaths_hat_ha S_beef_cl_hat_ha S_beef_births_hat_ha
#>                    <num>            <num>                <num>
#> 1:        0.000007187978       0.02034820          0.005212591
#> 2:        0.000009039695       0.02974461          0.007970856
#> 3:        0.000000000000       0.05393181          0.014745383
#> 4:        0.000009726773       0.03057606          0.008602196
#> 5:        0.000000000000       0.04944272          0.011527594
#> 6:        0.000008478467       0.03322463          0.008456550
#>    S_beef_deaths_hat_ha Q_beef_hat_ha Q_sheep_hat_ha Q_lamb_hat_ha
#>                   <num>         <num>          <num>         <num>
#> 1:          0.000989490   0.004790528  0.00007117650             0
#> 2:          0.001468278   0.009646485  0.00009448864             0
#> 3:          0.002867331   0.014401773  0.00001299674             0
#> 4:          0.001446424   0.009577272  0.00010191595             0
#> 5:          0.002491037   0.014668761  0.00001283228             0
#> 6:          0.001627910   0.009281578  0.00008869032             0
#>    R_beef_hat_ha R_sheep_hat_ha R_lamb_hat_ha C_fodder_hat_ha C_fert_hat_ha
#>            <num>          <num>         <num>           <num>         <num>
#> 1:      7.392679    0.010222802             0       0.3553107  0.0007795925
#> 2:     14.281910    0.014485890             0       0.7040333  0.0670951492
#> 3:     24.308574    0.001821158             0       0.9473936  0.1475929946
#> 4:     14.518771    0.015352095             0       0.7060111  0.0764850563
#> 5:     23.060943    0.001892115             0       1.0269189  0.1592835324
#> 6:     14.474964    0.013278806             0       0.7019839  0.0997758317
#>    C_fuel_hat_ha C_chem_hat_ha A_total_cropped_ha FBP_pfe_hat_ha
#>            <num>         <num>              <num>          <num>
#> 1:     0.4282799  0.0002169123     0.000001588013       2.142158
#> 2:     0.5663560  0.0212989625     0.000144292922       6.679382
#> 3:     0.9244438  0.0398376851     0.000296036096      16.185389
#> 4:     0.5688555  0.0223214940     0.000151675639       7.711993
#> 5:     0.8337981  0.0416492516     0.000316535762      10.294743
#> 6:     0.5575842  0.0293469147     0.000201161236       7.101658
#>    farmland_per_cell    lon    lat
#>                <num>  <num>  <num>
#> 1:          62.26270 142.60 -10.75
#> 2:          61.71605 136.75 -11.05
#> 3:          61.82964 132.90 -11.15
#> 4:          72.85995 136.70 -11.20
#> 5:          61.82964 133.45 -11.60
#> 6:          61.71605 136.25 -11.60
```

## Features

### Caching

{abares} supports caching the files using
`tools::R_user_dir(package = "abares", which = "cache")` to save the
files in a standardised location across platforms so you don’t have to
worry about where the files went or if they’re still there. When
requesting the files, {abares} will first check if they are available
locally. Caching is not mandatory, you can just work with the downloaded
files in `tempdir()`, which is cleaned up when your R session ends.
`get_agfd()` will always check first if the files are available locally,
either cached or in your current R session’s `tempdir()` to save time by
not downloading again if they are available already.

### Multiple Classes Supported

{abares} supports multiple classes of objects to support your workflow.
Select from spatial classes:

- [{stars}](https://CRAN.R-project.org/package=stars),
- [{terra}](https://CRAN.R-project.org/package=terra) or
- [{tidync}](https://CRAN.R-project.org/package=tidync)

or data.frame objects:

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
bugs](https://codeberg.org/adamhsparks/abares/issues).

License: [MIT](LICENSE.md)

Citing the data: Please refer to the ABARES website,
<https://www.agriculture.gov.au/abares/products/citations>, on how to
cite these data when you use them.

## Code of Conduct

Please note that the {abares} project is released with a [Contributor
Code of
Conduct](https://adamhsparks.codeberg.page/abares/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.
