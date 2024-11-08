% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_historical_regional_estimates.R
\name{get_historical_regional_estimates}
\alias{get_historical_regional_estimates}
\alias{get_hist_reg_est}
\title{Get Historical Regional Estimates from ABARES}
\source{
\url{https://www.agriculture.gov.au/abares/data/farm-data-portal#data-download}
}
\usage{
get_historical_regional_estimates()

get_hist_reg_est()
}
\value{
A \link[data.table:data.table]{data.table::data.table} object with the \code{Variable} field as the
\code{key}.
}
\description{
Get Historical Regional Estimates from ABARES
}
\note{
Columns are renamed and reordered for consistency.
}
\examples{
\dontshow{if (interactive()) (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}
 get_historical_regional_estimates()

 # or shorter
 get_hist_reg_est()
\dontshow{\}) # examplesIf}
}
\seealso{
Other Estimates: 
\code{\link{get_estimates_by_performance_category}()},
\code{\link{get_estimates_by_size}()},
\code{\link{get_historical_national_estimates}()},
\code{\link{get_historical_state_estimates}()}
}
\concept{Estimates}
