testthat::test_that(".get_nlum errors on unknown dataset codes", {
  expect_error(.get_nlum(".NOT_A_CODE."), regexp = "(?i)unknown|data.?set|code")
})

testthat::test_that(".get_nlum errors when .x is provided but missing", {
  tmp <- withr::local_tempdir()
  bad <- fs::path(tmp, "not-there.zip")
  expect_error(
    .get_nlum("Y202021", .x = bad),
    regexp = "(?i)does not exist|missing"
  )
})

testthat::test_that(".get_nlum tries package stem first then falls back to canonical", {
  last <- new.env(parent = emptyenv())
  withr::local_options(read.abares.max_tries = 1L)

  # Mock: first attempt fails (package), second succeeds (canonical)
  call_count <- 0L
  testthat::with_mocked_bindings(
    .retry_download = function(url, .f, ...) {
      call_count <<- call_count + 1L
      last$url <- url
      last$f <- .f
      if (call_count == 1L) {
        stop("404 Not Found") # simulate package failing
      } else {
        con <- file(.f, "wb")
        on.exit(close(con))
        writeBin(as.raw(c(0x50, 0x4B, 0x03, 0x04)), con) # minimal ZIP header
        invisible(NULL)
      }
    },
    .unzip_file = function(.x) {
      out <- fs::path_ext_remove(.x)
      fs::dir_create(out, recurse = TRUE)
      fs::file_create(fs::path(out, "ok.tif"))
      invisible(NULL)
    },
    .env = environment(.get_nlum),
    {
      res <- .get_nlum("Y202021")
      # Should have tried twice: package then canonical
      expect_identical(call_count, 2L)
      expect_true(grepl("/NLUM_v7_250m_ALUMV8_2020_21_alb\\.zip$", last$url))
      expect_s3_class(res, "read.abares.agfd.nlum.files")
      expect_true(all(fs::file_exists(res)))
    }
  )
})

testthat::test_that(".get_nlum prefers the live change package name if it works", {
  last <- new.env(parent = emptyenv())
  withr::local_options(read.abares.max_tries = 1L)

  testthat::with_mocked_bindings(
    .retry_download = function(url, .f, ...) {
      last$url <- url
      last$f <- .f
      # Simulate package success on first try (change product)
      con <- file(.f, "wb")
      on.exit(close(con))
      writeBin(as.raw(c(0x50, 0x4B, 0x03, 0x04)), con)
      invisible(NULL)
    },
    .unzip_file = function(.x) {
      out <- fs::path_ext_remove(.x)
      fs::dir_create(out, recurse = TRUE)
      fs::file_create(fs::path(out, "change.tif"))
      invisible(NULL)
    },
    .env = environment(.get_nlum),
    {
      res <- .get_nlum("C201121")
      expect_match(
        last$url,
        "/NLUM_v7_250_CHANGE_SIMP_2011_to_2021_alb_package_[0-9]{8}\\.zip$"
      )
      expect_s3_class(res, "read.abares.agfd.nlum.files")
      expect_setequal(basename(res), "change.tif")
    }
  )
})

testthat::test_that(".get_nlum works for thematic inputs (T*) and probability grids (P*)", {
  last <- new.env(parent = emptyenv())
  withr::local_options(read.abares.max_tries = 1L)

  testthat::with_mocked_bindings(
    .retry_download = function(url, .f, ...) {
      last$url <- url
      last$f <- .f
      con <- file(.f, "wb")
      on.exit(close(con))
      writeBin(as.raw(c(0x50, 0x4B, 0x03, 0x04)), con)
      invisible(NULL)
    },
    .unzip_file = function(.x) {
      out <- fs::path_ext_remove(.x)
      fs::dir_create(out, recurse = TRUE)
      fs::file_create(fs::path(out, "layer.tif"))
      invisible(NULL)
    },
    .env = environment(.get_nlum),
    {
      # INPUTS (T*) should end with _geo
      resT <- .get_nlum("T201011")
      expect_true(grepl(
        "/NLUM_v7_250m_INPUTS_2010_11_geo(_package_[0-9]{8})?\\.zip$",
        last$url
      ))
      expect_s3_class(resT, "read.abares.agfd.nlum.files")

      # AgProbabilitySurfaces (P*) should end with _geo
      resP <- .get_nlum("P201516")
      expect_true(grepl(
        "/NLUM_v7_250m_AgProbabilitySurfaces_2015_16_geo(_package_[0-9]{8})?\\.zip$",
        last$url
      ))
      expect_s3_class(resP, "read.abares.agfd.nlum.files")
    }
  )
})

testthat::test_that(".get_nlum uses provided local .x and skips download", {
  tmp <- withr::local_tempdir()
  ds <- "NLUM_v7_250m_ALUMV8_2020_21_alb"
  zip <- fs::path(tmp, paste0(ds, ".zip"))
  # Create a dummy zip and extracted folder
  con <- file(zip, "wb")
  writeBin(as.raw(c(0x50, 0x4B, 0x03, 0x04)), con)
  close(con)
  out <- fs::path_ext_remove(zip)
  fs::dir_create(out, recurse = TRUE)
  fs::file_create(fs::path(out, c("a.tif", "b.tif")))

  called <- FALSE
  testthat::with_mocked_bindings(
    .retry_download = function(...) {
      called <<- TRUE
      invisible(NULL)
    },
    .unzip_file = function(...) {
      invisible(NULL)
    },
    .env = environment(.get_nlum),
    {
      res <- .get_nlum("Y202021", .x = zip)
      expect_false(called) # download not called
      expect_setequal(basename(res), c("a.tif", "b.tif"))
      expect_s3_class(res, "read.abares.agfd.nlum.files")
    }
  )
})

testthat::test_that(".get_nlum reports all attempted URLs on total failure", {
  withr::local_options(read.abares.max_tries = 1L)
  # Force all candidates to fail
  testthat::with_mocked_bindings(
    .retry_download = function(url, .f, ...) stop("404 Not Found"),
    .unzip_file = function(.x) invisible(NULL),
    .env = environment(.get_nlum),
    {
      expect_error(
        .get_nlum("Y201011"),
        regexp = "(?i)All candidate downloads failed|Tried the following URLs"
      )
    }
  )
})
