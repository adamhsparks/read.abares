## ----setup, include = FALSE-------------------------------------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)


## ----estimates--------------------------------------------------------------------------------------------------
library(abares)

get_hist_nat_est() |> 
  head()

get_hist_sta_est() |> 
  head()

get_hist_reg_est() |> 
  head()


## ----agfd-------------------------------------------------------------------------------------------------------
library(abares)

## A list of {stars} objects
star <- get_agfd(cache = TRUE) |>
  read_agfd_stars()

head(star[[1]])

## A {terra} `rast` object
terr <- get_agfd(cache = TRUE) |>
  read_agfd_terra()

head(terr[[1]])

## A list of {tidync} objects
tdnc <- get_agfd(cache = TRUE) |>
  read_agfd_tidync()

head(tdnc[[1]])

## A {data.table} object
get_agfd(cache = TRUE) |>
  read_agfd_dt() |>
  head()


## ----soil-thickness---------------------------------------------------------------------------------------------
library(abares)
get_soil_thickness(cache = TRUE) |>
  read_soil_thickness_stars()

x <- get_soil_thickness(cache = TRUE) |>
  read_soil_thickness_terra()


## ----plot-soil-depth--------------------------------------------------------------------------------------------
plot(x)


## ----brief-metadata---------------------------------------------------------------------------------------------
library(abares)
get_soil_thickness(cache = TRUE)


## ----soil-thickness-metadata------------------------------------------------------------------------------------
library(abares)
get_soil_thickness(cache = TRUE) |>
  display_soil_thickness_metadata()


## ----soil-thickness-metada-pander-------------------------------------------------------------------------------
library(abares)
library(pander)
x <- get_soil_thickness(cache = TRUE)
y <- x$metadata
pander(y)

