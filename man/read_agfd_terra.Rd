% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/read_agfd_terra.R
\name{read_agfd_terra}
\alias{read_agfd_terra}
\title{Read AGFD NCDF Files With terra}
\usage{
read_agfd_terra(files)
}
\arguments{
\item{files}{A list of NetCDF files to import}
}
\value{
a \code{list} object of \link[terra:rast]{terra::rast} objects of the Australian Gridded
Farm Data with the file names as the list's objects' names
}
\description{
Read Australian Gridded Farm Data, (\acronym{AGFD}) as a \code{list} of
\link[terra:rast]{terra::rast} objects.
}
\examples{
\dontshow{if (interactive()) (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}
get_agfd(cache = TRUE) |>
  read_agfd_terra()
\dontshow{\}) # examplesIf}
}
\seealso{
Other AGFD: 
\code{\link{get_aagis_regions}()},
\code{\link{get_agfd}()},
\code{\link{read_agfd_dt}()},
\code{\link{read_agfd_stars}()},
\code{\link{read_agfd_tidync}()}
}
\concept{AGFD}
