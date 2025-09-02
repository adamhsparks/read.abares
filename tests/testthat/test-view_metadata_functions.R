test_that("view_clum_metadata_pdf downloads and opens PDF in interactive mode", {
  download_calls <- list()
  system_calls <- list()
  
  # Mock interactive session
  local_mocked_bindings(
    rlang::is_interactive = function() TRUE,
    .retry_download = function(url, .f) {
      download_calls <<- append(download_calls, list(list(url = url, file = .f)))
      # Create mock PDF file
      writeLines("mock PDF content", .f)
      return(invisible(NULL))
    },
    system = function(command) {
      system_calls <<- append(system_calls, command)
      return(0)
    }
  )
  
  result <- view_clum_metadata_pdf(commodities = FALSE)
  
  expect_null(result)
  expect_length(download_calls, 1)
  expect_true(grepl("CLUM_DescriptiveMetadata", download_calls[[1]]$url))
  expect_length(system_calls, 1)
  expect_true(grepl("open.*clum_metadata.pdf", system_calls[[1]]))
})

test_that("view_clum_metadata_pdf downloads commodities PDF in non-interactive mode", {
  download_calls <- list()
  system_calls <- list()
  
  # Mock non-interactive session
  local_mocked_bindings(
    rlang::is_interactive = function() FALSE,
    .retry_download = function(url, .f) {
      download_calls <<- append(download_calls, list(list(url = url, file = .f)))
      writeLines("mock PDF content", .f)
      return(invisible(NULL))
    },
    system = function(command) {
      system_calls <<- append(system_calls, command)
      return(0)
    }
  )
  
  result <- view_clum_metadata_pdf(commodities = TRUE)
  
  expect_null(result)
  expect_length(download_calls, 1)
  expect_true(grepl("CLUMC_DescriptiveMetadata", download_calls[[1]]$url))
  expect_length(system_calls, 1)
  expect_true(grepl("open.*clumc_metadata.pdf", system_calls[[1]]))
})

test_that("view_clum_metadata_pdf handles commodities parameter correctly", {
  download_calls <- list()
  
  local_mocked_bindings(
    rlang::is_interactive = function() TRUE,
    .retry_download = function(url, .f) {
      download_calls <<- append(download_calls, url)
      writeLines("mock PDF content", .f)
      return(invisible(NULL))
    },
    system = function(command) return(0)
  )
  
  # Test with commodities = TRUE (should still download regular CLUM in interactive mode)
  view_clum_metadata_pdf(commodities = TRUE)
  expect_true(grepl("CLUM_DescriptiveMetadata", download_calls[[1]]))
  
  # Reset and test with commodities = FALSE
  download_calls <- list()
  view_clum_metadata_pdf(commodities = FALSE)
  expect_true(grepl("CLUM_DescriptiveMetadata", download_calls[[1]]))
})

test_that("view_nlum_metadata_pdf downloads PDF in interactive mode", {
  download_calls <- list()
  
  local_mocked_bindings(
    rlang::is_interactive = function() TRUE,
    .retry_download = function(url, .f) {
      download_calls <<- append(download_calls, list(list(url = url, file = .f)))
      writeLines("mock PDF content", .f)
      return(invisible(NULL))
    }
  )
  
  result <- view_nlum_metadata_pdf()
  
  expect_null(result)
  expect_length(download_calls, 1)
  expect_true(grepl("NLUM_v7_DescriptiveMetadata", download_calls[[1]]$url))
})

test_that("view_nlum_metadata_pdf does nothing in non-interactive mode", {
  download_calls <- list()
  
  local_mocked_bindings(
    rlang::is_interactive = function() FALSE,
    .retry_download = function(url, .f) {
      download_calls <<- append(download_calls, list(list(url = url, file = .f)))
      writeLines("mock PDF content", .f)
      return(invisible(NULL))
    }
  )
  
  result <- view_nlum_metadata_pdf()
  
  expect_null(result)
  expect_length(download_calls, 0)  # Should not download in non-interactive mode
})