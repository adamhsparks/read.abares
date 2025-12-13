test_that("read_aagis_regions calls .retry_download when x is NULL and file missing", {
  ns <- asNamespace("read.abares")

  fake_sf <- sf::st_sf(
    name = c("WA Region", "NSW Region"),
    class = c("A", "B"),
    zone = c("Z1", "Z2"),
    geometry = sf::st_sfc(sf::st_point(c(0, 0)), sf::st_point(c(1, 1)))
  )

  called <- FALSE
  fake_retry <- function(url, dest) {
    called <<- TRUE
    dest
  }
  fake_read <- function(dsn, quiet) fake_sf
  fake_valid <- function(x) x

  with_mocked_bindings(
    {
      old_read <- sf::st_read
      old_valid <- sf::st_make_valid
      assignInNamespace("st_read", fake_read, ns = "sf")
      assignInNamespace("st_make_valid", fake_valid, ns = "sf")
      on.exit(
        {
          assignInNamespace("st_read", old_read, ns = "sf")
          assignInNamespace("st_make_valid", old_valid, ns = "sf")
        },
        add = TRUE
      )

      # force x=NULL so download branch runs
      result <- read_aagis_regions(x = NULL)
      expect_true(called)
      expect_s3_class(result, "sf")
      expect_equal(result$State, c("WA", "NSW"))
      expect_true("ABARES_region" %in% names(result))
    },
    .retry_download = fake_retry,
    .env = ns
  )
})


test_that("read_aagis_regions bypasses download when x provided", {
  ns <- asNamespace("read.abares")

  fake_sf <- sf::st_sf(
    name = "Queensland Region",
    class = "C",
    zone = "Z3",
    geometry = sf::st_sfc(sf::st_point(c(2, 2)))
  )

  fake_read <- function(dsn, quiet) fake_sf
  fake_valid <- function(x) x

  # patch sf functions directly
  old_read <- sf::st_read
  old_valid <- sf::st_make_valid
  assignInNamespace("st_read", fake_read, ns = "sf")
  assignInNamespace("st_make_valid", fake_valid, ns = "sf")
  on.exit(
    {
      assignInNamespace("st_read", old_read, ns = "sf")
      assignInNamespace("st_make_valid", old_valid, ns = "sf")
    },
    add = TRUE
  )

  # no need for with_mocked_bindings here, since we’re not overriding any read.abares symbols
  result <- read_aagis_regions(x = "local.zip")
  expect_s3_class(result, "sf")
  expect_equal(result$State, "Queensland")
  expect_true("ABARES_region" %in% names(result))
})
