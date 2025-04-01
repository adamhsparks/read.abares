# vignettes that depend on Internet access need to be precompiled
library(knitr)
library(here)

# read.abares vignette
knit(
  input = "vignettes/read.abares.Rmd.orig",
  output = "vignettes/read.abares.Rmd"
)
purl("vignettes/read.abares.Rmd.orig", output = "vignettes/read.abares.R")

# Move figures into vignettes/ folder
figs <- fs::dir_ls(glob = "*.png")
fs::file_move(figs, fs::path("vignettes/", figs))

# remove fs::path_file such that vignettes will build with figures
## read.abares vignette
abares_replace <- readLines("vignettes/read.abares.Rmd")
abares_replace <- gsub("\\(figure/", "\\(", abares_replace)

abares_file_con <- file("vignettes/read.abares.Rmd")
writeLines(abares_replace, abares_file_con)
close(abares_file_con)

# build vignettes
library("devtools")
build_vignettes()

# move resource files to /doc
resources <-
  list.files(pattern = ".png$", full.names = TRUE)
file.copy(from = resources, to = "doc", overwrite = TRUE)
