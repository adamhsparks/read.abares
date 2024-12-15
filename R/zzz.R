manage_cache <- NULL # nocov start

.onLoad <-
  function(libname = find.package("read.abares"),
           pkgname = "read.abares") {
    # CRAN Note avoidance
    if (getRversion() >= "2.15.1") {
      utils::globalVariables(c("."))

      x <- hoardr::hoard()
      x$cache_path_set(path = "read.abares",
                       prefix = "org.R-project.R/R",
                       type = "user_cache_dir")
      manage_cache <<- x
    }
  }

# nocov end
