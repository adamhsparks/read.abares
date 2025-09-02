test_that("read.abares_options returns all read.abares options when no arguments", {
  # Store original options
  original_opts <- options()
  
  # Set some test options
  options(
    read.abares.test1 = "value1",
    read.abares.test2 = "value2",
    other.option = "should_not_appear"
  )
  
  result <- read.abares_options()
  
  expect_true(is.list(result))
  expect_true(all(grepl("^read.abares\\.", names(result))))
  expect_false(any(grepl("^other\\.", names(result))))
  
  # Restore original options
  options(original_opts)
})

test_that("read.abares_options sets new options when arguments provided", {
  # Store original options
  original_opts <- options()
  
  # Test setting new options
  read.abares_options(read.abares.new_option = "test_value")
  
  expect_equal(getOption("read.abares.new_option"), "test_value")
  
  # Test setting multiple options
  read.abares_options(
    read.abares.option1 = "value1", 
    read.abares.option2 = 42
  )
  
  expect_equal(getOption("read.abares.option1"), "value1")
  expect_equal(getOption("read.abares.option2"), 42)
  
  # Restore original options
  options(original_opts)
})

test_that("read.abares_options filters correctly", {
  # Store original options
  original_opts <- options()
  
  # Set a mix of options
  options(
    read.abares.filtered = "should_appear",
    readabares.filtered = "should_not_appear",
    not.related = "should_not_appear"
  )
  
  result <- read.abares_options()
  option_names <- names(result)
  
  expect_true("read.abares.filtered" %in% option_names)
  expect_false("readabares.filtered" %in% option_names)
  expect_false("not.related" %in% option_names)
  
  # Restore original options
  options(original_opts)
})

test_that("read.abares_options returns current values for existing options", {
  # Store original options
  original_opts <- options()
  
  # Set some known options
  options(
    read.abares.user_agent = "test_agent",
    read.abares.timeout = 1000L
  )
  
  result <- read.abares_options()
  
  expect_equal(result$read.abares.user_agent, "test_agent")
  expect_equal(result$read.abares.timeout, 1000L)
  
  # Restore original options
  options(original_opts)
})