# ---------------------------------------------------------------------------
# .readabares_collaborators() — reads installed file (no mocking)
# ---------------------------------------------------------------------------

testthat::test_that(".readabares_collaborators returns contents of installed collaborators.txt", {
  testthat::skip_if_offline()

  path <- system.file("collaborators.txt", package = "read.abares")
  testthat::expect_true(
    nzchar(path),
    info = "collaborators.txt not found via system.file()"
  )
  testthat::expect_true(
    file.exists(path),
    info = sprintf("Missing file at: %s", path)
  )

  expected <- readLines(path)
  out <- .readabares_collaborators()

  testthat::expect_type(out, "character")
  testthat::expect_equal(out, expected)
})

# ---------------------------------------------------------------------------
# read.abares_user_agent() — CI branch (env var set)
# ---------------------------------------------------------------------------

testthat::test_that("read.abares_user_agent returns CI UA when CI env var is set", {
  testthat::skip_if_offline()

  withr::local_envvar(c("READABARES _CI" = "true"))

  # Mock package version for deterministic output.
  testthat::with_mocked_bindings(
    {
      ua <- read.abares_user_agent()
      testthat::expect_identical(
        ua,
        "read.abares R package 9.9.9 CI https://github.com/adamhsparks/read.abares"
      )
    },
    .package = "utils",
    packageVersion = function(pkg) base::package_version("9.9.9")
  )
})

# ---------------------------------------------------------------------------
# read.abares_user_agent() — DEV branch (collaborator, NOT CI)
# ---------------------------------------------------------------------------

testthat::test_that("read.abares_user_agent returns DEV UA when gh_username is a collaborator and NOT CI", {
  testthat::skip_if_offline()

  withr::local_envvar(c("READABARES _CI" = "")) # explicit NOT CI

  # 1) Mock utils::packageVersion -> 2.0.0
  testthat::with_mocked_bindings(
    {
      # 2) Mock whoami::gh_username -> "alice"
      testthat::with_mocked_bindings(
        {
          # 3) Mock collaborators list IN THE PACKAGE NAMESPACE to include "alice"
          testthat::with_mocked_bindings(
            {
              ua <- read.abares_user_agent()
              testthat::expect_identical(
                ua,
                "read.abares R package 2.0.0 DEV https://github.com/adamhsparks/read.abares"
              )
              testthat::expect_false(grepl(" CI ", ua, fixed = TRUE))
            },
            .package = "read.abares",
            .readabares_collaborators = function() c("alice", "bob")
          )
        },
        .package = "whoami",
        gh_username = function() "alice"
      )
    },
    .package = "utils",
    packageVersion = function(pkg) base::package_version("2.0.0")
  )
})

# ---------------------------------------------------------------------------
# read.abares_user_agent() — default branch (NOT CI, NOT collaborator)
# ---------------------------------------------------------------------------

testthat::test_that("read.abares_user_agent returns default UA when NOT CI and user is NOT a collaborator", {
  testthat::skip_if_offline()

  withr::local_envvar(c("READABARES _CI" = "")) # explicit NOT CI

  # 1) Mock utils::packageVersion -> 3.1.4
  testthat::with_mocked_bindings(
    {
      # 2) Mock whoami username to a non-collaborator
      testthat::with_mocked_bindings(
        {
          # 3) Mock collaborators list IN PACKAGE NAMESPACE to exclude 'charlie'
          testthat::with_mocked_bindings(
            {
              ua <- read.abares_user_agent()
              testthat::expect_identical(
                ua,
                "read.abares R package 3.1.4 https://github.com/adamhsparks/read.abares"
              )
              testthat::expect_false(grepl(" DEV ", ua, fixed = TRUE))
              testthat::expect_false(grepl(" CI ", ua, fixed = TRUE))
            },
            .package = "read.abares",
            .readabares_collaborators = function() c("maelle", "adam")
          )
        },
        .package = "whoami",
        gh_username = function() "charlie"
      )
    },
    .package = "utils",
    packageVersion = function(pkg) base::package_version("3.1.4")
  )
})

# ---------------------------------------------------------------------------
# read.abares_user_agent() — robustness: gh_username errors -> default UA (NOT CI)
# ---------------------------------------------------------------------------

testthat::test_that("read.abares_user_agent falls back to default UA if gh_username errors (NOT CI)", {
  testthat::skip_if_offline()

  withr::local_envvar(c("READABARES _CI" = "")) # NOT CI

  testthat::with_mocked_bindings(
    {
      testthat::with_mocked_bindings(
        {
          testthat::with_mocked_bindings(
            {
              ua <- read.abares_user_agent()
              testthat::expect_identical(
                ua,
                "read.abares R package 1.2.3 https://github.com/adamhsparks/read.abares"
              )
              testthat::expect_false(grepl(" DEV ", ua, fixed = TRUE))
              testthat::expect_false(grepl(" CI ", ua, fixed = TRUE))
            },
            .package = "read.abares",
            .readabares_collaborators = function() c("someone", "someoneelse")
          )
        },
        .package = "whoami",
        gh_username = function() stop("boom")
      )
    },
    .package = "utils",
    packageVersion = function(pkg) base::package_version("1.2.3")
  )
})
