test_that("read.abares creates a proper useragent", {
  ua <- readabares_user_agent()
  ver <- as.character(utils::packageVersion("read.abares"))
  repo <- "https://github.com/adamhsparks/read.abares"

  # Build a regex that allows an optional " DEV"
  ver_rx <- gsub("\\.", "\\\\.", ver) # escape dots for regex
  repo_rx <- gsub("\\.", "\\\\.", repo)
  expect_match(
    ua,
    sprintf("^read\\.abares R package %s( DEV)? %s$", ver_rx, repo_rx)
  )
})
