.onLoad <- function(libname, pkgname) {
  op <- options()
  op.read.abares <- list(
    read.abares.user_agent = "read.abares",
    read.abares.timeout = 2000L
  )
  toset <- !(names(op.read.abares) %in% names(op))
  if (any(toset)) options(op.read.abares[toset])
  invisible()
}
