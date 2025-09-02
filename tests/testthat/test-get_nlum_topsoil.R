test_that(".get_nlum downloads and processes Y202021 dataset", {
  local_mocked_bindings(
    .retry_download = function(url, .f) {
      expect_true(grepl("NLUM_v7_250_ALUMV8_2020_21", url))
      writeLines("mock zip content", .f)
      return(invisible(NULL))
    },
    .unzip_file = function(.x) {
      mock_dir <- fs::path(fs::path_dir(.x), "NLUM_v7_250_ALUMV8_2020_21_alb_package_20241128")
      fs::dir_create(mock_dir, recurse = TRUE)
      mock_files <- c(
        fs::path(mock_dir, "NLUM_2020_21.tif"),
        fs::path(mock_dir, "metadata.txt")
      )
      for (f in mock_files) {
        writeLines("mock content", f)
      }
      return(invisible(NULL))
    }
  )
  
  local_mocked_bindings(
    fs::dir_ls = function(path, recurse = FALSE, glob = NULL, ...) {
      if (grepl("NLUM_v7_250_ALUMV8_2020_21", path)) {
        c(
          fs::path(path, "NLUM_2020_21.tif"),
          fs::path(path, "metadata.txt")
        )
      } else {
        character(0)
      }
    }
  )
  
  result <- .get_nlum(.data_set = "Y202021", .x = NULL)
  
  expect_type(result, "character")
  expect_true(any(grepl("NLUM_2020_21.tif", result)))
})

test_that(".get_nlum works with different datasets", {
  local_mocked_bindings(
    .retry_download = function(url, .f) {
      writeLines("mock zip content", .f)
      return(invisible(NULL))
    },
    .unzip_file = function(.x) {
      return(invisible(NULL))
    }
  )
  
  local_mocked_bindings(
    fs::dir_ls = function(path, ...) {
      c(fs::path(path, "test_file.tif"))
    }
  )
  
  # Test different dataset codes
  datasets <- c("Y201516", "Y201011", "C201121", "T202021", "P202021")
  
  for (ds in datasets) {
    result <- .get_nlum(.data_set = ds, .x = NULL)
    expect_type(result, "character")
    expect_length(result, 1)
  }
})

test_that(".get_nlum works with user-provided file", {
  temp_zip <- tempfile(fileext = ".zip")
  writeLines("mock content", temp_zip)
  
  local_mocked_bindings(
    .unzip_file = function(.x) {
      return(invisible(NULL))
    }
  )
  
  local_mocked_bindings(
    fs::dir_ls = function(path, ...) {
      c(fs::path(path, "user_nlum.tif"))
    }
  )
  
  result <- .get_nlum(.data_set = "Y202021", .x = temp_zip)
  
  expect_type(result, "character")
  
  # Clean up
  unlink(temp_zip)
})

test_that(".get_topsoil_thickness downloads and processes data", {
  local_mocked_bindings(
    .retry_download = function(url, .f) {
      expect_true(grepl("staiar9cl__05911a01eg_geo___.zip", url))
      writeLines("mock zip content", .f)
      return(invisible(NULL))
    },
    .unzip_file = function(.x) {
      mock_dir <- fs::path(fs::path_dir(.x), "topsoil_thick/staiar9cl__05911a01eg_geo___")
      fs::dir_create(mock_dir, recurse = TRUE)
      mock_files <- c(
        fs::path(mock_dir, "thpk_1.tif"),
        fs::path(mock_dir, "metadata.txt")
      )
      for (f in mock_files) {
        writeLines("mock content", f)
      }
      return(invisible(NULL))
    },
    terra::rast = function(x) {
      structure(
        list(source = x, nlyr = 1),
        class = "SpatRaster"
      )
    },
    terra::init = function(x, values) {
      return(x)
    },
    readtext::readtext = function(file) {
      data.frame(
        doc_id = basename(file),
        text = "Mock metadata content"
      )
    }
  )
  
  local_mocked_bindings(
    fs::dir_ls = function(path) {
      c(
        fs::path(path, "thpk_1"),
        fs::path(path, "metadata.txt")
      )
    }
  )
  
  result <- .get_topsoil_thickness(.x = NULL)
  
  expect_s3_class(result, "read.abares.topsoil.thickness.files")
  expect_true("data" %in% names(result))
  expect_true("metadata" %in% names(result))
})

test_that(".get_topsoil_thickness works with user-provided file", {
  temp_zip <- tempfile(fileext = ".zip")
  writeLines("mock content", temp_zip)
  
  local_mocked_bindings(
    .unzip_file = function(.x) {
      return(invisible(NULL))
    },
    terra::rast = function(x) {
      structure(list(source = x), class = "SpatRaster")
    },
    terra::init = function(x, values) {
      return(x)
    },
    readtext::readtext = function(file) {
      data.frame(doc_id = basename(file), text = "User metadata")
    }
  )
  
  local_mocked_bindings(
    fs::dir_ls = function(path) {
      c(
        fs::path(path, "thpk_1"),
        fs::path(path, "user_metadata.txt")
      )
    }
  )
  
  result <- .get_topsoil_thickness(.x = temp_zip)
  
  expect_s3_class(result, "read.abares.topsoil.thickness.files")
  
  # Clean up
  unlink(temp_zip)
})

test_that("read_nlum_stars creates stars object", {
  local_mocked_bindings(
    .get_nlum = function(.data_set, .x) {
      c("/mock/path/NLUM_data.tif")
    },
    stars::read_stars = function(x, ...) {
      structure(
        list(
          NLUM = array(1:100, dim = c(10, 10)),
          dimensions = list(
            x = 1:10,
            y = 1:10
          )
        ),
        class = "stars"
      )
    }
  )
  
  result <- read_nlum_stars(data_set = "Y202021", x = NULL)
  
  expect_s3_class(result, "stars")
})

test_that("read_nlum_terra creates SpatRaster object", {
  local_mocked_bindings(
    .get_nlum = function(.data_set, .x) {
      c("/mock/path/NLUM_data.tif")
    },
    terra::rast = function(x) {
      structure(
        list(
          source = x,
          nlyr = 1,
          names = "NLUM"
        ),
        class = "SpatRaster"
      )
    }
  )
  
  result <- read_nlum_terra(data_set = "Y202021", x = NULL)
  
  expect_s3_class(result, "SpatRaster")
})

test_that("read_topsoil_thickness_stars creates stars object", {
  local_mocked_bindings(
    .get_topsoil_thickness = function(.x) {
      structure(
        list(
          data = structure(list(), class = "SpatRaster"),
          metadata = data.frame(text = "metadata")
        ),
        class = "read.abares.topsoil.thickness.files"
      )
    },
    stars::st_as_stars = function(x) {
      structure(
        list(topsoil_thickness = array(1:100, dim = c(10, 10))),
        class = "stars"
      )
    }
  )
  
  result <- read_topsoil_thickness_stars(x = NULL)
  
  expect_s3_class(result, "stars")
})

test_that("read_topsoil_thickness_terra returns SpatRaster", {
  local_mocked_bindings(
    .get_topsoil_thickness = function(.x) {
      structure(
        list(
          data = structure(list(source = "test"), class = "SpatRaster"),
          metadata = data.frame(text = "metadata")
        ),
        class = "read.abares.topsoil.thickness.files"
      )
    }
  )
  
  result <- read_topsoil_thickness_terra(x = NULL)
  
  expect_s3_class(result, "SpatRaster")
  expect_equal(result$source, "test")
})