library(read.abares)
library(data.table)
library(readr)
library(fs)
library(here)
library(tools) # for `file_ext()`
library(openxlsx2)

# cleanup any existing mock files
file_delete(here("tests/testthat/abares"))

# create mock files by running all tests
devtools::test()

# create a list of the mock files that need to be modified
mock_files <- dir_ls(here("tests/testthat/abares"),
  recurse = TRUE,
  type = "file",
  regexp = "[.](R|txt)$"
)

recreate_binary_file <- function(x) {
  if (file_ext(x) == "txt") {
    y <- fread(x, fill = TRUE)
    y <- y[1:5, ]
    fwrite(y)
  } else {
    y <- source(x) # load the list object into R session
    if (basename(x) == "0.R") {
      data_path <- file.path(tempdir(), "y.xlsx")
      tmp <- tempfile(fileext = ".xlsx")
      writeBin(y$value$body, tmp)
      body <- read_xlsx(tmp, sheet = "Database", na.strings = "na")

      # keep only first 5 rows for space saving in the file
      body <- body[1:5, ]
      write_xlsx(body, data_path)

      # read the resulting .xlsx file and insert into the list object as "body"
      y$value$body <- readBin(
        data_path,
        "raw",
        n = file.info(data_path)$size
      )
      y$value$cache <- new.env(parent = emptyenv())
      class(y$value) <- union(
        "httr2_response",
        class(y$value)
      )
      unlink(data_path)
    } else {
      tmp <- tempfile(fileext = ".csv.gz")
      data_path <- file.path(tempdir(), "y.csv")

      # path for saving the resulting .gz file to be inserted as "$value$body"
      write_con <- gzfile(tmp, "wb")

      body_csv <- read_csv(y$value$body)

      # keep only the first 5 rows for space saving in the file
      body_csv <- body_csv[1:5, ]

      # write out to use with readLines
      write_csv(body_csv, data_path)

      # read the csv file using readlines and rewrite
      readLines(data_path) |>
        write.csv(write_con)
      close(write_con)
    }

    # read the resulting .gz file and insert into the list object as "body"
    read_con <- gzfile(tmp, "rb")
    y[[1]][[5]] <- readBin(
      read_con,
      "raw",
      n = file.info(tmp)$size
    )
    y[[1]][[6]] <- new.env(parent = emptyenv())
    class(y[[1]]) <- union(
      "httr2_response",
      class(y[[1]])
    )
    close(read_con)
    unlink(tmp)
    unlink(data_path)
  }
  # lastly, resave the new list object to the same path for mocking
  dput(y, x)
}

# apply the function to the list of mock files
lapply(mock_files, recreate_binary_file)

# rerun tests to ensure that modifications are acceptable
devtools::test()
