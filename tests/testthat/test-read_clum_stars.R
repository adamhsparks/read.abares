test_that("read_clum_stars validates data_set parameter correctly", {
  expect_error(
    read_clum_stars(data_set = "invalid_dataset"),
    class = "rlang_error"
  )

  expect_error(
    read_clum_stars(data_set = c("clum_50m_2023_v2", "scale_date_update")),
    class = "rlang_error"
  )

  expect_error(
    read_clum_stars(data_set = NULL),
    class = "rlang_error"
  )
})

test_that("read_clum_stars works with valid data_set values when properly mocked", {
  skip_if_offline()
  # Create a temporary file to simulate downloaded data
  temp_file <- withr::local_tempfile(fileext = ".tif")

  # Write some dummy content to simulate a real file
  writeLines("dummy tiff content", temp_file)

  # Mock .get_clum to return our temp file path
  local({
    .get_clum_orig <- .get_clum
    withr::defer({
      assignInNamespace(".get_clum", .get_clum_orig, "read.abares")
    })

    mock_get_clum <- function(.data_set, .x = NULL) {
      temp_file
    }
    assignInNamespace(".get_clum", mock_get_clum, "read.abares")

    # Mock stars::read_stars to return a simple stars object
    mock_stars_obj <- structure(
      list(data = array(1:100, dim = c(10, 10))),
      class = "stars"
    )

    stars_read_orig <- stars::read_stars
    withr::defer({
      assignInNamespace("read_stars", stars_read_orig, "stars")
    })

    mock_read_stars <- function(x, ...) {
      mock_stars_obj
    }
    assignInNamespace("read_stars", mock_read_stars, "stars")

    # Now test both valid data_set values
    expect_no_error(read_clum_stars(data_set = "clum_50m_2023_v2"))
    expect_no_error(read_clum_stars(data_set = "scale_date_update"))
  })
})

test_that("read_clum_stars passes x parameter correctly", {
  # Track what arguments were passed to .get_clum
  get_clum_calls <- list()

  temp_file <- withr::local_tempfile(fileext = ".tif")
  writeLines("dummy content", temp_file)

  local({
    .get_clum_orig <- .get_clum
    withr::defer({
      assignInNamespace(".get_clum", .get_clum_orig, "read.abares")
    })

    mock_get_clum <- function(.data_set, .x = NULL) {
      get_clum_calls <<- append(
        get_clum_calls,
        list(list(
          data_set = .data_set,
          x = .x
        ))
      )
      temp_file
    }
    assignInNamespace(".get_clum", mock_get_clum, "read.abares")

    # Mock stars::read_stars
    mock_stars_obj <- structure(list(), class = "stars")
    stars_read_orig <- stars::read_stars
    withr::defer({
      assignInNamespace("read_stars", stars_read_orig, "stars")
    })
    assignInNamespace("read_stars", function(x, ...) mock_stars_obj, "stars")

    # Test with custom x parameter
    test_x <- "/custom/path"
    read_clum_stars(data_set = "clum_50m_2023_v2", x = test_x)

    # Check that .get_clum was called with correct arguments
    expect_length(get_clum_calls, 1)
    expect_equal(get_clum_calls[[1]]$data_set, "clum_50m_2023_v2")
    expect_equal(get_clum_calls[[1]]$x, test_x)
  })
})

test_that("read_clum_stars passes additional arguments to stars::read_stars", {
  skip_if_offline()
  # Track what arguments were passed to stars::read_stars
  read_stars_calls <- list()

  temp_file <- withr::local_tempfile(fileext = ".tif")
  writeLines("dummy content", temp_file)

  local({
    # Mock .get_clum
    .get_clum_orig <- .get_clum
    withr::defer({
      assignInNamespace(".get_clum", .get_clum_orig, "read.abares")
    })
    assignInNamespace(
      ".get_clum",
      function(.data_set, .x = NULL) temp_file,
      "read.abares"
    )

    # Mock stars::read_stars to capture arguments
    stars_read_orig <- stars::read_stars
    withr::defer({
      assignInNamespace("read_stars", stars_read_orig, "stars")
    })

    mock_read_stars <- function(x, ...) {
      dots <- list(...)
      read_stars_calls <<- append(
        read_stars_calls,
        list(list(
          x = x,
          dots = dots
        ))
      )
      structure(list(), class = "stars")
    }
    assignInNamespace("read_stars", mock_read_stars, "stars")

    # Test with RAT parameter
    read_clum_stars(data_set = "clum_50m_2023_v2", RAT = "land_use")

    # Check that stars::read_stars was called with correct arguments
    expect_length(read_stars_calls, 1)
    expect_equal(read_stars_calls[[1]]$x, temp_file)
    expect_equal(read_stars_calls[[1]]$dots$RAT, "land_use")
  })
})

test_that("read_clum_stars returns stars object", {
  skip_if_offline()
  temp_file <- withr::local_tempfile(fileext = ".tif")
  writeLines("dummy content", temp_file)

  local({
    # Mock .get_clum
    .get_clum_orig <- .get_clum
    withr::defer({
      assignInNamespace(".get_clum", .get_clum_orig, "read.abares")
    })
    assignInNamespace(
      ".get_clum",
      function(.data_set, .x = NULL) temp_file,
      "read.abares"
    )

    # Mock stars::read_stars to return a known stars object
    expected_stars <- structure(
      list(data = array(1:100, dim = c(10, 10))),
      class = "stars"
    )

    stars_read_orig <- stars::read_stars
    withr::defer({
      assignInNamespace("read_stars", stars_read_orig, "stars")
    })
    assignInNamespace("read_stars", function(x, ...) expected_stars, "stars")

    result <- read_clum_stars(data_set = "clum_50m_2023_v2")
    expect_s3_class(result, "stars")
    expect_identical(result, expected_stars)
  })
})

test_that("read_clum_stars works with default parameters", {
  skip_if_offline()
  temp_file <- withr::local_tempfile(fileext = ".tif")
  writeLines("dummy content", temp_file)

  local({
    # Mock .get_clum
    .get_clum_orig <- .get_clum
    withr::defer({
      assignInNamespace(".get_clum", .get_clum_orig, "read.abares")
    })
    assignInNamespace(
      ".get_clum",
      function(.data_set, .x = NULL) temp_file,
      "read.abares"
    )

    # Mock stars::read_stars
    stars_read_orig <- stars::read_stars
    withr::defer({
      assignInNamespace("read_stars", stars_read_orig, "stars")
    })
    assignInNamespace(
      "read_stars",
      function(x, ...) structure(list(), class = "stars"),
      "stars"
    )

    # Should work with just defaults (data_set = "clum_50m_2023_v2", x = NULL)
    expect_no_error(read_clum_stars())
    expect_s3_class(read_clum_stars(), "stars")
  })
})

test_that("read_clum_stars handles file path from .get_clum correctly", {
  skip_if_offline()
  # Track which file path was passed to stars::read_stars
  read_stars_paths <- character()

  test_path <- "/path/to/clum/data.tif"

  local({
    # Mock .get_clum to return specific path
    .get_clum_orig <- .get_clum
    withr::defer({
      assignInNamespace(".get_clum", .get_clum_orig, "read.abares")
    })
    assignInNamespace(
      ".get_clum",
      function(.data_set, .x = NULL) test_path,
      "read.abares"
    )

    # Mock stars::read_stars to capture the path
    stars_read_orig <- stars::read_stars
    withr::defer({
      assignInNamespace("read_stars", stars_read_orig, "stars")
    })

    mock_read_stars <- function(x, ...) {
      read_stars_paths <<- c(read_stars_paths, x)
      structure(list(), class = "stars")
    }
    assignInNamespace("read_stars", mock_read_stars, "stars")

    read_clum_stars(data_set = "clum_50m_2023_v2")

    expect_length(read_stars_paths, 1)
    expect_identical(read_stars_paths[1], test_path)
  })
})
