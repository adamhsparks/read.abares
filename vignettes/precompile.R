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
figs <- fs::dir_ls(glob = "vigfig-*")
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

# move resource files (images) to /doc
resources <- fs::dir_ls(here("vignettes/"), glob = "*.png")
file.copy(from = resources, to = here("doc"), overwrite = TRUE)
