test_that(".readabares_collaborators reads collaborators file", {
  # Mock system.file to return a test file path
  temp_file <- tempfile()
  writeLines(c("collaborator1", "collaborator2", "collaborator3"), temp_file)
  
  local_mocked_bindings(
    system.file = function(file, package) {
      temp_file
    }
  )
  
  result <- .readabares_collaborators()
  
  expect_type(result, "character")
  expect_length(result, 3)
  expect_equal(result, c("collaborator1", "collaborator2", "collaborator3"))
  
  # Clean up
  unlink(temp_file)
})

test_that("readabares_user_agent creates proper user agent string", {
  # Test basic user agent string
  result <- readabares_user_agent()
  
  expect_type(result, "character")
  expect_true(grepl("read.abares R package", result))
  expect_true(grepl("https://github.com/adamhsparks/read.abares", result))
  expect_true(grepl("\\d+\\.\\d+\\.\\d+", result))  # Version pattern
})

test_that("readabares_user_agent detects CI environment", {
  # Mock CI environment
  original_ci <- Sys.getenv("READABARES_CI")
  Sys.setenv("READABARES_CI" = "true")
  
  result <- readabares_user_agent()
  
  expect_true(grepl("CI", result))
  expect_true(grepl("read.abares R package", result))
  
  # Restore original environment
  if (nzchar(original_ci)) {
    Sys.setenv("READABARES_CI" = original_ci)
  } else {
    Sys.unsetenv("READABARES_CI")
  }
})

test_that("readabares_user_agent detects development environment", {
  # Mock development environment by making whoami return a collaborator
  local_mocked_bindings(
    whoami::gh_username = function() "test_collaborator",
    .readabares_collaborators = function() c("test_collaborator", "other_dev")
  )
  
  result <- readabares_user_agent()
  
  expect_true(grepl("DEV", result))
  expect_true(grepl("read.abares R package", result))
})

test_that("readabares_user_agent handles whoami errors gracefully", {
  # Mock whoami to throw an error
  local_mocked_bindings(
    whoami::gh_username = function() stop("No GitHub username found"),
    .readabares_collaborators = function() c("collaborator1", "collaborator2")
  )
  
  result <- readabares_user_agent()
  
  expect_type(result, "character")
  expect_false(grepl("DEV", result))
  expect_false(grepl("CI", result))
  expect_true(grepl("read.abares R package", result))
})

test_that("readabares_user_agent handles non-collaborator users", {
  # Mock whoami to return a non-collaborator
  local_mocked_bindings(
    whoami::gh_username = function() "random_user",
    .readabares_collaborators = function() c("collaborator1", "collaborator2")
  )
  
  result <- readabares_user_agent()
  
  expect_type(result, "character")
  expect_false(grepl("DEV", result))
  expect_false(grepl("CI", result))
  expect_true(grepl("read.abares R package", result))
})