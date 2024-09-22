
# vignettes that depend on Internet access need to be precompiled
library(knitr)
library(here)

# abares vignette
knit(input = "vignettes/abares.Rmd.orig",
     output = "vignettes/abares.Rmd")
purl("vignettes/abares.Rmd.orig",
     output = "vignettes/abares.R")

# move image files
figs <-
  list.files(here("figure/"),
             pattern = ".png$",
             full.names = TRUE)
file.copy(from = figs,
          to = paste0(here("vignettes/"),
                      basename(figs)),
          overwrite = TRUE)
file.remove(figs)
file.remove(here("figure"))

# remove file path such that vignettes will build with figures
## abares vignette
abares_replace <- readLines("vignettes/abares.Rmd")
abares_replace <- gsub("\\(figure/", "\\(", abares_replace)

abares_file_con <- file("vignettes/abares.Rmd")
writeLines(abares_replace, abares_file_con)
close(abares_file_con)

# build vignettes
library("devtools")
build_vignettes()

# move resource files (images) to /doc
resources <-
  list.files(here("vignettes/"),
             pattern = ".png$",
             full.names = TRUE)
file.copy(from = resources,
          to = here("doc"),
          overwrite =  TRUE)
